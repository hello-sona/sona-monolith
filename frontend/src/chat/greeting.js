export function timeOfDayGreeting(displayName) {
  const hour = new Date().getHours()
  const when = hour < 12 ? 'Morning' : hour < 18 ? 'Afternoon' : 'Evening'
  const name = (displayName || '').trim().split(/\s+/)[0] || 'there'
  return `${when}, ${name}`
}
