require "uri"
require "escher-keypool"
require "faraday"
require "faraday/retry"
require "faraday_middleware/escher"

class SessionValidator::Client
  CREDENTIAL_SCOPE = "eu/session-validator/ems_request".freeze
  ESCHER_AUTH_OPTIONS = {
    algo_prefix: "EMS",
    vendor_key: "EMS",
    auth_header_name: "X-Ems-Auth",
    date_header_name: "X-Ems-Date"
  }.freeze
  SERVICE_REQUEST_TIMEOUT = 2.freeze
  NETWORK_ERRORS = Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed] - ['Timeout::Error']

  def valid?(msid)
    response_status = client.get("/sessions/#{msid}", nil, headers).status
    (200..299).include?(response_status) || (500..599).include?(response_status)
  rescue *NETWORK_ERRORS
    true
  end

  def filter_invalid(msids)
    response = client.post("/sessions/filter", JSON.generate({msids: msids}), headers)
    if response.status == 200
      JSON.parse(response.body)
    else
      []
    end
  rescue *NETWORK_ERRORS
    []
  end

  private

  def client
    Faraday.new(url) do |faraday|
      faraday.options[:open_timeout] = SERVICE_REQUEST_TIMEOUT
      faraday.options[:timeout] = SERVICE_REQUEST_TIMEOUT
      faraday.request :retry, interval: 0.05, interval_randomness: 0.5, backoff_factor: 2, methods: [:get, :post], exceptions: NETWORK_ERRORS
      faraday.use Faraday::Middleware::Escher::RequestSigner, escher_config
      faraday.adapter Faraday.default_adapter
    end
  end

  def url
    uri.to_s
  end

  def host
    uri.hostname
  end

  def uri
    URI.parse(SessionValidator.base_url)
  end

  def escher_config
    {
      credential_scope: CREDENTIAL_SCOPE,
      host: host,
      options: ESCHER_AUTH_OPTIONS,
      active_key: -> { ::Escher::Keypool.new.get_active_key("session_validator") }
    }
  end

  def headers
    {"content-type" => "application/json"}
  end
end
