// image zoom: click a post-body image to open it full-screen, Esc/click to close
(function () {
  var overlay = null;

  function buildOverlay() {
    var el = document.createElement('div');
    el.className = 'image-zoom-overlay';
    el.innerHTML =
      '<button type="button" class="image-zoom-overlay__close" aria-label="닫기">&times;</button>' +
      '<img class="image-zoom-overlay__img" alt="">' +
      '<div class="image-zoom-overlay__caption"></div>';
    document.body.appendChild(el);
    return el;
  }

  function fitToViewport(target) {
    var naturalW = target.naturalWidth;
    var naturalH = target.naturalHeight;
    if (!naturalW || !naturalH) return;
    var maxW = window.innerWidth * 0.9;
    var maxH = window.innerHeight * 0.85;
    var scale = Math.min(maxW / naturalW, maxH / naturalH);
    target.style.width = Math.round(naturalW * scale) + 'px';
    target.style.height = Math.round(naturalH * scale) + 'px';
  }

  function openOverlay(img) {
    if (!overlay) overlay = buildOverlay();
    var target = overlay.querySelector('.image-zoom-overlay__img');
    var caption = overlay.querySelector('.image-zoom-overlay__caption');
    target.style.width = '';
    target.style.height = '';
    target.src = img.currentSrc || img.src;
    target.alt = img.alt || '';
    caption.textContent = img.alt || '';
    if (target.complete && target.naturalWidth) {
      fitToViewport(target);
    } else {
      target.onload = function () { fitToViewport(target); };
    }
    overlay.classList.add('is--visible');
    document.documentElement.classList.add('image-zoom-lock');
    document.body.classList.add('image-zoom-lock');
  }

  function closeOverlay() {
    if (overlay) overlay.classList.remove('is--visible');
    document.documentElement.classList.remove('image-zoom-lock');
    document.body.classList.remove('image-zoom-lock');
  }

  document.addEventListener('DOMContentLoaded', function () {
    var content = document.querySelector('.page__content');
    if (!content) return;

    content.addEventListener('click', function (e) {
      var img = e.target.closest('img');
      if (!img || !content.contains(img)) return;
      if (img.closest('a')) return; // don't hijack linked images
      e.preventDefault();
      openOverlay(img);
    });

    document.addEventListener('click', function (e) {
      if (!overlay || !overlay.classList.contains('is--visible')) return;
      if (e.target === overlay || e.target.classList.contains('image-zoom-overlay__close')) {
        closeOverlay();
      }
    });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') closeOverlay();
    });

    window.addEventListener('resize', function () {
      if (!overlay || !overlay.classList.contains('is--visible')) return;
      fitToViewport(overlay.querySelector('.image-zoom-overlay__img'));
    });
  });
})();
