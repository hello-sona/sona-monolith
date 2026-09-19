import { BrowserRouter, Navigate, Outlet, Route, Routes } from 'react-router-dom'
import { Box, CircularProgress } from '@mui/material'
import { AuthProvider, useAuth } from './auth/AuthContext'
import { ChatPage } from './pages/ChatPage'
import { LoginPage } from './pages/LoginPage'
import { RegisterPage } from './pages/RegisterPage'

function LoadingScreen() {
  return (
    <Box sx={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <CircularProgress size={28} />
    </Box>
  )
}

function RequireAuth() {
  const { user, ready } = useAuth()
  if (!ready) {
    return <LoadingScreen />
  }
  if (!user) {
    return <Navigate to="/login" replace />
  }
  return <Outlet />
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />
          <Route element={<RequireAuth />}>
            <Route path="/" element={<ChatPage />} />
            <Route path="/c/:conversationId" element={<ChatPage />} />
          </Route>
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  )
}
