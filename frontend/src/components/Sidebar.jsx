import { useState } from 'react'
import {
  Box,
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  IconButton,
  List,
  ListItemButton,
  ListItemText,
  Stack,
  TextField,
  Typography,
} from '@mui/material'
import AddIcon from '@mui/icons-material/Add'
import DeleteOutlinedIcon from '@mui/icons-material/DeleteOutlined'
import EditOutlinedIcon from '@mui/icons-material/EditOutlined'
import LogoutIcon from '@mui/icons-material/Logout'

export function Sidebar({
  user,
  conversations,
  selectedId,
  onNewChat,
  onSelect,
  onRename,
  onDelete,
  onLogout,
}) {
  const [renameId, setRenameId] = useState(null)
  const [renameValue, setRenameValue] = useState('')

  const renaming = conversations.find((conversation) => conversation.id === renameId)

  return (
    <Stack spacing={1.5} sx={{ height: '100%', px: 1.5, py: 2 }}>
      <Typography
        sx={{
          px: 1,
          pt: 0.5,
          pb: 1,
          fontWeight: 600,
          fontSize: 18,
          letterSpacing: '-0.03em',
        }}
      >
        Sona
      </Typography>

      <Button
        fullWidth
        onClick={onNewChat}
        startIcon={<AddIcon />}
        sx={{
          justifyContent: 'flex-start',
          color: 'text.primary',
          bgcolor: 'rgba(255,255,255,0.07)',
          borderRadius: 2,
          px: 1.5,
          py: 1,
          '&:hover': { bgcolor: 'rgba(255,255,255,0.12)' },
        }}
      >
        New chat
      </Button>

      <Box sx={{ flex: 1, overflow: 'auto', pt: 1.5 }}>
        {conversations.length > 0 ? (
          <Typography
            variant="caption"
            sx={{
              display: 'block',
              px: 1.25,
              pb: 0.75,
              color: 'text.secondary',
              letterSpacing: '0.04em',
              textTransform: 'uppercase',
              fontSize: 11,
            }}
          >
            Chats
          </Typography>
        ) : null}
        <List disablePadding>
          {conversations.map((conversation) => (
            <ListItemButton
              key={conversation.id}
              selected={conversation.id === selectedId}
              onClick={() => onSelect(conversation.id)}
              sx={{
                borderRadius: 2,
                mb: 0.25,
                py: 0.85,
                px: 1.25,
                '&:hover .conversation-actions': { opacity: 1 },
                '&.Mui-selected': {
                  bgcolor: 'rgba(255,255,255,0.08)',
                },
                '&.Mui-selected:hover': {
                  bgcolor: 'rgba(255,255,255,0.11)',
                },
              }}
            >
              <ListItemText
                primary={conversation.title}
                slotProps={{
                  primary: {
                    noWrap: true,
                    sx: {
                      fontSize: 14,
                      fontWeight: conversation.id === selectedId ? 600 : 400,
                    },
                  },
                }}
              />
              <Stack
                direction="row"
                className="conversation-actions"
                sx={{ opacity: conversation.id === selectedId ? 1 : 0, ml: 0.5 }}
              >
                <IconButton
                  size="small"
                  aria-label={`Rename ${conversation.title}`}
                  onClick={(event) => {
                    event.stopPropagation()
                    setRenameId(conversation.id)
                    setRenameValue(conversation.title)
                  }}
                >
                  <EditOutlinedIcon sx={{ fontSize: 16 }} />
                </IconButton>
                <IconButton
                  size="small"
                  aria-label={`Delete ${conversation.title}`}
                  onClick={(event) => {
                    event.stopPropagation()
                    onDelete(conversation.id)
                  }}
                >
                  <DeleteOutlinedIcon sx={{ fontSize: 16 }} />
                </IconButton>
              </Stack>
            </ListItemButton>
          ))}
        </List>
      </Box>

      <Stack
        direction="row"
        spacing={1}
        sx={{
          alignItems: 'center',
          px: 0.75,
          py: 0.75,
          borderRadius: 2,
        }}
      >
        <Box
          sx={{
            width: 28,
            height: 28,
            borderRadius: '50%',
            bgcolor: 'primary.main',
            color: 'primary.contrastText',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: 13,
            fontWeight: 700,
            flexShrink: 0,
          }}
        >
          {(user.display_name || user.email).slice(0, 1).toUpperCase()}
        </Box>
        <Box sx={{ flex: 1, minWidth: 0 }}>
          <Typography noWrap sx={{ fontWeight: 600, fontSize: 14 }}>
            {user.display_name}
          </Typography>
          <Typography noWrap variant="body2" color="text.secondary" sx={{ fontSize: 12 }}>
            {user.email}
          </Typography>
        </Box>
        <IconButton aria-label="Sign out" onClick={onLogout} size="small">
          <LogoutIcon sx={{ fontSize: 18 }} />
        </IconButton>
      </Stack>

      <Dialog open={Boolean(renaming)} onClose={() => setRenameId(null)} fullWidth maxWidth="xs">
        <DialogTitle>Rename chat</DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            margin="dense"
            label="Title"
            fullWidth
            value={renameValue}
            onChange={(event) => setRenameValue(event.target.value)}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setRenameId(null)}>Cancel</Button>
          <Button
            variant="contained"
            onClick={() => {
              onRename(renameId, renameValue.trim() || 'New chat')
              setRenameId(null)
            }}
          >
            Save
          </Button>
        </DialogActions>
      </Dialog>
    </Stack>
  )
}
