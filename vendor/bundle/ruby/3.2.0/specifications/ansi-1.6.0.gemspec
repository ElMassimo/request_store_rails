# -*- encoding: utf-8 -*-
# stub: ansi 1.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "ansi".freeze
  s.version = "1.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Thomas Sawyer".freeze, "Florian Frank".freeze]
  s.date = "1980-01-02"
  s.description = "The ANSI project is a superlative collection of ANSI escape code related libraries enabling ANSI colorization and stylization of console output. Byte for byte ANSI is the best ANSI code library available for the Ruby programming language.".freeze
  s.email = ["transfire@gmail.com".freeze]
  s.homepage = "https://github.com/rubyworks/ansi".freeze
  s.licenses = ["BSD-2-Clause".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "ANSI at your fingertips!".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rake>.freeze, [">= 13"])
  s.add_development_dependency(%q<qed>.freeze, [">= 2.9"])
  s.add_development_dependency(%q<ae>.freeze, [">= 1.8"])
end
