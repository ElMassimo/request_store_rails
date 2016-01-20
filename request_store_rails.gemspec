Gem::Specification.new do |s|
  s.name = 'request_store_rails'
  s.version = '0.0.3'
  s.licenses = ['MIT']
  s.summary = 'Per-request global storage for Rails'
  s.description = 'RequestLocals gives you per-request global storage in Rails'
  s.authors = ['Máximo Mussini']

  s.email = ['maximomussini@gmail.com']
  s.extra_rdoc_files = ['README.md']
  s.files = Dir.glob('{lib}/**/*.rb') + %w(README.md)
  s.homepage = %q{https://github.com/ElMassimo/request_store_rails}

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=1.9.3'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest', '~> 5.0'

  s.add_runtime_dependency 'concurrent-ruby', ['~> 1.0.0']
end
