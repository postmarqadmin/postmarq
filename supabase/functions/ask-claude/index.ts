import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })

  try {
    const { prompt, html, css, js } = await req.json()
    if (!prompt) return new Response('Missing prompt', { status: 400, headers: cors })

    // Auth check
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) return new Response('Unauthorized', { status: 401, headers: cors })

    const sb = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user }, error: authError } = await sb.auth.getUser()
    if (authError || !user) return new Response('Unauthorized', { status: 401, headers: cors })

    // Plan A / Plan B: use user's own key if they have one, else fall back to Postmarq's key
    const { data: profile } = await sb
      .from('profiles')
      .select('anthropic_api_key')
      .eq('id', user.id)
      .single()

    const apiKey = profile?.anthropic_api_key || Deno.env.get('ANTHROPIC_API_KEY')
    if (!apiKey) return new Response('No API key configured', { status: 500, headers: cors })

    const systemPrompt = `You are a code assistant inside a web site editor. The user describes a change they want to make to their site. You receive their current HTML, CSS, and JS as separate strings.

Return ONLY a raw JSON object — no markdown, no code fences, no explanation — with exactly these three keys:
{"html": "...", "css": "...", "js": "..."}

Rules:
- Always return complete code for each tab, never truncate
- If a tab is empty and the change doesn't affect it, return it unchanged (empty string is fine)
- If everything is in the HTML tab (inline style and script tags), keep that pattern — don't split it out
- Preserve all existing functionality unless the user explicitly asks to remove something`

    const userMessage = `Current code:

HTML:
${html || '(empty)'}

CSS:
${css || '(empty)'}

JS:
${js || '(empty)'}

Instruction: ${prompt}`

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        model: 'claude-sonnet-4-6',
        max_tokens: 8192,
        system: systemPrompt,
        messages: [{ role: 'user', content: userMessage }],
      }),
    })

    if (!response.ok) {
      const err = await response.text()
      return new Response(JSON.stringify({ error: err }), { status: 502, headers: { ...cors, 'Content-Type': 'application/json' } })
    }

    const data = await response.json()
    const text = data.content?.[0]?.text || ''

    // Strip markdown code fences if Claude wrapped the JSON anyway
    const cleaned = text.replace(/^```(?:json)?\n?/i, '').replace(/\n?```$/i, '').trim()

    // Validate it's parseable JSON before sending back
    JSON.parse(cleaned)

    return new Response(cleaned, {
      headers: { ...cors, 'Content-Type': 'application/json' },
    })

  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    })
  }
})
