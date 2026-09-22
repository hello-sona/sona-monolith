import { useCallback, useEffect, useRef, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import {
  AppBar,
  Box,
  CircularProgress,
  Drawer,
  IconButton,
  Stack,
  Toolbar,
  Typography,
} from '@mui/material'
import { ThemeProvider } from '@mui/material/styles'
import MenuIcon from '@mui/icons-material/Menu'
import { useAuth } from '../auth/AuthContext'
import {
  createConversation,
  deleteConversation,
  listConversations,
  listMessages,
  renameConversation,
  sendMessage,
} from '../api/chat'
import { timeOfDayGreeting } from '../chat/greeting'
import { Composer } from '../components/Composer'
import { MessageThread } from '../components/MessageThread'
import { Sidebar } from '../components/Sidebar'
import { chatTheme } from '../theme'

const DRAWER_WIDTH = 260
const SIDEBAR_BG = '#111111'

export function ChatPage() {
  const { user, logout } = useAuth()
  const { conversationId } = useParams()
  const navigate = useNavigate()
  const [conversations, setConversations] = useState([])
  const [messages, setMessages] = useState([])
  const [loadingList, setLoadingList] = useState(true)
  const [loadingThread, setLoadingThread] = useState(false)
  const [sending, setSending] = useState(false)
  const [mobileOpen, setMobileOpen] = useState(false)
  const threadEndRef = useRef(null)
  const skipNextLoadRef = useRef(false)

  const refreshConversations = useCallback(async () => {
    const data = await listConversations()
    setConversations(data)
    return data
  }, [])

  useEffect(() => {
    let cancelled = false
    ;(async () => {
      try {
        const data = await listConversations()
        if (!cancelled) {
          setConversations(data)
        }
      } finally {
        if (!cancelled) {
          setLoadingList(false)
        }
      }
    })()
    return () => {
      cancelled = true
    }
  }, [])

  useEffect(() => {
    if (!conversationId) {
      return undefined
    }

    if (skipNextLoadRef.current) {
      skipNextLoadRef.current = false
      setLoadingThread(false)
      return undefined
    }

    let cancelled = false
    setLoadingThread(true)
    ;(async () => {
      try {
        const data = await listMessages(conversationId)
        if (!cancelled) {
          setMessages(data)
        }
      } catch {
        if (!cancelled) {
          navigate('/', { replace: true })
        }
      } finally {
        if (!cancelled) {
          setLoadingThread(false)
        }
      }
    })()

    return () => {
      cancelled = true
    }
  }, [conversationId, navigate])

  useEffect(() => {
    threadEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  async function handleSend(content) {
    setSending(true)
    try {
      let activeId = conversationId
      if (!activeId) {
        const created = await createConversation()
        activeId = created.id
        const result = await sendMessage(activeId, content)
        skipNextLoadRef.current = true
        setMessages([result.user_message, result.assistant_message])
        await refreshConversations()
        navigate(`/c/${activeId}`, { replace: true })
        return
      }

      const result = await sendMessage(activeId, content)
      setMessages((current) => [
        ...current,
        result.user_message,
        result.assistant_message,
      ])
      await refreshConversations()
    } finally {
      setSending(false)
    }
  }

  async function handleDelete(id) {
    await deleteConversation(id)
    await refreshConversations()
    if (id === conversationId) {
      setMessages([])
      navigate('/', { replace: true })
    }
  }

  async function handleRename(id, title) {
    await renameConversation(id, title)
    await refreshConversations()
  }

  async function handleLogout() {
    await logout()
    navigate('/login', { replace: true })
  }

  const sidebar = (
    <Sidebar
      user={user}
      conversations={conversations}
      selectedId={conversationId}
      onNewChat={() => {
        setMobileOpen(false)
        setMessages([])
        navigate('/')
      }}
      onSelect={(id) => {
        setMobileOpen(false)
        navigate(`/c/${id}`)
      }}
      onRename={handleRename}
      onDelete={handleDelete}
      onLogout={handleLogout}
    />
  )

  const selected = conversations.find((conversation) => conversation.id === conversationId)
  const showEmpty = !conversationId && messages.length === 0
  const composer = (
    <Composer
      onSend={handleSend}
      disabled={sending}
      placeholder={showEmpty ? 'How can I help you today?' : 'Ask anything'}
    />
  )

  return (
    <ThemeProvider theme={chatTheme}>
      <Box sx={{ display: 'flex', height: '100vh', bgcolor: 'background.default' }}>
        <Box
          component="nav"
          sx={{ width: { md: DRAWER_WIDTH }, flexShrink: { md: 0 } }}
          aria-label="Conversations"
        >
          <Drawer
            variant="temporary"
            open={mobileOpen}
            onClose={() => setMobileOpen(false)}
            ModalProps={{ keepMounted: true }}
            sx={{
              display: { xs: 'block', md: 'none' },
              '& .MuiDrawer-paper': {
                width: DRAWER_WIDTH,
                bgcolor: SIDEBAR_BG,
                border: 0,
                backgroundImage: 'none',
              },
            }}
          >
            {sidebar}
          </Drawer>
          <Drawer
            variant="permanent"
            open
            sx={{
              display: { xs: 'none', md: 'block' },
              '& .MuiDrawer-paper': {
                width: DRAWER_WIDTH,
                bgcolor: SIDEBAR_BG,
                border: 0,
                backgroundImage: 'none',
              },
            }}
          >
            {sidebar}
          </Drawer>
        </Box>

        <Box sx={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0, bgcolor: '#1a1a1a' }}>
          <AppBar
            position="static"
            elevation={0}
            color="transparent"
            sx={{ display: { md: 'none' } }}
          >
            <Toolbar>
              <IconButton edge="start" aria-label="Open conversations" onClick={() => setMobileOpen(true)}>
                <MenuIcon />
              </IconButton>
              <Typography variant="h6" noWrap sx={{ fontWeight: 600, fontSize: 16, color: '#fff' }}>
                {selected?.title ?? 'New chat'}
              </Typography>
            </Toolbar>
          </AppBar>

          {loadingList && conversations.length === 0 && !showEmpty ? (
            <Stack sx={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
              <CircularProgress size={28} />
            </Stack>
          ) : showEmpty ? (
            <Box
              sx={{
                flex: 1,
                minWidth: 0,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                px: { xs: 2, sm: 3 },
                pb: 10,
              }}
            >
              <Box sx={{ width: '100%', maxWidth: 720 }}>
                <Typography
                  variant="h3"
                  component="h1"
                  sx={{
                    textAlign: 'center',
                    mb: 4,
                    fontWeight: 500,
                    fontSize: { xs: 32, sm: 40 },
                    color: '#ececec',
                  }}
                >
                  {timeOfDayGreeting(user.display_name)}
                </Typography>
                {composer}
              </Box>
            </Box>
          ) : (
            <>
              <Box sx={{ flex: 1, overflow: 'auto', px: { xs: 2, sm: 3 }, py: { xs: 3, sm: 5 }, minWidth: 0 }}>
                {loadingThread ? (
                  <Stack sx={{ alignItems: 'center', justifyContent: 'center', height: '100%' }}>
                    <CircularProgress size={28} />
                  </Stack>
                ) : (
                  <>
                    <MessageThread messages={messages} />
                    <Box ref={threadEndRef} />
                  </>
                )}
              </Box>
              <Box sx={{ px: { xs: 2, sm: 3 }, pb: 3, pt: 1 }}>{composer}</Box>
            </>
          )}
        </Box>
      </Box>
    </ThemeProvider>
  )
}
