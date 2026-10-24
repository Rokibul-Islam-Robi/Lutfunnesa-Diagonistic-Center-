/* ==========================================================
   LUTFOR NETURE DIABETES AND DRIGNISC CENTER — HOMEPAGE
   Vanilla JavaScript (no frameworks)
   ----------------------------------------------------------
   01. THEME SWITCHER (presets, custom color, persistence)
   02. NAVBAR (stuck state, mobile collapse)
   03. APPOINTMENT FORM (validation + success toast)
   04. ANIMATED STATISTICS COUNTERS
   05. SCROLL REVEAL
   06. BACK TO TOP
   07. CARD SLIDER (Departments / Doctors)
   ========================================================== */
(function () {
  'use strict';

  /* ----------------------------------------------------------
     01. THEME SWITCHER
     ---------------------------------------------------------- */
  var STORAGE_THEME = 'selectedTheme';
  var STORAGE_STYLES = 'selectedThemeStyles';

  var themes = {
    green: {
      primary: '#087f5b',
      secondary: '#0b9b72',
      accent: '#f4b400'
    },
    blue: {
      primary: '#1565c0',
      secondary: '#1e88e5',
      accent: '#ffc107'
    },
    purple: {
      primary: '#6a1b9a',
      secondary: '#8e24aa',
      accent: '#ffb300'
    },
    red: {
      primary: '#c62828',
      secondary: '#e53935',
      accent: '#ffb300'
    },
    orange: {
      primary: '#ef6c00',
      secondary: '#fb8c00',
      accent: '#00897b'
    }
  };

  function hexToRgb(hex) {
    var h = hex.replace('#', '');
    if (h.length === 3) {
      h = h[0] + h[0] + h[1] + h[1] + h[2] + h[2];
    }
    var n = parseInt(h, 16);
    return [(n >> 16) & 255, (n >> 8) & 255, n & 255];
  }

  function rgbToHex(r, g, b) {
    function c(v) {
      var s = Math.max(0, Math.min(255, Math.round(v))).toString(16);
      return s.length === 1 ? '0' + s : s;
    }
    return '#' + c(r) + c(g) + c(b);
  }

  /* Mix a hex color toward white (0 = unchanged, 1 = white) */
  function lighten(hex, amount) {
    var rgb = hexToRgb(hex);
    return rgbToHex(
      rgb[0] + (255 - rgb[0]) * amount,
      rgb[1] + (255 - rgb[1]) * amount,
      rgb[2] + (255 - rgb[2]) * amount
    );
  }

  function buildStyles(primary, secondary, accent) {
    var p = hexToRgb(primary);
    var s = hexToRgb(secondary);
    var a = hexToRgb(accent);
    return {
      '--primary-color': primary,
      '--secondary-color': secondary,
      '--accent-color': accent,
      '--primary-rgb': p[0] + ', ' + p[1] + ', ' + p[2],
      '--secondary-rgb': s[0] + ', ' + s[1] + ', ' + s[2],
      '--accent-rgb': a[0] + ', ' + a[1] + ', ' + a[2]
    };
  }

  function applyStyles(styles) {
    var root = document.documentElement;
    for (var key in styles) {
      if (Object.prototype.hasOwnProperty.call(styles, key)) {
        root.style.setProperty(key, styles[key]);
      }
    }
  }

  function saveTheme(name, styles) {
    try {
      localStorage.setItem(STORAGE_THEME, name);
      localStorage.setItem(STORAGE_STYLES, JSON.stringify(styles));
    } catch (e) { /* storage unavailable (private mode) */ }
  }

  var swatches = document.querySelectorAll('.theme-swatch');
  var colorPicker = document.getElementById('themeColorPicker');

  function syncSwatchStates(name) {
    swatches.forEach(function (sw) {
      sw.classList.toggle('is-active', sw.getAttribute('data-theme') === name);
    });
  }

  function setTheme(name) {
    var t = themes[name];
    if (!t) return;
    var styles = buildStyles(t.primary, t.secondary, t.accent);
    applyStyles(styles);
    saveTheme(name, styles);
    syncSwatchStates(name);
    if (colorPicker) colorPicker.value = t.primary;
  }

  function setCustomColor(hex) {
    if (!/^#([0-9a-f]{3}|[0-9a-f]{6})$/i.test(hex)) return;
    var accentEl = document.querySelector('.theme-swatch.is-active');
    var accent = '#f4b400';
    if (accentEl && accentEl.getAttribute('data-theme') !== 'custom') {
      accent = themes[accentEl.getAttribute('data-theme')].accent;
    } else if (colorPicker) {
      accent = getComputedStyle(document.documentElement)
        .getPropertyValue('--accent-color').trim() || accent;
    }
    var styles = buildStyles(hex, lighten(hex, 0.22), accent);
    applyStyles(styles);
    saveTheme('custom', styles);
    syncSwatchStates('custom');
  }

  /* Restore saved state / sync UI after DOM ready */
  function initTheme() {
    var saved = null;
    try { saved = localStorage.getItem(STORAGE_THEME); } catch (e) { /* noop */ }

    if (saved && themes[saved]) {
      setTheme(saved);
    } else {
      /* Styles were already applied by the head script — just sync UI */
      if (colorPicker) {
        var current = getComputedStyle(document.documentElement)
          .getPropertyValue('--primary-color').trim();
        if (current) colorPicker.value = /^#/.test(current) ? current : '#087f5b';
      }
      syncSwatchStates(saved === 'custom' ? 'custom' : 'green');
    }

    swatches.forEach(function (sw) {
      sw.addEventListener('click', function () {
        setTheme(sw.getAttribute('data-theme'));
      });
    });

    if (colorPicker) {
      colorPicker.addEventListener('input', function () {
        setCustomColor(colorPicker.value);
      });
    }

    /* Panel open / close */
    var switcher = document.getElementById('themeSwitcher');
    var toggle = document.getElementById('themeToggle');
    if (switcher && toggle) {
      toggle.addEventListener('click', function (e) {
        e.stopPropagation();
        var open = switcher.classList.toggle('is-open');
        toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      });

      document.addEventListener('click', function (e) {
        if (!switcher.contains(e.target)) {
          switcher.classList.remove('is-open');
          toggle.setAttribute('aria-expanded', 'false');
        }
      });

      document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
          switcher.classList.remove('is-open');
          toggle.setAttribute('aria-expanded', 'false');
        }
      });
    }
  }

  /* ----------------------------------------------------------
     02. NAVBAR
     ---------------------------------------------------------- */
  function initNavbar() {
    var navbar = document.getElementById('siteNavbar');
    if (!navbar) return;

    var onScroll = function () {
      navbar.classList.toggle('is-stuck', window.scrollY > 60);
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();

    /* ----------------------------------------------------------
       Mobile panel: close only after tapping a real link.
       Dropdown parents (.dropdown-toggle) are excluded so the
       panel stays open while the submenu toggles inside it.
       ---------------------------------------------------------- */
    var collapseEl = document.getElementById('mainNav');
    if (collapseEl && window.bootstrap) {
      var collapse = bootstrap.Collapse.getOrCreateInstance(collapseEl, { toggle: false });

      var closeSelectors = 'a.nav-link:not(.dropdown-toggle), a.dropdown-item, a.btn--book';
      collapseEl.querySelectorAll(closeSelectors).forEach(function (link) {
        link.addEventListener('click', function () {
          if (collapseEl.classList.contains('show')) collapse.hide();
        });
      });

      /* Reset any submenu left open when the panel closes */
      var hideOpenDropdowns = function (root) {
        (root || collapseEl).querySelectorAll('.dropdown-menu.show').forEach(function (menu) {
          var toggle = menu.parentElement && menu.parentElement.querySelector('[data-bs-toggle="dropdown"]');
          var instance = toggle && bootstrap.Dropdown.getInstance(toggle);
          if (instance) instance.hide();
          else menu.classList.remove('show');
        });
      };

      collapseEl.addEventListener('hidden.bs.collapse', function () {
        hideOpenDropdowns();
      });
      collapseEl.addEventListener('hide.bs.collapse', function () {
        hideOpenDropdowns();
      });

      /* Leaving mobile width: clear inline submenu state */
      var desktopMq = window.matchMedia('(min-width: 992px)');
      var onBreakpoint = function () {
        if (desktopMq.matches) hideOpenDropdowns();
      };
      if (desktopMq.addEventListener) desktopMq.addEventListener('change', onBreakpoint);
      else if (desktopMq.addListener) desktopMq.addListener(onBreakpoint);
    }

    initDropdownHover();
  }

  /* ----------------------------------------------------------
     02b. DESKTOP HOVER DROPDOWN
     Opens a nav submenu while hovering on desktop (≥992px)
     pointer devices only — click behaviour stays untouched.
     ---------------------------------------------------------- */
  function initDropdownHover() {
    if (!window.bootstrap) return;

    var widthMq = window.matchMedia('(min-width: 992px)');
    var hoverMq = window.matchMedia('(hover: hover) and (pointer: fine)');

    var enabled = function () {
      return widthMq.matches && hoverMq.matches;
    };

    var hideTimer = null;

    var cancelHide = function () {
      if (hideTimer) {
        clearTimeout(hideTimer);
        hideTimer = null;
      }
    };

    document.querySelectorAll('#siteNavbar li.nav-item.dropdown').forEach(function (item) {
      var toggle = item.querySelector('[data-bs-toggle="dropdown"]');
      if (!toggle) return;

      var menu = item.querySelector('.dropdown-menu');
      if (!menu) return;

      var hovering = false;

      var show = function () {
        if (!enabled()) return;
        cancelHide();
        var current = document.querySelector('#siteNavbar .dropdown-menu.show');
        if (current && current !== menu) {
          var currentToggle = current.parentElement &&
            current.parentElement.querySelector('[data-bs-toggle="dropdown"]');
          var currentInstance = currentToggle &&
            bootstrap.Dropdown.getInstance(currentToggle);
          if (currentInstance) currentInstance.hide();
        }
        bootstrap.Dropdown.getOrCreateInstance(toggle).show();
      };

      var scheduleHide = function () {
        cancelHide();
        hideTimer = setTimeout(function () {
          hideTimer = null;
          if (!enabled()) return;
          var instance = bootstrap.Dropdown.getInstance(toggle);
          if (instance) instance.hide();
        }, 120);
      };

      item.addEventListener('mouseenter', function () {
        hovering = true;
        show();
      });
      item.addEventListener('mouseleave', function () {
        hovering = false;
        scheduleHide();
      });
      item.addEventListener('focusin', function () {
        if (enabled()) cancelHide();
      });
      item.addEventListener('focusout', function () {
        if (!hovering) scheduleHide();
      });
    });
  }

  /* ----------------------------------------------------------
     03. APPOINTMENT FORM
     ---------------------------------------------------------- */
  function initAppointmentForm() {
    var form = document.getElementById('appointmentForm');
    if (!form) return;

    /* Date can never be in the past */
    var dateField = document.getElementById('apptDate');
    if (dateField) {
      var today = new Date();
      var iso =
        today.getFullYear() + '-' +
        String(today.getMonth() + 1).padStart(2, '0') + '-' +
        String(today.getDate()).padStart(2, '0');
      dateField.min = iso;
    }

    var phoneRe = /^\+?[0-9][0-9\s\-()]{6,19}$/;

    function isFieldValid(field) {
      if (field.id === 'apptPhone') {
        return phoneRe.test(field.value.trim());
      }
      if (field.id === 'apptDate' && field.value) {
        return field.value >= (field.min || '');
      }
      return field.checkValidity();
    }

    function markField(field) {
      var valid = isFieldValid(field);
      field.classList.toggle('is-invalid', !valid);
      if (valid) field.classList.remove('is-valid');
      return valid;
    }

    var fields = form.querySelectorAll('input[required], select[required]');

    fields.forEach(function (field) {
      var evt = field.tagName === 'SELECT' ? 'change' : 'input';
      field.addEventListener(evt, function () {
        if (field.classList.contains('is-invalid')) markField(field);
      });
    });

    form.addEventListener('submit', function (e) {
      e.preventDefault();

      var firstInvalid = null;
      fields.forEach(function (field) {
        if (!markField(field) && !firstInvalid) firstInvalid = field;
      });

      if (firstInvalid) {
        firstInvalid.focus({ preventScroll: false });
        return;
      }

      /* Success — show toast, reset form */
      var toastEl = document.getElementById('appointmentToast');
      if (toastEl && window.bootstrap) {
        var toast = bootstrap.Toast.getOrCreateInstance(toastEl, { delay: 6000 });
        toast.show();
      }

      form.reset();
      fields.forEach(function (field) {
        field.classList.remove('is-invalid', 'is-valid');
      });
    });
  }

  /* ----------------------------------------------------------
     04. ANIMATED STATISTICS COUNTERS
     ---------------------------------------------------------- */
  function animateCounter(el) {
    var target = parseInt(el.getAttribute('data-count'), 10);
    if (isNaN(target)) return;

    var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduced || !('requestAnimationFrame' in window)) {
      el.textContent = target.toLocaleString('en-US');
      return;
    }

    var duration = 1800;
    var start = null;

    function step(ts) {
      if (start === null) start = ts;
      var progress = Math.min((ts - start) / duration, 1);
      var eased = 1 - Math.pow(1 - progress, 3); /* easeOutCubic */
      el.textContent = Math.round(target * eased).toLocaleString('en-US');
      if (progress < 1) {
        requestAnimationFrame(step);
      } else {
        el.textContent = target.toLocaleString('en-US');
      }
    }

    el.textContent = '0';
    requestAnimationFrame(step);
  }

  function initCounters() {
    var counters = document.querySelectorAll('[data-count]');
    if (!counters.length) return;

    if (!('IntersectionObserver' in window)) {
      counters.forEach(animateCounter);
      return;
    }

    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          animateCounter(entry.target);
          observer.unobserve(entry.target); /* run once */
        }
      });
    }, { threshold: 0.4 });

    counters.forEach(function (el) { observer.observe(el); });
  }

  /* ----------------------------------------------------------
     05. SCROLL REVEAL
     ---------------------------------------------------------- */
  function initReveal() {
    var items = document.querySelectorAll('.reveal');
    if (!items.length) return;

    var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    if (reduced || !('IntersectionObserver' in window)) {
      items.forEach(function (el) { el.classList.add('is-visible'); });
      return;
    }

    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.15, rootMargin: '0px 0px -40px 0px' });

    items.forEach(function (el) { observer.observe(el); });
  }

  /* ----------------------------------------------------------
     06. BACK TO TOP
     ---------------------------------------------------------- */
  function initBackToTop() {
    var btn = document.getElementById('backToTop');
    if (!btn) return;

    var onScroll = function () {
      btn.classList.toggle('is-visible', window.scrollY > 450);
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();

    btn.addEventListener('click', function () {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  /* ----------------------------------------------------------
     07. CARD SLIDER (Departments / Doctors)
     Shows `perView` cards, auto-advances one card at a time.
     The first `perView` slides are cloned at the end so the
     loop can wrap back to the start without a visible jump.
     ---------------------------------------------------------- */
  function initCardSliders() {
    var roots = document.querySelectorAll('[data-slider]');
    if (!roots.length) return;

    var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    function perView() {
      var w = window.innerWidth;
      if (w >= 992) return 4;
      if (w >= 768) return 2;
      return 1;
    }

    roots.forEach(function (root) {
      var track = root.querySelector('.card-slider__track');
      var prevBtn = root.querySelector('.card-slider__btn--prev');
      var nextBtn = root.querySelector('.card-slider__btn--next');
      if (!track) return;

      var originals = Array.prototype.slice.call(track.children);
      var count = originals.length;
      var interval = parseInt(root.getAttribute('data-interval'), 10) || 3000;
      var views = perView();
      var index = 0;
      var timer = null;
      var wrapTimer = null;
      var paused = false;
      var inView = !('IntersectionObserver' in window);

      function syncButtons() {
        var off = count <= views;
        if (prevBtn) prevBtn.hidden = off;
        if (nextBtn) nextBtn.hidden = off;
      }

      function buildClones() {
        Array.prototype.slice.call(track.querySelectorAll('[data-clone]'))
          .forEach(function (node) { node.parentNode.removeChild(node); });

        views = perView();
        if (count <= views) return;

        for (var i = 0; i < views; i++) {
          var clone = originals[i].cloneNode(true);
          clone.setAttribute('data-clone', 'true');
          clone.setAttribute('aria-hidden', 'true');
          track.appendChild(clone);
        }
      }

      function stepSize() {
        if (track.children.length < 2) return 0;
        return track.children[1].offsetLeft - track.children[0].offsetLeft;
      }

      function paint(animate) {
        if (!animate) track.style.transition = 'none';
        track.style.transform = 'translate3d(' + (-index * stepSize()) + 'px, 0, 0)';
        if (!animate) {
          void track.offsetHeight; /* force reflow before restoring the transition */
          track.style.transition = '';
        }
      }

      function stopAuto() {
        clearInterval(timer);
        timer = null;
      }

      function startAuto() {
        if (reduced || paused || !inView || count <= views) return;
        stopAuto();
        timer = setInterval(next, interval);
      }

      function restartAuto() {
        stopAuto();
        startAuto();
      }

      function pauseAuto() {
        paused = true;
        stopAuto();
      }

      function resumeAuto() {
        paused = false;
        startAuto();
      }

      function next() {
        if (count <= views) return;
        clearTimeout(wrapTimer);
        index += 1;
        paint(true);
        if (index >= count) {
          /* the visible window is now the cloned first one - snap back */
          wrapTimer = setTimeout(function () {
            index = 0;
            paint(false);
          }, 650);
        }
      }

      function prev() {
        if (count <= views) return;
        clearTimeout(wrapTimer);
        if (index === 0) {
          index = count; /* clone position identical to index 0 */
          paint(false);
          index = count - 1;
          requestAnimationFrame(function () {
            requestAnimationFrame(function () { paint(true); });
          });
        } else {
          index -= 1;
          paint(true);
        }
      }

      buildClones();
      syncButtons();
      paint(false);

      root.addEventListener('mouseenter', pauseAuto);
      root.addEventListener('mouseleave', resumeAuto);
      root.addEventListener('focusin', pauseAuto);
      root.addEventListener('focusout', function (e) {
        if (!root.contains(e.relatedTarget)) resumeAuto();
      });

      if (prevBtn) {
        prevBtn.addEventListener('click', function () {
          prev();
          restartAuto();
        });
      }

      if (nextBtn) {
        nextBtn.addEventListener('click', function () {
          next();
          restartAuto();
        });
      }

      if ('IntersectionObserver' in window) {
        var observer = new IntersectionObserver(function (entries) {
          entries.forEach(function (entry) {
            inView = entry.isIntersecting;
            if (inView) startAuto();
            else stopAuto();
          });
        }, { threshold: 0.2 });
        observer.observe(root);
      }

      var resizeTimer = null;
      window.addEventListener('resize', function () {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function () {
          clearTimeout(wrapTimer);
          stopAuto();
          buildClones();
          syncButtons();
          if (index > count) index = 0;
          paint(false);
          startAuto();
        }, 150);
      });

      startAuto();
    });
  }

  /* ----------------------------------------------------------
     INIT
     ---------------------------------------------------------- */
  function init() {
    initTheme();
    initNavbar();
    initAppointmentForm();
    initCounters();
    initReveal();
    initBackToTop();
    initCardSliders();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
