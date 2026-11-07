#!/usr/bin/env ruby
# frozen_string_literal: true

# 포스트 front matter 검사: ruby .github/scripts/check-posts.rb [저장소 루트]
#
# CI(.github/workflows/pages-deploy.yml 의 Check posts 단계)와 로컬
# (.claude/skills/post/verify-build.sh)이 같은 이 스크립트를 부른다.
# Jekyll 은 아래 실수들을 에러 없이 빌드하고 해당 메뉴에서만 조용히 빼므로,
# 빌드 전에 여기서 막는다. 실패하면 파일 이름과 고칠 곳을 출력하고 exit 1.

require "yaml"
require "date"

ROOT = File.expand_path(ARGV[0] || File.join(__dir__, "..", ".."))
ROUNDUP = /-trending-weekly(-\d{4})?\.md\z/

def load_yaml(path)
  YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true)
end

def front_matter(path)
  text = File.read(path)
  m = text.match(/\A---\s*\n(.*?)\n---\s*(\n|\z)/m)
  return nil unless m

  YAML.safe_load(m[1], permitted_classes: [Date, Time], aliases: true) || {}
end

errors = []
posts = Dir.glob(File.join(ROOT, "_posts", "**", "*.md")).sort.map do |path|
  rel = path.delete_prefix("#{ROOT}/")
  fm = front_matter(path)
  if fm.nil?
    errors << "#{rel}: front matter(--- ... ---)가 없다"
    next
  end
  { rel: rel, fm: fm, slug: File.basename(path, ".md").sub(/\A\d{4}-\d{2}-\d{2}-/, "") }
end.compact

# 카테고리: _data/category_hierarchy.yml 의 leaf(categories[].name)만 허용.
# 그 밖의 이름(그룹 key 포함)은 /categories/ 그룹 뷰에서 조용히 빠진다(1864865).
# Trending 은 주간 roundup(*-trending-weekly-MMDD.md) 전용, 다른 카테고리 없이(cd4cd5b).
hierarchy_file = "_data/category_hierarchy.yml"
leaves = load_yaml(File.join(ROOT, hierarchy_file)).flat_map do |group|
  (group["categories"] || []).map { |c| c["name"] }
end
posts.each do |post|
  cats = Array(post[:fm]["categories"]).map(&:to_s)
  errors << "#{post[:rel]}: categories 가 비어 있다 (#{hierarchy_file} 의 leaf 이름을 쓴다)" if cats.empty?
  cats.each do |cat|
    next if leaves.include?(cat)

    errors << "#{post[:rel]}: 카테고리 '#{cat}' 가 #{hierarchy_file} 의 leaf(categories[].name)에 없다. " \
              "있는 leaf: #{leaves.join(', ')}. 새 카테고리면 그 파일의 그룹에 leaf 로 추가한다"
  end
  roundup = post[:rel].match?(ROUNDUP)
  if cats.include?("Trending") && !roundup
    errors << "#{post[:rel]}: Trending 은 주간 roundup(*-trending-weekly-MMDD.md) 전용이다. 개별 리뷰는 [AI] 만 쓴다"
  elsif roundup && cats != ["Trending"]
    errors << "#{post[:rel]}: 주간 roundup 의 categories 는 [Trending] 하나여야 한다 (지금: #{cats.inspect})"
  end
end

# 시리즈: /series/ 와 orbit 은 front matter series/series_index 와 _data/series.yml 로만
# 시리즈를 안다. 제목에 편 번호([k/N], k편, k일차)만 있고 이 필드가 없으면 조용히 빠진다
# (0551df8 Jev, 3ca0b75 JUnit). 편 수는 제목 [k/N] 과 series.yml 의 "N부작" 과도 맞아야 한다.
series_file = "_data/series.yml"
series_path = File.join(ROOT, series_file)
series_meta = File.exist?(series_path) ? (load_yaml(series_path) || {}) : {}
by_series = Hash.new { |h, k| h[k] = [] }
posts.each do |post|
  title = post[:fm]["title"].to_s
  id = post[:fm]["series"]&.to_s
  index = post[:fm]["series_index"]
  by_series[id] << post if id
  part = title.match(%r{\[(\d+)/(\d+)\]}) || title.match(/(\d+)(?:편|일차)/)
  if part && id.nil?
    errors << "#{post[:rel]}: 제목에 편 번호('#{part[0]}')가 있는데 series 가 없다. " \
              "front matter 에 series: <id>, series_index: #{part[1]} 를 넣고 #{series_file} 에 <id> 를 등록한다"
  elsif part && index.to_i != part[1].to_i
    errors << "#{post[:rel]}: 제목의 편 번호 #{part[1]} 와 series_index #{index.inspect} 가 다르다"
  end
  post[:total] = part[2].to_i if part && part.size > 2 && part[2]
  if id && !index.is_a?(Integer)
    errors << "#{post[:rel]}: series: #{id} 인데 series_index(1부터 시작하는 정수)가 없다"
  end
end
by_series.each do |id, members|
  unless series_meta.key?(id)
    errors << "#{series_file}: series '#{id}' 가 없다 (#{members.map { |p| p[:rel] }.join(', ')}). " \
              "#{id}: { title: ..., description: \"... N부작 ...\" } 로 추가한다"
  end
  count = members.size
  indexes = members.map { |p| p[:fm]["series_index"] }.sort_by(&:to_s)
  unless indexes.map(&:to_i).sort == (1..count).to_a
    errors << "series '#{id}': series_index 가 1..#{count} 이 아니다 (#{indexes.inspect})"
  end
  members.each do |post|
    next unless post[:total] && post[:total] != count

    errors << "#{post[:rel]}: 제목은 [k/#{post[:total]}] 인데 series '#{id}' 포스트는 #{count}편이다"
  end
  desc = series_meta.dig(id, "description").to_s
  if (n = desc[/(\d+)부작/, 1]) && n.to_i != count
    errors << "#{series_file}: '#{id}' description 은 #{n}부작인데 포스트는 #{count}편이다"
  end
end

# slug: permalink 가 /:categories/:title/ 이라 같은 slug 는 URL 이 겹쳐 한쪽이 조용히
# 덮어써진다(11bc4df trending-weekly). 날짜를 뺀 파일 이름이 저장소 전체에서 하나여야 한다.
posts.group_by { |p| p[:slug] }.each do |slug, same|
  next if same.size < 2

  errors << "slug '#{slug}' 가 중복이다 (#{same.map { |p| p[:rel] }.join(', ')}). " \
            "새 글의 slug 를 바꾼다(주간 roundup 은 -MMDD 접미사)"
end

if errors.empty?
  puts "OK: check-posts (#{posts.size} posts)"
else
  warn "FAIL: check-posts — #{errors.size}건"
  errors.each { |e| warn "  #{e}" }
  exit 1
end
