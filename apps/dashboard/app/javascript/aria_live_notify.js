
export function ariaNotify(message) {
  const liveRegion = document.getElementById("aria_live_region");

  if(liveRegion) {
    liveRegion.textContent = message;
  }
}