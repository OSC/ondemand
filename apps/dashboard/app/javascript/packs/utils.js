

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


