import { Box, Stack, Typography } from '@mui/material'

export function MessageThread({ messages }) {
  return (
    <Stack spacing={3.5} sx={{ maxWidth: 720, mx: 'auto', width: '100%' }}>
      {messages.map((message) => {
        const isUser = message.role === 'user'
        return (
          <Box
            key={message.id}
            sx={{ display: 'flex', justifyContent: isUser ? 'flex-end' : 'flex-start' }}
          >
            <Box
              sx={{
                maxWidth: isUser ? '72%' : '100%',
                px: isUser ? 2 : 0.5,
                py: isUser ? 1.35 : 0,
                borderRadius: 4,
                bgcolor: isUser ? '#2f2f2f' : 'transparent',
                color: 'text.primary',
              }}
            >
              {!isUser ? (
                <Typography
                  variant="overline"
                  sx={{ letterSpacing: '0.14em', color: 'primary.light', display: 'block', mb: 0.75 }}
                >
                  Sona
                </Typography>
              ) : null}
              <Typography sx={{ whiteSpace: 'pre-wrap', lineHeight: 1.75, fontSize: 16 }}>
                {message.content}
              </Typography>
            </Box>
          </Box>
        )
      })}
    </Stack>
  )
}
