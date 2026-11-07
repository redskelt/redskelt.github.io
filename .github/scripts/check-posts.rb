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

if errors.empty?
  puts "OK: check-posts (#{posts.size} posts)"
else
  warn "FAIL: check-posts — #{errors.size}건"
  errors.each { |e| warn "  #{e}" }
  exit 1
end
