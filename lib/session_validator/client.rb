require "uri"
require "escher-keypool"
require "faraday"
require "faraday/retry"
require "faraday_middleware/escher"

class SessionValidator::Client
  MSID_PATTERN = /^[a-z0-9._]+_[0-9a-f]{14}\.[0-9]{8}$/.freeze
  CREDENTIAL_SCOPE = "eu/session-validator/ems_request".freeze
  ESCHER_AUTH_OPTIONS = {
    algo_prefix: "EMS",
    vendor_key: "EMS",
    auth_header_name: "X-Ems-Auth",
    date_header_name: "X-Ems-Date"
  }.freeze
  SERVICE_REQUEST_TIMEOUT = 2.freeze
  NETWORK_ERRORS = Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed] - ['Timeout::Error']

  def initialize(use_escher: true)
    @use_escher = use_escher
  end

  def valid?(id)
    if id.match(MSID_PATTERN)
      valid_by_msid? id
    else
      valid_by_session_data_token? id
    end
  end

  def session_data(token)
    response = client.get("/sessions", nil, headers.merge(authorization_header token))
    case response.status
      when 200 then JSON.parse(response.body)
      when 400..499 then raise SessionValidator::SessionDataNotFound
      when 500.. then raise SessionValidator::SessionDataError, "Service unreachable"
    end
  rescue *NETWORK_ERRORS
    raise SessionValidator::SessionDataError, "Service unreachable"
  end

  # @deprecated
  def filter_invalid(msids)
    response = client.post("/sessions/filter", JSON.generate({ msids: msids }), headers)
    if response.status == 200
      JSON.parse(response.body)
    else
      []
    end
  rescue *NETWORK_ERRORS
    []
  end

  private

  def valid_by_msid?(msid)
    response_status = client.get("/sessions/#{msid}", nil, headers).status
    (200..299).include?(response_status) || (500..599).include?(response_status)
  rescue *NETWORK_ERRORS
    true
  end

  def valid_by_session_data_token?(token)
    response_status = client.head("/sessions", nil, headers.merge(authorization_header token)).status
    case response_status
      when 200 then true
      when 400..499 then false
      when 500.. then raise SessionValidator::SessionDataError, "Service unreachable"
    end
  rescue *NETWORK_ERRORS
    raise SessionValidator::SessionDataError, "Service unreachable"
  end

  def client
    Faraday.new(url) do |faraday|
      faraday.options[:open_timeout] = SERVICE_REQUEST_TIMEOUT
      faraday.options[:timeout] = SERVICE_REQUEST_TIMEOUT
      faraday.request :retry, interval: 0.05, interval_randomness: 0.5, backoff_factor: 2, methods: [:head, :get, :post], exceptions: NETWORK_ERRORS
      faraday.use(Faraday::Middleware::Escher::RequestSigner, escher_config) if @use_escher
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

  def authorization_header(token)
    { "Authorization" =>  "Bearer #{token}" }
  end
end
