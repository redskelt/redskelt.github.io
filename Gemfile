source "https://rubygems.org"

# github-pages 빌드 스택. 233 미만은 jekyll-remote-theme 0.4.3 이 rubyzip 을
# 3.0 미만(보안 경고 대상)으로 묶는다.
# 이 저장소는 테마 gem 자체가 아니라 vendored 파일을 쓰므로
# "gemspec"(자기 자신을 gem으로 등록하는 줄)은 사용하지 않는다.
gem "github-pages", "233", group: :jekyll_plugins
gem "jekyll-paginate"
gem "jekyll-sitemap"
gem "jekyll-gist"
gem "jekyll-feed"
gem "jekyll-include-cache"
gem "kramdown-parser-gfm"
gem "webrick", "~> 1.8"
# Ruby 3.4+는 csv를 기본 gem에서 제외함 — jekyll 3.9.3이 내부적으로
# require하므로 명시적으로 선언해 둔다. 지금 ruby 버전은 .ruby-version(로컬·CI 공통)이
# 정하지만, 그 파일을 3.4+로 올려도 빌드가 깨지지 않게 남긴다.
gem "csv"

group :test do
  gem "html-proofer", "~> 5.0"
end

platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end
