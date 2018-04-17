Gem::Specification.new do |s|
  s.name        = "session-validator-client"
  s.version     = "3.0.0"
  s.summary     = "Ruby client for Emarsys session validator service"
  s.authors     = ["Emarsys Technologies Ltd."]
  s.email       = "security@emarsys.com"
  s.homepage    = "https://github.com/emartech/session-validator-client-ruby/"
  s.licenses    = ["MIT"]

  s.required_ruby_version = ">= 1.9"

  s.add_dependency "escher-keypool"
  s.add_dependency "faraday"
  s.add_dependency "faraday_middleware"
  s.add_dependency "faraday_middleware-escher"

  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
  s.add_development_dependency "dotenv"
end
