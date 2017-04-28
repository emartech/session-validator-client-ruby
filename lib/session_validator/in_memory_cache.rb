module SessionValidator
  class InMemoryCache
    def initialize(ttl)
      @ttl = ttl
      @cache = {}
    end

    def get(key)
      return nil unless @cache.key? key

      data = @cache[key]
      return nil if expired? data

      data[:value]
    end

    def set(key, value)
      @cache[key] = { value: value, expiry: Time.now.to_i + @ttl }
    end

    def cleanup
      @cache.delete_if { |_, data| expired? data }
    end

    def empty?
      @cache.length == 0
    end

    private

    def expired?(data)
      Time.now.to_i >= data[:expiry]
    end
  end
end
