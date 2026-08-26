source "https://rubygems.org"

# 대상(whdrns2013.github.io)과 동일한 github-pages 빌드 스택.
# 이 저장소는 테마 gem 자체가 아니라 vendored 파일을 쓰므로
# "gemspec"(자기 자신을 gem으로 등록하는 줄)은 사용하지 않는다.
gem "github-pages", "228", group: :jekyll_plugins
gem "jekyll-paginate"
gem "jekyll-sitemap"
gem "jekyll-gist"
gem "jekyll-feed"
gem "jekyll-include-cache"
gem "kramdown-parser-gfm"
gem "webrick", "~> 1.8"

group :test do
  gem "html-proofer", "~> 5.0"
end

platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end
