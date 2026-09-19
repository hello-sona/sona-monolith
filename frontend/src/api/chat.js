import { api } from './client'

export function listConversations() {
  return api('/api/conversations/')
}

export function createConversation() {
  return api('/api/conversations/', { method: 'POST', body: {} })
}

export function renameConversation(id, title) {
  return api(`/api/conversations/${id}/`, { method: 'PATCH', body: { title } })
}

export function deleteConversation(id) {
  return api(`/api/conversations/${id}/`, { method: 'DELETE' })
}

export function listMessages(conversationId) {
  return api(`/api/conversations/${conversationId}/messages/`)
}

export function sendMessage(conversationId, content) {
  return api(`/api/conversations/${conversationId}/messages/`, {
    method: 'POST',
    body: { content },
  })
}
