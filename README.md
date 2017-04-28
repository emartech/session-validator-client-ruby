# session-validator-client-ruby

Ruby client for Emarsys session validator service.

## Usage

```ruby
require "logger"
require "session_validator"

options = {
  service_url: "dummy-service.example.org",
  api_key: "dummy_api_key",
  api_secret: "dummy_api_secret",
}

client = SessionValidator::Client.new options
client.logger = Logger.new STDOUT

cache = SessionValidator::InMemoryCache.new 300

cached_client = SessionValidator::CachedClient.new client, cache

if cached_client.valid? "dummy_msid"
  puts "MSID is valid!"
end
```
