require "escher"
require "logger"
require "net/http"

module SessionValidator
  class Client
    attr_accessor :logger

    CREDENTIAL_SCOPE = "eu/session-validator/ems_request".freeze

    ESCHER_CONFIG = {
      algo_prefix: "EMS",
      vendor_key: "EMS",
      auth_header_name: "X-Ems-Auth",
      date_header_name: "X-Ems-Date"
    }.freeze

    SERVICE_REQUEST_TIMEOUT = 0.15.freeze

    def initialize(service_url:, api_key:, api_secret:)
      @escher = Escher::Auth.new(CREDENTIAL_SCOPE, ESCHER_CONFIG)
      @logger = nil

      @service_url = service_url
      @api_key = api_key
      @api_secret = api_secret
    end

    def valid?(msid)
      response = execute signed_request "GET", "/sessions/#{msid}"

      log Logger::DEBUG, "response code: #{response.code}, response body: #{response.body}"

      response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPServerError)
    rescue Net::OpenTimeout
      log Logger::DEBUG, "open timeout"
      true
    rescue Net::ReadTimeout
      log Logger::DEBUG, "read timeout"
      true
    end

    private

    def signed_request(method, path)
      @escher.sign! request_data(method, path), { api_key_id: @api_key, api_secret: @api_secret }
    end

    def request_data(method, path)
      {
        method: method,
        uri: path,
        headers: [
          ["content-type", "application/json"],
          ["host", @service_url]
        ]
      }
    end

    def execute(data)
      request = Net::HTTP::Get.new(data[:uri])

      data[:headers].each { |header| request[header.first] = header.last }

      options = {
        use_ssl: true,
        open_timeout: SERVICE_REQUEST_TIMEOUT,
        read_timeout: SERVICE_REQUEST_TIMEOUT
      }

      Net::HTTP.start(@service_url, 443, options) { |http| http.request(request) }
    end

    def log(severity, message)
      return unless @logger
      @logger.log(severity, message)
    end
  end
end
