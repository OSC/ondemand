# Accessibility checks to be performed on every page visit.
class ActiveSupport::TestCase
  CONTRAST_WATCH_SCRIPT = <<~HEREDOC
    function getLuminance(r, g, b) {
      const [rs, gs, bs] = [r, g, b].map(c => {
        c /= 255;
        return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
      });
      return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
    }

    function parse(color) {
      const inner = color.replace('rgb(', '').replace(')', '');
      values = inner.split(', ');
      return values;
    }

    function getContrastRatio(color1, color2) {
      const [r1,g1,b1] = parse(color1);
      const [r2,g2,b2] = parse(color2);
      const l1 = getLuminance(r1,g1,b1);
      const l2 = getLuminance(r2,g2,b2);
      const lighter = Math.max(l1, l2);
      const darker  = Math.min(l1, l2);
      return (lighter + 0.05) / (darker + 0.05);
    }

    function isVisible(el) {
      const style = window.getComputedStyle(el);
      return style.display !== 'none'
        && style.visibility !== 'hidden'
        && style.opacity !== '0'
        && el.offsetWidth > 0;
    }

    function hasText(el){
      var textFound = false;
      el.childNodes.forEach((ch) => {
        if (ch.nodeType === 3) {
          if (ch.textContent.trim() !== '') {
            textFound = true;
          }
        }
      });
      return textFound;
    }

    function getEffectiveBackground(el) {
      const style = window.getComputedStyle(el);
      const shadow = style.boxShadow;
    
      if (shadow && shadow !== 'none' && shadow.includes('9999px')) {
        const colorMatch = shadow.match(/rgba?\([^)]+\)/);
        if (colorMatch) return colorMatch[0];
      }
    
      return style.backgroundColor;
    }

    function ascendForBackground(el){
      const style = window.getComputedStyle(el);

      // ascend tree to get first defined background
      var current = el;
      var bg = getEffectiveBackground(el);
      while (bg === 'rgba(0, 0, 0, 0)') {
        let parent = current.parentElement;
        if (!parent) { // assume white if no background found
          bg = 'rgb(255, 255, 255)';
        } else {
          if (parent.hasAttribute('disabled')) return;
          
          bg = getEffectiveBackground(parent);
          current = parent;
        }
      }
      return bg;
    }

    function checkElement(el) {
      if (el.nodeType !== Node.ELEMENT_NODE) return;

      if (!isVisible(el) || !hasText(el) || el.classList.contains('sr-only') || el.classList.contains('visually-hidden')) return;

      const style = window.getComputedStyle(el);
      const fg = style.color;
      var bg = ascendForBackground(el)
      if (!fg || !bg) return;

  
      const ratio = getContrastRatio(fg, bg);
      const fontSize = parseFloat(style.fontSize);
      const isBold = parseInt(style.fontWeight) >= 700;
      // WCAG AA: 4.5:1 normal, 3:1 large (18pt / 14pt bold)
      const isLargeText = fontSize >= 24 || (isBold && fontSize >= 18.67);
      const required = isLargeText ? 3.0 : 4.5;
      if (ratio < required) {
        const contrastViolation = {
          tag: el.tagName,
          text: el.innerText?.slice(0, 50),
          fg, bg,
          ratio: Math.round(ratio * 100) / 100,
          required,
          path: el.closest('[id]')?.id || el.className
        };
        throw `Contrast check failed. Failing element: ${JSON.stringify(contrastViolation)}`;
      }
    }

    function checkTree(root) {
      try {
        checkElement(root);
        if (root.nodeType === 1) {
          root.querySelectorAll('*').forEach(element => checkElement(element));
        }
      } catch (error) {
        throw `Failed checkTree on element '${root}' with error ${error}`;
      }
    }
      
    // Inject style tag to remove transitions
    if (!window.__styleTag) {
      window.__styleTag = document.createElement('style');
      document.head.appendChild(window.__styleTag);
    }
    
    if (!window.__changedElements) {
      window.__changedElements = [];
      const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
          mutation.addedNodes.forEach(node => window.__changedElements.push(node));
          if (mutation.type === 'attributes' && isVisible(mutation.target)) {
            window.__changedElements.push(mutation.target)
          }
        });
      });
      observer.observe(document.body, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ['style', 'class', 'hidden', 'aria-hidden']
      });

      // Scan whatever's already on the page if first run
      checkTree(document.body);
    } else {
      if (window.__changedElements.length > 0) {
        window.__styleTag.textContent = '* { transition: none !important; }';
        // subsequent runs only check changed elements
        window.__changedElements.forEach(node => checkTree(node))
        window.__changedElements = [];
        window.__styleTag.textContent = '';
      }
    }
  HEREDOC

  def inject_contrast_observer
    page.execute_script(CONTRAST_WATCH_SCRIPT)
  end
end

