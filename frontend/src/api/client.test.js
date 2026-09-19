import { api, API_UNREACHABLE_MESSAGE } from './client'

afterEach(() => {
  vi.unstubAllGlobals()
})

test('maps Failed to fetch to a reachable-API message', async () => {
  vi.stubGlobal(
    'fetch',
    vi.fn(() => Promise.reject(new TypeError('Failed to fetch'))),
  )

  await expect(api('/api/auth/me/')).rejects.toThrow(API_UNREACHABLE_MESSAGE)
})

test('maps Firefox NetworkError to a reachable-API message', async () => {
  vi.stubGlobal(
    'fetch',
    vi.fn(() =>
      Promise.reject(new TypeError('NetworkError when attempting to fetch resource.')),
    ),
  )

  await expect(api('/api/auth/me/')).rejects.toThrow(API_UNREACHABLE_MESSAGE)
})
