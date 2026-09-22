document.addEventListener('DOMContentLoaded', function () {
  var rows = Array.prototype.slice.call(document.querySelectorAll('.post-card--list[data-categories], .post-card--list[data-category]'));
  var years = Array.prototype.slice.call(document.querySelectorAll('.archive-year'));
  var indicator = document.getElementById('archive-active-filter');
  var indicatorName = document.getElementById('archive-active-filter-name');
  if (!rows.length || !indicator) return;

  var params = new URLSearchParams(window.location.search);
  var category = params.get('category');
  if (!category) return;

  var matchedRows = [];
  rows.forEach(function (row) {
    var categories = row.getAttribute('data-categories') || ('|' + (row.getAttribute('data-category') || '') + '|');
    var match = categories.indexOf('|' + category + '|') !== -1;
    row.parentElement.style.display = match ? '' : 'none';
    if (match) matchedRows.push(row);
  });

  years.forEach(function (year) {
    var visibleCount = year.querySelectorAll('.list__item:not([style*="display: none"])').length;
    year.style.display = visibleCount > 0 ? '' : 'none';

    // The year-nav pill count is baked in at build time from ALL posts in
    // that year, so without this it keeps showing the unfiltered total
    // right next to a list that's already been filtered down.
    var navItem = document.querySelector('.archive-year-nav__item[href="#' + year.id + '"]');
    if (navItem) {
      var countEl = navItem.querySelector('.archive-year-nav__count');
      if (countEl) countEl.textContent = visibleCount;
      navItem.style.display = visibleCount > 0 ? '' : 'none';
    }
  });

  // The chip on a matched card carries the category's real display case
  // (e.g. "AI"), while the query param is always lowercased by slugify.
  var displayLabel = category;
  for (var i = 0; i < matchedRows.length; i++) {
    var chip = matchedRows[i].querySelector('.post-card__chip');
    if (chip && chip.textContent.trim()) {
      displayLabel = chip.textContent.trim();
      break;
    }
  }

  indicatorName.textContent = displayLabel;
  indicator.hidden = false;

  // Without this, filtering still shows the generic "Posts" title/tab and
  // "Posts" stays highlighted in the top nav, so the filter reads as
  // "nothing happened" even though the list below did change.
  var pageTitle = document.getElementById('page-title');
  if (pageTitle) pageTitle.textContent = displayLabel;
  if (document.title.indexOf('Posts') === 0) {
    document.title = document.title.replace(/^Posts/, displayLabel);
  }

  var navLinks = Array.prototype.slice.call(document.querySelectorAll('.masthead__menu-item'));
  var matchedNavItem = navLinks.filter(function (item) {
    var link = item.querySelector('a');
    var href = link ? (link.getAttribute('href') || '') : '';
    return href.indexOf('category=' + category) !== -1;
  })[0];
  // Only re-point the active tab when a top-nav item actually targets this
  // category (currently just "AI"); other categories only reachable via
  // /categories/ keep "Posts" highlighted as their nearest parent tab.
  if (matchedNavItem) {
    navLinks.forEach(function (item) {
      item.classList.toggle('is-active', item === matchedNavItem);
    });
  }
});
