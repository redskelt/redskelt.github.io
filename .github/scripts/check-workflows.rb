#!/usr/bin/env ruby
# frozen_string_literal: true

# 워크플로 검사: bundle exec ruby .github/scripts/check-workflows.rb [저장소 루트]
#
# build-site.sh 가 CI · 로컬 공통으로 부른다. CI 환경이 저절로 바뀌어 빌드가 깨진 일이 세 번 있었다.
#   - ruby-version 을 3.4 로 따로 적어 로컬(.ruby-version)과 어긋남(3d7dfad 가 .ruby-version 하나로 모음)
#   - ubuntu-latest 가 26.04 로 바뀌어 setup-ruby 에 3.3.0 이 없어짐(08c614d 가 24.04 로 고정)
# 실패하면 파일 · job 과 대신 쓸 값을 출력하고 exit 1.

require "yaml"

ROOT = File.expand_path(ARGV[0] || File.join(__dir__, "..", ".."))

errors = []
Dir.glob(File.join(ROOT, ".github", "workflows", "*.{yml,yaml}")).sort.each do |path|
  rel = path.delete_prefix("#{ROOT}/")
  jobs = (YAML.safe_load(File.read(path), aliases: true) || {})["jobs"] || {}
  jobs.each do |name, job|
    Array(job["runs-on"]).each do |label|
      next unless label.to_s.end_with?("-latest")

      errors << "#{rel}: job '#{name}' 의 runs-on '#{label}' 는 GitHub 가 이미지를 바꾸면 저절로 달라진다. " \
                "버전이 든 이미지(예: ubuntu-24.04)로 쓴다"
    end
    Array(job["steps"]).each do |step|
      next unless step["uses"].to_s.start_with?("ruby/setup-ruby")

      version = step.dig("with", "ruby-version")
      next if version.to_s == ".ruby-version"

      errors << "#{rel}: job '#{name}' 의 setup-ruby ruby-version '#{version}' 는 로컬 .ruby-version 과 어긋날 수 있다. " \
                "ruby-version: .ruby-version 으로 쓴다"
    end
  end
end

if errors.empty?
  puts "OK: check-workflows"
else
  warn "FAIL: check-workflows — #{errors.size}건"
  errors.each { |e| warn "  #{e}" }
  exit 1
end
