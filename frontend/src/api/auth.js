import { api } from './client'

export function getMe() {
  return api('/api/auth/me/')
}

export function login(email, password) {
  return api('/api/auth/login/', { method: 'POST', body: { email, password } })
}

export function register({ email, password, displayName }) {
  return api('/api/auth/register/', {
    method: 'POST',
    body: { email, password, display_name: displayName },
  })
}

export function logout() {
  return api('/api/auth/logout/', { method: 'POST' })
}

export function googleAuth(credential) {
  return api('/api/auth/google/', { method: 'POST', body: { credential } })
}
