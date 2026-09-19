import { Box } from '@mui/material'
import { GoogleLogin, GoogleOAuthProvider } from '@react-oauth/google'
import { GOOGLE_CLIENT_ID } from '../config'

export function ConfiguredGoogleSignIn({ onSuccess, onError }) {
  return (
    <GoogleOAuthProvider clientId={GOOGLE_CLIENT_ID}>
      <Box sx={{ display: 'flex', justifyContent: 'center' }}>
        <GoogleLogin
          onSuccess={(response) => onSuccess(response.credential)}
          onError={() => onError('Google sign-in was cancelled or failed.')}
          text="continue_with"
          shape="rectangular"
          theme="outline"
          size="large"
          width="352"
        />
      </Box>
    </GoogleOAuthProvider>
  )
}
