import { createContext, useContext, useEffect, useMemo, useState } from 'react'
import { getMe, googleAuth, login as loginRequest, logout as logoutRequest, register as registerRequest } from '../api/auth'
import { ensureCsrf } from '../api/client'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [ready, setReady] = useState(false)

  useEffect(() => {
    let cancelled = false

    ;(async () => {
      try {
        await ensureCsrf()
        const me = await getMe()
        if (!cancelled) {
          setUser(me)
        }
      } catch {
        if (!cancelled) {
          setUser(null)
        }
      } finally {
        if (!cancelled) {
          setReady(true)
        }
      }
    })()

    return () => {
      cancelled = true
    }
  }, [])

  const value = useMemo(
    () => ({
      user,
      ready,
      async login(email, password) {
        const nextUser = await loginRequest(email, password)
        setUser(nextUser)
        return nextUser
      },
      async loginWithGoogle(credential) {
        const nextUser = await googleAuth(credential)
        setUser(nextUser)
        return nextUser
      },
      async register(payload) {
        const nextUser = await registerRequest(payload)
        setUser(nextUser)
        return nextUser
      },
      async logout() {
        await logoutRequest()
        setUser(null)
      },
    }),
    [user, ready],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}
