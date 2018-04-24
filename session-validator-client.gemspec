Gem::Specification.new do |s|
  s.name        = "session-validator-client"
  s.version     = "3.1.1"
  s.summary     = "Ruby client for Emarsys session validator service"
  s.authors     = ["Emarsys Technologies Ltd."]
  s.email       = "security@emarsys.com"
  s.homepage    = "https://github.com/emartech/session-validator-client-ruby"
  s.licenses    = ["MIT"]

  s.required_ruby_version = ">= 1.9"

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.require_paths = ['lib']

  s.add_dependency "escher-keypool"
  s.add_dependency "faraday"
  s.add_dependency "faraday_middleware"
  s.add_dependency "faraday_middleware-escher"

  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
  s.add_development_dependency "dotenv"
end
