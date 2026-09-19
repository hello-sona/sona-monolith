import { useState } from 'react'
import { IconButton, InputBase, Paper, Stack } from '@mui/material'
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpward'

export function Composer({ onSend, disabled, placeholder }) {
  const [value, setValue] = useState('')

  function submit() {
    const content = value.trim()
    if (!content || disabled) {
      return
    }
    onSend(content)
    setValue('')
  }

  return (
    <Paper
      elevation={0}
      sx={{
        maxWidth: 720,
        width: '100%',
        boxSizing: 'border-box',
        borderRadius: 4,
        px: 1.25,
        py: 0.75,
        bgcolor: '#2f2f2f',
        boxShadow: '0 0 0 1px rgba(255,255,255,0.08), 0 12px 32px rgba(0,0,0,0.28)',
      }}
    >
      <Stack direction="row" spacing={1} sx={{ alignItems: 'flex-end' }}>
        <InputBase
          multiline
          maxRows={6}
          fullWidth
          value={value}
          disabled={disabled}
          placeholder={placeholder}
          onChange={(event) => setValue(event.target.value)}
          onKeyDown={(event) => {
            if (event.key === 'Enter' && !event.shiftKey) {
              event.preventDefault()
              submit()
            }
          }}
          sx={{
            px: 1.25,
            py: 1.35,
            fontSize: 16,
            lineHeight: 1.5,
            color: 'text.primary',
            '& textarea::placeholder': { color: 'text.secondary', opacity: 1 },
          }}
        />
        <IconButton
          aria-label="Send message"
          onClick={submit}
          disabled={disabled || !value.trim()}
          sx={{
            mb: 0.35,
            width: 36,
            height: 36,
            bgcolor: 'primary.main',
            color: 'primary.contrastText',
            '&:hover': { bgcolor: 'primary.dark' },
            '&.Mui-disabled': {
              bgcolor: 'rgba(255,255,255,0.08)',
              color: 'text.secondary',
            },
          }}
        >
          <ArrowUpwardIcon sx={{ fontSize: 18 }} />
        </IconButton>
      </Stack>
    </Paper>
  )
}
