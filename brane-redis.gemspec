Gem::Specification.new do |gem|
  gem.name = 'brane-redis'
  gem.version = '0.0.1'
  gem.authors = ['Ross Paffett']
  gem.email = ['ross@rosspaffett.com']
  gem.description = 'Simple Markov chain generator with Redis persistence'
  gem.summary = gem.description
  gem.homepage = 'https://github.com/raws/brane-redis'

  gem.files = `git ls-files`.split($\)
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'pickup', '~> 0.0.11'
  gem.add_runtime_dependency 'redis', '>= 3.2.1'
end
