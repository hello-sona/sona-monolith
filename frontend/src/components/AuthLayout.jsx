import { Box, Paper } from '@mui/material'

export function AuthLayout({ children }) {
  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        px: 2,
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      <Box
        aria-hidden
        sx={{
          position: 'absolute',
          inset: -32,
          backgroundImage: 'url(/base-background.jpg)',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          filter: 'blur(16px) saturate(1.05)',
          transform: 'scale(1.08)',
        }}
      />
      <Box
        aria-hidden
        sx={{
          position: 'absolute',
          inset: 0,
          background:
            'linear-gradient(160deg, rgba(87, 16, 118, 0.42) 0%, rgba(154, 74, 232, 0.22) 48%, rgba(226, 126, 217, 0.18) 100%)',
        }}
      />
      <Paper
        elevation={0}
        sx={{
          position: 'relative',
          width: '100%',
          maxWidth: 420,
          p: { xs: 3, sm: 4.5 },
          bgcolor: 'rgba(255, 255, 255, 0.82)',
          backdropFilter: 'blur(22px)',
          border: '1px solid rgba(255, 255, 255, 0.55)',
        }}
      >
        {children}
      </Paper>
    </Box>
  )
}
