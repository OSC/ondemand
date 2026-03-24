
export default function initPopovers() {
  customizePopoverTriggers();
   
  $('li.vdi').popover({
    trigger: "hover",
    content: "A VDI (Virtual Desktop Interface) gives you desktop access to a shared node. This is the graphical version of a login node. Use this for lightweight tasks like accessing & viewing files, submitting jobs, and for visualizations.",
    title: function(){ return $(this).text() }
  });

  $('li.ihpc').popover({
    trigger: "hover",
    content: "An Interactive HPC session gives you dedicated access to one or more nodes on the cluster. This is similar to an interactive batch session with an accessible desktop on the primary node. Use this for heavyweight jobs such as long-running compute tasks or where you need dedicated resources.",
    title: function(){ return $(this).text() }
  });

  $('[data-bs-toggle="popover"]').popover({delay: {'show': 0, 'hide': 500}});
  $('[data-bs-toggle="tooltip"]').tooltip();
}

function customizePopoverTriggers() {
  const HIDE_DELAY = 150; // Increased from 50ms to give the mouse time to re-enter

  document.querySelectorAll('[data-bs-toggle="popover"]').forEach(trigger => {
    let hideTimeout;
    let popoverEl = null;
    let triggerHovered = false;  // Manual hover tracking
    let popoverHovered = false;  // Manual hover tracking
    let popoverOpen = false

    const instance = bootstrap.Popover.getOrCreateInstance(trigger, {
      trigger: 'manual'
    });

    const getTip = () =>
      instance.tip || (instance._getTipElement && instance._getTipElement());

    const forceCancel = () => {
      clearTimeout(hideTimeout);
      if (instance._timeout) {
        clearTimeout(instance._timeout);
        instance._timeout = null;
      }
    };

    const show = () => {
      forceCancel();
      if (!popoverOpen) {
        instance.show();
        popoverOpen = true;
      }
    };

    const scheduleHide = () => {
      forceCancel();
      hideTimeout = setTimeout(() => {
        const triggerFocused = trigger.contains(document.activeElement);
        const popoverFocused = popoverEl && popoverEl.contains(document.activeElement);

        if (!triggerHovered && !popoverHovered && !triggerFocused && !popoverFocused) {
          instance.hide();
          popoverOpen = false;
        }
      }, HIDE_DELAY);
    };

    // Trigger events
    trigger.addEventListener('mouseenter', () => {
      triggerHovered = true;
      show();
    });
    trigger.addEventListener('mouseleave', () => {
      triggerHovered = false;
      scheduleHide();
    });
    trigger.addEventListener('focusin', show);
    trigger.addEventListener('focusout', scheduleHide);

    // Popover lifecycle
    trigger.addEventListener('shown.bs.popover', () => {
      popoverEl = getTip();
      if (!popoverEl) return;

      popoverEl.addEventListener('mouseenter', () => {
        popoverHovered = true;
        forceCancel();
      });
      popoverEl.addEventListener('mouseleave', () => {
        popoverHovered = false;
        scheduleHide();
      });
    });

    trigger.addEventListener('hidden.bs.popover', () => {
      popoverEl = null;
      popoverHovered = false; // Reset in case popover is hidden externally
    });
  });
}