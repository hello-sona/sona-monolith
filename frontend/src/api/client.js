const API_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:8000'
const SAFE_METHODS = new Set(['GET', 'HEAD', 'OPTIONS'])
const CSRF_PATH = '/api/auth/csrf'

export const API_UNREACHABLE_MESSAGE = 'Cannot reach the API. Is it running?'

let csrfToken = ''

function isNetworkError(error) {
  if (!(error instanceof TypeError) || !error.message) {
    return false
  }
  return /failed to fetch|networkerror|load failed|network request failed/i.test(
    error.message,
  )
}

function messageFromError(data, fallback) {
  if (!data || typeof data !== 'object') {
    return fallback
  }
  if (typeof data.detail === 'string') {
    return data.detail
  }
  const first = Object.values(data)[0]
  if (Array.isArray(first) && first[0]) {
    return String(first[0])
  }
  if (typeof first === 'string') {
    return first
  }
  return fallback
}

async function parseResponse(response) {
  if (response.status === 204) {
    return null
  }
  const data = await response.json().catch(() => null)
  if (!response.ok) {
    const error = new Error(messageFromError(data, 'Request failed'))
    error.status = response.status
    error.data = data
    throw error
  }
  return data
}

export async function api(path, { method = 'GET', body, headers } = {}) {
  const verb = method.toUpperCase()
  if (!csrfToken && !SAFE_METHODS.has(verb) && path !== CSRF_PATH) {
    await ensureCsrf()
  }

  let response
  try {
    response = await fetch(`${API_URL}${path}`, {
      method: verb,
      credentials: 'include',
      headers: {
        ...(body !== undefined ? { 'Content-Type': 'application/json' } : {}),
        ...(csrfToken ? { 'X-CSRF-Token': csrfToken } : {}),
        ...headers,
      },
      ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
    })
  } catch (error) {
    if (isNetworkError(error)) {
      throw new Error(API_UNREACHABLE_MESSAGE, { cause: error })
    }
    throw error
  }

  // Rails scopes the CSRF token to the session, so signing in or out issues a
  // new one. The API echoes the current token on every response.
  const rotated = response.headers.get('X-CSRF-Token')
  if (rotated) {
    csrfToken = rotated
  }

  return parseResponse(response)
}

export async function ensureCsrf() {
  const data = await api(CSRF_PATH)
  csrfToken = data.csrfToken
  return csrfToken
}
