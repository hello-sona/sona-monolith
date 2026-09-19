import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { API_UNREACHABLE_MESSAGE } from './api/client'
import App from './App'
import { Providers } from './providers'

function jsonResponse(status, body) {
  return Promise.resolve({
    ok: status >= 200 && status < 300,
    status,
    json: async () => body,
  })
}

beforeEach(() => {
  global.fetch = vi.fn((url, options = {}) => {
    const path = String(url)
    const method = options.method ?? 'GET'

    if (path.endsWith('/api/auth/csrf/')) {
      return jsonResponse(200, { csrfToken: 'test-csrf' })
    }
    if (path.endsWith('/api/auth/me/')) {
      return jsonResponse(403, { detail: 'Authentication credentials were not provided.' })
    }
    if (path.endsWith('/api/auth/login/') && method === 'POST') {
      return jsonResponse(200, { id: 1, email: 'ada@example.com', display_name: 'Ada' })
    }
    if (path.endsWith('/api/conversations/') && method === 'GET') {
      return jsonResponse(200, [])
    }
    return jsonResponse(404, { detail: 'Not found' })
  })
})

test('shows the login screen, then the empty chat after signing in', async () => {
  const user = userEvent.setup()
  render(
    <Providers>
      <App />
    </Providers>,
  )

  expect(await screen.findByRole('heading', { name: /welcome back/i })).toBeInTheDocument()
  expect(screen.getByRole('button', { name: /continue with google/i })).toBeInTheDocument()

  await user.type(screen.getByLabelText(/email/i), 'ada@example.com')
  await user.type(screen.getByLabelText(/password/i), 'password123')
  await user.click(screen.getByRole('button', { name: /sign in/i }))

  expect(await screen.findByRole('heading', { name: /morning, ada|afternoon, ada|evening, ada/i })).toBeInTheDocument()
  expect(screen.getAllByRole('button', { name: /new chat/i }).length).toBeGreaterThan(0)
  expect(screen.getAllByText('Ada').length).toBeGreaterThan(0)
})

test('shows a reachable-API error instead of Failed to fetch', async () => {
  global.fetch = vi.fn((url, options = {}) => {
    const path = String(url)
    const method = options.method ?? 'GET'

    if (path.endsWith('/api/auth/csrf/')) {
      return jsonResponse(200, { csrfToken: 'test-csrf' })
    }
    if (path.endsWith('/api/auth/me/')) {
      return jsonResponse(403, { detail: 'Authentication credentials were not provided.' })
    }
    if (path.endsWith('/api/auth/login/') && method === 'POST') {
      return Promise.reject(new TypeError('Failed to fetch'))
    }
    return jsonResponse(404, { detail: 'Not found' })
  })

  const user = userEvent.setup()
  render(
    <Providers>
      <App />
    </Providers>,
  )

  expect(await screen.findByRole('heading', { name: /welcome back/i })).toBeInTheDocument()
  await user.type(screen.getByLabelText(/email/i), 'admin@example.com')
  await user.type(screen.getByLabelText(/password/i), 'password!123')
  await user.click(screen.getByRole('button', { name: /sign in/i }))

  expect(await screen.findByText(API_UNREACHABLE_MESSAGE)).toBeInTheDocument()
  expect(screen.queryByText(/failed to fetch/i)).not.toBeInTheDocument()
})
