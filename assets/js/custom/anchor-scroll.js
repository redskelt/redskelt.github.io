// 같은 페이지 안의 '#' 링크(목차 · 각주 · 연도 링크 등) 이동을 맡는다.
//
// 테마(remote_theme minimal-mistakes 4.24.0)의 main.min.js 는
// new SmoothScroll('a[href*="#"]', { offset: 20 }) 로 이런 클릭을 가로채 직접 스크롤하는데,
// 고정 offset 20px 이라 sticky masthead(64px) 아래에 소제목이 깔리고 CSS 의
// scroll-padding-top 도 무시한다. 그래서 window 캡처 단계에서 먼저 받아 테마 핸들러
// (document, 버블 단계)까지 가지 않게 하고, scroll-padding-top 을 지키는 scrollIntoView 로
// 이동한다. 오프셋 값은 _sass/custom/_masthead-terminal.scss 의 --masthead-height 하나가 정한다.
(function () {
  window.addEventListener("click", function (event) {
    if (event.defaultPrevented || event.button !== 0) return;
    if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;

    var link = event.target.closest && event.target.closest("a[href*='#']");
    if (!link || link.target === "_blank") return;
    if (link.origin !== location.origin || link.pathname !== location.pathname) return;
    if (!link.hash || link.hash === "#") return;

    var target = document.getElementById(decodeURIComponent(link.hash.slice(1)));
    if (!target) return;

    event.preventDefault();
    event.stopPropagation();

    if (location.hash !== link.hash) history.pushState(null, "", link.hash);
    scrollToTarget(target);
  }, true);

  function targetY(target) {
    var padding = parseFloat(getComputedStyle(document.documentElement).scrollPaddingTop) || 0;
    var max = document.documentElement.scrollHeight - window.innerHeight;
    return Math.max(0, Math.min(max, target.getBoundingClientRect().top + window.scrollY - padding));
  }

  // 브라우저 기본 smooth 는 거리에 비례해 2~3초까지 걸린다. 테마(speed 400, 최대 500ms)처럼
  // 짧게 끝낸다. 움직임 줄이기 설정이면 바로 이동한다.
  // 지나가는 동안 lazy 이미지가 로드되면 대상이 밀리므로, 매 프레임 목표를 다시 계산하고
  // 끝난 뒤에도 잠깐(SETTLE) 위치가 어긋나면 바로잡는다. 사용자가 직접 스크롤하면 멈춘다.
  var DURATION = 400;
  var SETTLE = 1000;
  function scrollToTarget(target) {
    var from = window.scrollY;
    var reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    var cancelled = false;
    function cancel() { cancelled = true; }
    var opts = { passive: true, once: true };
    window.addEventListener("wheel", cancel, opts);
    window.addEventListener("touchstart", cancel, opts);
    window.addEventListener("keydown", cancel, opts);
    var start = null;
    function step(now) {
      if (cancelled) return;
      if (start === null) start = now;
      var elapsed = now - start;
      var p = reduce ? 1 : Math.min(1, elapsed / DURATION);
      var eased = p < 0.5 ? 2 * p * p : 1 - Math.pow(-2 * p + 2, 2) / 2;
      var to = targetY(target);
      var y = from + (to - from) * eased;
      if (Math.abs(window.scrollY - y) >= 1) window.scrollTo(0, y);
      if (elapsed < DURATION + SETTLE) {
        window.requestAnimationFrame(step);
      } else {
        window.removeEventListener("wheel", cancel);
        window.removeEventListener("touchstart", cancel);
        window.removeEventListener("keydown", cancel);
      }
    }
    window.requestAnimationFrame(step);
  }
})();
