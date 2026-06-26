const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })

  try {
    const { prompt, html, css, js } = await req.json()
    if (!prompt) return new Response('Missing prompt', { status: 400, headers: cors })

    const apiKey = Deno.env.get('ANTHROPIC_API_KEY')
    if (!apiKey) return new Response('No API key configured', { status: 500, headers: cors })

    const systemPrompt = `You are a code assistant inside a web site editor. The user describes a change they want to make to their site. You receive their current HTML, CSS, and JS as separate strings. Return ONLY a raw JSON object with exactly these three keys: {"html": "...", "css": "...", "js": "..."}. No markdown, no code fences, no explanation. Always return complete code, never truncate. If everything is in the HTML tab, keep that pattern.`

    const userMessage = `HTML:\n${html || '(empty)'}\n\nCSS:\n${css || '(empty)'}\n\nJS:\n${js || '(empty)'}\n\nInstruction: ${prompt}`

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
    const cleaned = text.replace(/^```(?:json)?\n?/i, '').replace(/\n?```$/i, '').trim()

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
