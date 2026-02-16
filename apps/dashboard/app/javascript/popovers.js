import * as BS from 'bootstrap';
import { Exception } from 'sass';

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
  const HIDE_DELAY = 50;

  document.querySelectorAll('[data-bs-toggle="popover"]').forEach(trigger => {
    let hideTimeout;
    let popoverEl = null;

    // Force manual control (kills Bootstrap hover logic)
    const instance = bootstrap.Popover.getOrCreateInstance(trigger, {
      trigger: 'manual'
    });

    const getTip = () =>
      instance.tip || (instance._getTipElement && instance._getTipElement());

    const forceCancel = () => {
      clearTimeout(hideTimeout);

      // Cancel Bootstrap internal timers if present
      if (instance._timeout) {
        clearTimeout(instance._timeout);
        instance._timeout = null;
      }
    };

    const show = () => {
      forceCancel();
      instance.show();
    };

    const scheduleHide = () => {
      forceCancel();

      hideTimeout = setTimeout(() => {
        const triggerHovered = trigger.matches(':hover');
        const popoverHovered = popoverEl && popoverEl.matches(':hover');

        const triggerFocused = trigger.contains(document.activeElement);
        const popoverFocused =
          popoverEl && popoverEl.contains(document.activeElement);

        if (
          !triggerHovered &&
          !popoverHovered &&
          !triggerFocused &&
          !popoverFocused
        ) {
          instance.hide();
        }
      }, HIDE_DELAY);
    };

    // Trigger events
    trigger.addEventListener('mouseenter', show);
    trigger.addEventListener('mouseleave', scheduleHide);
    trigger.addEventListener('focusin', show);
    trigger.addEventListener('focusout', scheduleHide);

    // Popover lifecycle
    trigger.addEventListener('shown.bs.popover', () => {
      popoverEl = getTip();

      if (!popoverEl) return;

      popoverEl.addEventListener('mouseenter', forceCancel);
      popoverEl.addEventListener('mouseleave', scheduleHide);
    });

    trigger.addEventListener('hidden.bs.popover', () => {
      popoverEl = null;
    });
  });
}







