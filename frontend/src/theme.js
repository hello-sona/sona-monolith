import { createTheme } from '@mui/material/styles'

const colors = {
  pink: '#E27ED9',
  plum: '#571076',
  silver: '#BCBEBC',
  mauve: '#8E7886',
  violet: '#9A4AE8',
}

export const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: colors.violet,
      dark: colors.plum,
      light: colors.pink,
      contrastText: '#ffffff',
    },
    secondary: {
      main: colors.pink,
      contrastText: colors.plum,
    },
    background: {
      default: '#F3F1F3',
      paper: '#ffffff',
    },
    text: {
      primary: '#3B1A4A',
      secondary: colors.mauve,
    },
    divider: colors.silver,
  },
  typography: {
    fontFamily: 'Roboto, Helvetica, Arial, sans-serif',
    h1: {
      fontWeight: 600,
      letterSpacing: '-0.04em',
    },
    h3: {
      fontWeight: 600,
      letterSpacing: '-0.04em',
    },
    h4: {
      fontWeight: 600,
      letterSpacing: '-0.03em',
    },
    h5: {
      fontWeight: 600,
      letterSpacing: '-0.03em',
    },
  },
  shape: {
    borderRadius: 12,
  },
  components: {
    MuiButton: {
      styleOverrides: {
        containedPrimary: {
          boxShadow: 'none',
          '&:hover': {
            boxShadow: 'none',
            backgroundColor: colors.plum,
          },
        },
      },
    },
  },
})

export const chatTheme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: colors.violet,
      dark: '#7A2FD0',
      light: colors.pink,
      contrastText: '#ffffff',
    },
    secondary: {
      main: colors.pink,
      contrastText: '#1a1a1a',
    },
    background: {
      default: '#1a1a1a',
      paper: '#242424',
    },
    text: {
      primary: '#ececec',
      secondary: '#a3a3a3',
    },
    divider: 'rgba(255,255,255,0.08)',
  },
  typography: {
    fontFamily: 'Roboto, Helvetica, Arial, sans-serif',
    button: {
      textTransform: 'none',
      fontWeight: 600,
    },
    h3: {
      fontWeight: 500,
      letterSpacing: '-0.04em',
    },
  },
  shape: {
    borderRadius: 12,
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          boxShadow: 'none',
          '&:hover': { boxShadow: 'none' },
        },
      },
    },
    MuiIconButton: {
      styleOverrides: {
        root: {
          color: '#cfcfcf',
        },
      },
    },
  },
})
