// Responsive mobile drawer toggle
const toggle = document.getElementById('menuToggle');
const sidebar = document.querySelector('.sidebar');
toggle?.addEventListener('click', () => {
  const open = sidebar?.classList.toggle('open');
  toggle?.setAttribute('aria-expanded', String(open));
});
document.addEventListener('click', (event) => {
  if (sidebar?.classList.contains('open') && !sidebar.contains(event.target) && event.target !== toggle) {
    sidebar.classList.remove('open');
    toggle?.setAttribute('aria-expanded', 'false');
  }
});

// Modern, Unique, Minimalistic Corporate Desktop Sidebar Minimize / Collapse Controller
(function initSidebarMinimize() {
  const shell = document.getElementById('appShellRoot') || document.querySelector('.app-shell');
  const btnSidebar = document.getElementById('sidebarCollapseBtn');
  const btnTopbar = document.getElementById('topbarSidebarToggle');

  if (!shell) return;

  function setCollapsed(collapsed, save = true) {
    if (collapsed) {
      shell.classList.add('sidebar-collapsed');
      document.documentElement.classList.add('preload-sidebar-collapsed');
      if (btnSidebar) {
        btnSidebar.setAttribute('title', 'Expand Sidebar (Ctrl + B)');
        btnSidebar.setAttribute('aria-expanded', 'false');
      }
      if (btnTopbar) {
        btnTopbar.setAttribute('title', 'Expand Sidebar (Ctrl + B)');
        btnTopbar.setAttribute('aria-expanded', 'false');
      }
      if (save) {
        try { localStorage.setItem('erp_sidebar_collapsed', 'true'); } catch (e) {}
      }
    } else {
      shell.classList.remove('sidebar-collapsed');
      document.documentElement.classList.remove('preload-sidebar-collapsed');
      if (btnSidebar) {
        btnSidebar.setAttribute('title', 'Collapse Sidebar (Ctrl + B)');
        btnSidebar.setAttribute('aria-expanded', 'true');
      }
      if (btnTopbar) {
        btnTopbar.setAttribute('title', 'Collapse Sidebar (Ctrl + B)');
        btnTopbar.setAttribute('aria-expanded', 'true');
      }
      if (save) {
        try { localStorage.setItem('erp_sidebar_collapsed', 'false'); } catch (e) {}
      }
    }
  }

  function toggle() {
    const isCurrentlyCollapsed = shell.classList.contains('sidebar-collapsed') ||
      document.documentElement.classList.contains('preload-sidebar-collapsed');
    setCollapsed(!isCurrentlyCollapsed);
  }

  btnSidebar?.addEventListener('click', (e) => {
    e.preventDefault();
    e.stopPropagation();
    toggle();
  });

  btnTopbar?.addEventListener('click', (e) => {
    e.preventDefault();
    e.stopPropagation();
    toggle();
  });

  // Power-user keyboard shortcut: Ctrl + B or Cmd + B
  document.addEventListener('keydown', (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'b') {
      const activeEl = document.activeElement;
      const tag = activeEl ? activeEl.tagName.toLowerCase() : '';
      if (tag !== 'input' && tag !== 'textarea' && tag !== 'select' && !activeEl?.isContentEditable) {
        e.preventDefault();
        toggle();
      }
    }
  });

  // Initialize state based on persisted preference
  try {
    const saved = localStorage.getItem('erp_sidebar_collapsed');
    if (saved === 'true') {
      setCollapsed(true, false);
    } else {
      setCollapsed(false, false);
    }
  } catch (e) {}
})();

// =========================================================================
// Universal Auto-Search Engine (Instant Live Table Filter across all ERP modules)
// Fires instantly on typing 1 or 2 characters in any search input
// =========================================================================
(function initUniversalLiveSearch() {
  function setupSearchListeners() {
    const selector = [
      'input[name="q"]',
      'input[name="search"]',
      'input[type="search"]',
      'input.table-search',
      '.search-form input',
      'input[placeholder*="Search" i]',
      'input[placeholder*="search" i]',
      'input[placeholder*="Filter" i]',
      'input[placeholder*="খুঁজুন" i]'
    ].join(',');

    const searchInputs = document.querySelectorAll(selector);

    searchInputs.forEach(input => {
      // Don't bind multiple times
      if (input.dataset.liveSearchBound === 'true') return;
      input.dataset.liveSearchBound = 'true';

      // Live search on typing 1, 2 or more characters
      input.addEventListener('input', (e) => {
        const query = e.target.value.trim().toLowerCase();
        handleLiveSearch(input, query);
      });

      // Quick-clear on Escape key
      input.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
          input.value = '';
          handleLiveSearch(input, '');
        } else if (e.key === 'Enter') {
          // If table has live matching rows, prevent full page reload
          const table = findTargetTable(input);
          if (table) {
            e.preventDefault();
            handleLiveSearch(input, input.value.trim().toLowerCase());
          }
        }
      });
    });
  }

  function findTargetTable(input) {
    // 1. Look in closest card / section / container
    const container = input.closest('.card, section, .table-wrap, .master-body, .panel, main') || document;
    let table = container.querySelector('table');
    if (!table) {
      // 2. Look in sibling container
      const parent = input.closest('form, div, .submod-action-bar');
      if (parent && parent.nextElementSibling) {
        table = parent.nextElementSibling.querySelector('table');
      }
    }
    if (!table) {
      // 3. Fallback to any primary table with tbody
      table = document.querySelector('table:not(.layout-table)');
    }
    return table;
  }

  function findTargetCardsGrid(input) {
    const container = input.closest('main, .content, body') || document;
    return container.querySelector('.doctor-grid, .grid-cards, .cards-grid, .package-grid, .services-grid');
  }

  function handleLiveSearch(input, query) {
    // Check if target is a Card Grid (like Doctors Directory, Service Cards, etc.)
    const cardsGrid = findTargetCardsGrid(input);
    if (cardsGrid) {
      const cards = Array.from(cardsGrid.children);
      let matchedCards = 0;
      cards.forEach(card => {
        if (card.classList.contains('empty-state')) return;
        const text = card.innerText.toLowerCase();
        if (!query || text.includes(query)) {
          card.style.display = '';
          matchedCards++;
        } else {
          card.style.display = 'none';
        }
      });
      let emptyCard = cardsGrid.querySelector('.live-search-empty-card');
      if (matchedCards === 0 && query !== '') {
        if (!emptyCard) {
          emptyCard = document.createElement('div');
          emptyCard.className = 'empty-state live-search-empty-card';
          emptyCard.style.gridColumn = '1/-1';
          emptyCard.innerHTML = `<strong>No matching records found</strong><p style="margin:4px 0 0;font-size:12px;color:#64748b;">No cards matching "${input.value}".</p>`;
          cardsGrid.appendChild(emptyCard);
        } else {
          emptyCard.style.display = '';
        }
      } else if (emptyCard) {
        emptyCard.style.display = 'none';
      }
    }

    const table = findTargetTable(input);
    if (!table) return;

    const tbody = table.querySelector('tbody');
    if (!tbody) return;

    const rows = Array.from(tbody.querySelectorAll('tr:not(.live-search-empty-state)'));
    let matchedCount = 0;

    rows.forEach(row => {
      // Ignore statutory summary/total rows with colspan
      if (row.classList.contains('table-total-row') || row.classList.contains('summary-total-row') || (row.querySelector('td[colspan]') && row.innerText.toLowerCase().includes('total'))) {
        return;
      }
      
      const text = row.innerText.toLowerCase();
      if (!query || text.includes(query)) {
        row.style.display = '';
        matchedCount++;
      } else {
        row.style.display = 'none';
      }
    });

    // Handle dynamic empty state message if no rows match
    let emptyRow = tbody.querySelector('.live-search-empty-state');
    if (matchedCount === 0 && query !== '') {
      if (!emptyRow) {
        emptyRow = document.createElement('tr');
        emptyRow.className = 'live-search-empty-state';
        emptyRow.innerHTML = `
          <td colspan="100" style="text-align:center;padding:34px 20px;background:#f8fafc;color:#64748b;border-radius:8px;">
            <div style="font-size:26px;margin-bottom:8px;">🔍</div>
            <strong style="display:block;font-size:14px;color:#0f172a;margin-bottom:4px;">No matching records found</strong>
            <span style="font-size:12px;color:#64748b;">No results matching "${input.value}". Try clearing or changing search keywords.</span>
          </td>
        `;
        tbody.appendChild(emptyRow);
      } else {
        emptyRow.style.display = '';
        const span = emptyRow.querySelector('span');
        if (span) span.textContent = `No results matching "${input.value}". Try clearing or changing search keywords.`;
      }
    } else if (emptyRow) {
      emptyRow.style.display = 'none';
    }

    // Dynamic counter update on section badge/pill if present
    const card = input.closest('.card, section');
    if (card) {
      const pill = card.querySelector('.card-head .pill, .card-head span.badge, .card-head .count-chip');
      if (pill) {
        if (!pill.dataset.originalText) {
          pill.dataset.originalText = pill.textContent;
        }
        pill.textContent = query ? `${matchedCount} matching` : pill.dataset.originalText;
      }
    }
  }

  // Attach on load & dynamic DOM changes
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupSearchListeners);
  } else {
    setupSearchListeners();
  }
})();



// Enterprise Corporate Notification Center Interactivity
(function initNotificationHub() {
  const bellBtn = document.getElementById('topbarBellBtn');
  const panel = document.getElementById('notifDropdownPanel');
  const listContainer = document.getElementById('notifListContainer');
  const bellBadge = document.getElementById('topbarBellBadge');
  const panelBadge = document.getElementById('notifPanelUnreadBadge');
  const btnMarkAll = document.getElementById('btnMarkAllRead');
  const tabs = document.querySelectorAll('.notif-tab');

  if (!bellBtn || !panel) return;

  // Toggle Dropdown
  bellBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    const isHidden = panel.style.display === 'none' || !panel.style.display;
    if (isHidden) {
      panel.style.display = 'flex';
      bellBtn.classList.add('active');
    } else {
      panel.style.display = 'none';
      bellBtn.classList.remove('active');
    }
  });

  // Close when clicking outside
  document.addEventListener('click', (e) => {
    if (!panel.contains(e.target) && !bellBtn.contains(e.target)) {
      panel.style.display = 'none';
      bellBtn.classList.remove('active');
    }
  });

  // Tab Filtering
  tabs.forEach(tab => {
    tab.addEventListener('click', (e) => {
      e.stopPropagation();
      tabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
      const cat = tab.getAttribute('data-tab');
      const items = listContainer?.querySelectorAll('.notif-item') || [];
      items.forEach(item => {
        if (cat === 'all' || item.getAttribute('data-category') === cat) {
          item.style.display = 'flex';
        } else {
          item.style.display = 'none';
        }
      });
    });
  });

  // Mark single item read on click
  listContainer?.addEventListener('click', (e) => {
    const item = e.target.closest('.notif-item');
    if (!item) return;
    const notifId = item.getAttribute('data-id');
    if (item.classList.contains('unread')) {
      item.classList.remove('unread');
      item.classList.add('read');
      const dot = item.querySelector('.unread-dot');
      if (dot) dot.remove();

      // Decrement unread counter
      let unread = parseInt(bellBadge?.textContent || '0', 10);
      unread = Math.max(0, unread - 1);
      updateCounters(unread);

      // Persist via API
      try {
        const formData = new FormData();
        if (notifId) formData.append('id', notifId);
        fetch('/api/v1/notifications/read', {
          method: 'POST',
          body: formData
        }).catch(() => {});
      } catch (err) {}
    }
  });

  // Mark all read button
  btnMarkAll?.addEventListener('click', (e) => {
    e.stopPropagation();
    const unreadItems = listContainer?.querySelectorAll('.notif-item.unread') || [];
    unreadItems.forEach(item => {
      item.classList.remove('unread');
      item.classList.add('read');
      const dot = item.querySelector('.unread-dot');
      if (dot) dot.remove();
    });

    updateCounters(0);

    // Persist via API
    try {
      fetch('/api/v1/notifications/read', {
        method: 'POST'
      }).catch(() => {});
    } catch (err) {}
  });

  function updateCounters(unreadCount) {
    if (bellBadge) {
      bellBadge.textContent = unreadCount > 99 ? '99+' : unreadCount;
      bellBadge.style.display = unreadCount > 0 ? 'flex' : 'none';
    }
    const ping = bellBtn.querySelector('.bell-radar-ping');
    if (ping) {
      ping.style.display = unreadCount > 0 ? 'block' : 'none';
    }
    if (panelBadge) {
      panelBadge.textContent = `${unreadCount} New`;
      panelBadge.style.display = unreadCount > 0 ? 'inline-block' : 'none';
    }
  }

  // Periodic Polling every 45s for fresh real-time notification sync
  setInterval(() => {
    fetch('/api/v1/notifications')
      .then(res => res.json())
      .then(json => {
        if (json?.status === 'success' && json.data) {
          updateCounters(json.data.unread_count || 0);
        }
      })
      .catch(() => {});
  }, 45000);
})();
