module SessionValidator
  class CachedClient
    def initialize(client, cache)
      @client = client
      @cache = cache
    end

    def valid?(msid)
      @cache.cleanup

      cached_result = @cache.get msid
      return cached_result if cached_result

      @client.valid?(msid).tap do |result|
        @cache.set msid, result if result
      end
    end

    def filter_invalid(msids)
      @cache.cleanup

      @client.filter_invalid(msids).tap do |result|
        msids.each do |msid|
          @cache.set msid, true unless result.include?(msid)
        end
      end
    end

  end
end
