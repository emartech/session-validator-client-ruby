module SessionValidator
  autoload :Client, "session_validator/client"
  autoload :CachedClient, "session_validator/cached_client"
  autoload :InMemoryCache, "session_validator/in_memory_cache"

  class SessionDataError < StandardError; end

  class SessionDataNotFound < SessionDataError; end

  def self.base_url
    ENV['SESSION_VALIDATOR_URL']
  end
end
