import { useState } from 'react'
import { Link as RouterLink, Navigate, useNavigate } from 'react-router-dom'
import { Alert, Button, Link, Stack, TextField, Typography } from '@mui/material'
import { useAuth } from '../auth/AuthContext'
import { AuthLayout } from '../components/AuthLayout'
import { GoogleSignIn } from '../components/GoogleSignIn'

export function LoginPage() {
  const { user, ready, login } = useAuth()
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [submitting, setSubmitting] = useState(false)

  if (ready && user) {
    return <Navigate to="/" replace />
  }

  async function handleSubmit(event) {
    event.preventDefault()
    setError('')
    setSubmitting(true)
    try {
      await login(email, password)
      navigate('/', { replace: true })
    } catch (err) {
      setError(err.message || 'Could not sign in.')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <AuthLayout>
      <Stack spacing={3}>
        <Stack spacing={1}>
          <Typography variant="overline" color="primary" sx={{ letterSpacing: '0.16em' }}>
            Sona
          </Typography>
          <Typography variant="h4" component="h1">
            Welcome back
          </Typography>
          <Typography color="text.secondary">
            Sign in to continue your conversations.
          </Typography>
        </Stack>

        {error ? <Alert severity="error">{error}</Alert> : null}

        <GoogleSignIn onSignedIn={() => navigate('/', { replace: true })} onError={setError} />

        <Stack spacing={3} component="form" onSubmit={handleSubmit}>
          <TextField
            label="Email"
            type="text"
            name="email"
            autoComplete="username"
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            required
            fullWidth
          />
          <TextField
            label="Password"
            type="password"
            name="password"
            autoComplete="current-password"
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            required
            fullWidth
          />
          <Button type="submit" variant="contained" size="large" disabled={submitting}>
            {submitting ? 'Signing in…' : 'Sign in'}
          </Button>
          <Typography color="text.secondary">
            New here?{' '}
            <Link component={RouterLink} to="/register">
              Create an account
            </Link>
          </Typography>
        </Stack>
      </Stack>
    </AuthLayout>
  )
}
