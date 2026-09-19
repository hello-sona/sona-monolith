import { CssBaseline, ThemeProvider } from '@mui/material'
import { theme } from './theme'

export function Providers({ children }) {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      {children}
    </ThemeProvider>
  )
}
