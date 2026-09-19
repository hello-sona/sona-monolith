import { useState } from 'react'
import { Link as RouterLink, Navigate, useNavigate } from 'react-router-dom'
import { Alert, Button, Link, Stack, TextField, Typography } from '@mui/material'
import { useAuth } from '../auth/AuthContext'
import { AuthLayout } from '../components/AuthLayout'
import { GoogleSignIn } from '../components/GoogleSignIn'

export function RegisterPage() {
  const { user, ready, register } = useAuth()
  const navigate = useNavigate()
  const [displayName, setDisplayName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [error, setError] = useState('')
  const [submitting, setSubmitting] = useState(false)

  if (ready && user) {
    return <Navigate to="/" replace />
  }

  async function handleSubmit(event) {
    event.preventDefault()
    setError('')
    if (password !== confirmPassword) {
      setError('Passwords do not match.')
      return
    }
    setSubmitting(true)
    try {
      await register({ email, password, displayName })
      navigate('/', { replace: true })
    } catch (err) {
      setError(err.message || 'Could not create an account.')
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
            Create your account
          </Typography>
          <Typography color="text.secondary">
            Continue with Google, or use an email and password.
          </Typography>
        </Stack>

        {error ? <Alert severity="error">{error}</Alert> : null}

        <GoogleSignIn onSignedIn={() => navigate('/', { replace: true })} onError={setError} />

        <Stack spacing={3} component="form" onSubmit={handleSubmit}>
          <TextField
            label="Name"
            name="name"
            autoComplete="name"
            value={displayName}
            onChange={(event) => setDisplayName(event.target.value)}
            fullWidth
          />
          <TextField
            label="Email"
            type="email"
            name="email"
            autoComplete="email"
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            required
            fullWidth
          />
          <TextField
            label="Password"
            type="password"
            name="password"
            autoComplete="new-password"
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            required
            fullWidth
            helperText="At least 8 characters."
          />
          <TextField
            label="Confirm password"
            type="password"
            name="confirmPassword"
            autoComplete="new-password"
            value={confirmPassword}
            onChange={(event) => setConfirmPassword(event.target.value)}
            required
            fullWidth
          />
          <Button type="submit" variant="contained" size="large" disabled={submitting}>
            {submitting ? 'Creating account…' : 'Create account'}
          </Button>
          <Typography color="text.secondary">
            Already have an account?{' '}
            <Link component={RouterLink} to="/login">
              Sign in
            </Link>
          </Typography>
        </Stack>
      </Stack>
    </AuthLayout>
  )
}
