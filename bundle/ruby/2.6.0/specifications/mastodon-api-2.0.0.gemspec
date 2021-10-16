# -*- encoding: utf-8 -*-
# stub: mastodon-api 2.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "mastodon-api".freeze
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Eugen Rochko".freeze]
  s.date = "2019-01-29"
  s.description = "A ruby interface to the Mastodon API".freeze
  s.email = "eugen@zeonfederated.com".freeze
  s.homepage = "https://github.com/tootsuite/mastodon-api".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.9".freeze
  s.summary = "A ruby interface to the Mastodon API".freeze

  s.installed_by_version = "3.0.9" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<http>.freeze, ["~> 3.3"])
      s.add_runtime_dependency(%q<oj>.freeze, ["~> 3.7"])
      s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.6"])
      s.add_runtime_dependency(%q<buftok>.freeze, ["~> 0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.7"])
    else
      s.add_dependency(%q<http>.freeze, ["~> 3.3"])
      s.add_dependency(%q<oj>.freeze, ["~> 3.7"])
      s.add_dependency(%q<addressable>.freeze, ["~> 2.6"])
      s.add_dependency(%q<buftok>.freeze, ["~> 0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
    end
  else
    s.add_dependency(%q<http>.freeze, ["~> 3.3"])
    s.add_dependency(%q<oj>.freeze, ["~> 3.7"])
    s.add_dependency(%q<addressable>.freeze, ["~> 2.6"])
    s.add_dependency(%q<buftok>.freeze, ["~> 0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
  end
end
