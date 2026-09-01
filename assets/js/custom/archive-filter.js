document.addEventListener('DOMContentLoaded', function () {
  var rows = Array.prototype.slice.call(document.querySelectorAll('.post-card--list[data-categories], .post-card--list[data-category]'));
  var years = Array.prototype.slice.call(document.querySelectorAll('.archive-year'));
  var indicator = document.getElementById('archive-active-filter');
  var indicatorName = document.getElementById('archive-active-filter-name');
  if (!rows.length || !indicator) return;

  var params = new URLSearchParams(window.location.search);
  var category = params.get('category');
  if (!category) return;

  rows.forEach(function (row) {
    var categories = row.getAttribute('data-categories') || ('|' + (row.getAttribute('data-category') || '') + '|');
    var match = categories.indexOf('|' + category + '|') !== -1;
    row.parentElement.style.display = match ? '' : 'none';
  });

  years.forEach(function (year) {
    var visible = year.querySelectorAll('.list__item:not([style*="display: none"])').length > 0;
    year.style.display = visible ? '' : 'none';
  });

  indicatorName.textContent = category;
  indicator.hidden = false;
});
