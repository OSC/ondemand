
export function cssBadgeForState(state){
  switch (state) {
    case 'completed':
      return 'badge-success';
    case 'running':
      return 'badge-primary'
    case 'queued':
      return 'badge-info';
    case 'queued_held':
      return 'badge-warning';
    case 'suspended':
      return 'badge-warning';
    default:
      return 'badge-warning';
  }
}

export function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

export function startOfYear() {
  const now = new Date();
  const past = new Date();
  past.setDate(1);
  past.setMonth(0);
  past.setFullYear(now.getFullYear());
  return `${past.getFullYear()}-${past.getMonth()+1}-${past.getDate()}`;
}

export function thirtyDaysAgo() {
  const now = new Date();
  const past = new Date();
  past.setDate(now.getDate() - 30);
  return `${past.getFullYear()}-${past.getMonth()+1}-${past.getDate()}`;
}

export function today() {
  const now = new Date();
  return `${now.getFullYear()}-${now.getMonth()+1}-${now.getDate()}`;
}
