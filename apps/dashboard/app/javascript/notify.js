export function ariaNotify(message) {
  const liveRegion = document.getElementById("aria_live_region");

  if(liveRegion) {
    liveRegion.textContent = message;
  }
}

export function pushNotify(message, options = {}) {
  if (!("Notification" in window)) return;

  if (Notification.permission === "granted") {
    new Notification(message, options);
  } else if (Notification.permission !== "denied") {
    Notification.requestPermission().then(permission => {
      if (permission === "granted") {
        new Notification(message, options);
      }
    });
  }
}
