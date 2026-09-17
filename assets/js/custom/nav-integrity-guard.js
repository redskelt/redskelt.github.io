// greedy-nav(main.min.js)가 폰트 로딩 타이밍과 겹치면 드물게 nav 항목 하나를
// visible-links/hidden-links 어디에도 남기지 않고 그대로 지워버리는 레이스가 있다.
// 항상 완전한 목록을 갖고 있는 모바일 <select>의 옵션 수를 기준으로 삼아,
// 데스크톱 nav의 li 총합이 그보다 적으면(=유실) 세션당 한 번만 새로고침해 복구한다.
(function () {
  var nav = document.getElementById('site-nav');
  if (!nav) return;

  window.addEventListener('load', function () {
    setTimeout(function () {
      var expected = nav.querySelectorAll('.masthead__mobile-nav option').length;
      var actual = nav.querySelectorAll('.visible-links > li, .hidden-links > li').length;
      if (!expected || actual >= expected) return;

      var key = 'nav-integrity-reload';
      try {
        if (sessionStorage.getItem(key)) return;
        sessionStorage.setItem(key, '1');
      } catch (e) {
        return; // storage 접근 불가 시 재시도 루프 방지를 위해 조용히 포기
      }
      location.reload();
    }, 300);
  });
})();
