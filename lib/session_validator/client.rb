require "uri"
require "escher-keypool"
require "faraday"
require "faraday_middleware"
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

  def valid?(msid)
    response_status = client.get("/sessions/#{msid}", nil, headers).status
    (200..299).include?(response_status) || (500..599).include?(response_status)
  rescue Faraday::TimeoutError
    true
  end

  private

  def client
    Faraday.new(url) do |faraday|
      faraday.options[:open_timeout] = SERVICE_REQUEST_TIMEOUT
      faraday.options[:timeout] = SERVICE_REQUEST_TIMEOUT
      faraday.use FaradayMiddleware::Escher::RequestSigner, escher_config
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
    { "content-type" => "application/json" }
  end
end
