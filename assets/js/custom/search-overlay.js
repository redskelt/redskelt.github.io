document.addEventListener('DOMContentLoaded', function () {
  var searchInput = document.getElementById('search');
  var resultsEl = document.getElementById('results');
  var scrim = document.querySelector('.search-content');
  if (!searchInput || !resultsEl || typeof lunr === 'undefined') return;

  // lunr's default trimmer strips every non-ASCII character, which erased Hangul tokens entirely.
  // Splitting on anything that is not a letter or digit keeps them and still separates "(Docker,".
  lunr.tokenizer.separator = /[^\p{L}\p{N}]+/u;

  // The store holds every post's full text (search_full_content), so it loads on first search, not on every page.
  var storeLoad = null;
  function loadStore() {
    if (!storeLoad) {
      storeLoad = new Promise(function (resolve, reject) {
        var script = document.createElement('script');
        script.src = searchInput.dataset.store;
        script.onload = resolve;
        script.onerror = function () {
          storeLoad = null;
          script.remove();
          reject();
        };
        document.head.appendChild(script);
      });
    }
    return storeLoad;
  }

  var idx = null;
  function buildIndex() {
    return lunr(function () {
      this.pipeline.remove(lunr.trimmer);
      this.ref('id');
      this.field('title', { boost: 10 });
      this.field('categories');
      this.field('excerpt');

      store.forEach(function (doc, i) {
        this.add({
          id: i,
          title: doc.title,
          categories: (doc.categories || []).join(' '),
          excerpt: doc.excerpt
        });
      }, this);
    });
  }

  function renderResults(list) {
    resultsEl.innerHTML = '';
    if (!list.length) {
      resultsEl.innerHTML = '<p class="search-empty">No results.</p>';
      return;
    }
    var ul = document.createElement('ul');
    ul.className = 'search-results-list';
    list.forEach(function (doc) {
      var category = doc.categories && doc.categories.length ? doc.categories[0] : null;
      var li = document.createElement('li');
      li.innerHTML =
        '<a href="' + doc.url + '">' +
          '<span class="search-results-list__title">' + doc.title + '</span>' +
          (category ? '<span class="search-results-list__chip">' + category + '</span>' : '') +
        '</a>';
      ul.appendChild(li);
    });
    resultsEl.appendChild(ul);
  }

  function search() {
    loadStore().then(function () {
      var query = searchInput.value.trim();
      if (!query) {
        renderResults(store.slice(0, 6));
        return;
      }
      var tokens = lunr.tokenizer(query);
      if (!tokens.length) {
        renderResults([]);
        return;
      }
      idx = idx || buildIndex();
      var matches = idx.query(function (q) {
        tokens.forEach(function (token) {
          q.term(token.toString(), { boost: 10 });
          q.term(token.toString(), { usePipeline: false, wildcard: lunr.Query.wildcard.TRAILING });
        });
      }).map(function (r) { return store[Number(r.ref)]; });
      renderResults(matches);
    }, function () {});
  }

  searchInput.addEventListener('input', search);

  document.querySelectorAll('.search__toggle').forEach(function (btn) {
    btn.addEventListener('click', function () {
      setTimeout(search, 50);
    });
  });

  if (scrim) {
    scrim.addEventListener('click', function (e) {
      if (e.target === scrim) {
        scrim.classList.remove('is--visible');
      }
    });
  }
});
