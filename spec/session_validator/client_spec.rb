RSpec.describe SessionValidator::Client do
  subject(:client) { SessionValidator::Client.new(service_url: service_url, api_key: api_key, api_secret: api_secret) }

  let(:service_url) { "example.org" }
  let(:api_key) { "dummy_api_key" }
  let(:api_secret) { "dummy_api_secret" }

  let(:credential_scope) { "eu/session-validator/ems_request" }
  let(:escher_config) do
    {
      algo_prefix: "EMS",
      vendor_key: "EMS",
      auth_header_name: "X-Ems-Auth",
      date_header_name: "X-Ems-Date"
    }
  end

  describe "#valid?" do
    subject(:validation) { client.valid? msid }

    let(:msid) { "test_12345.67890" }
    let(:request_to_sign) do
      {
        method: "GET",
        uri: "/sessions/#{msid}",
        headers: [
          ["content-type", "application/json"],
          ["host", service_url]
        ]
      }
    end
    let(:http_request) { stub_request(:get, "https://#{service_url}/sessions/#{msid}") }

    context "when performing validation" do
      let(:escher) { instance_double(Escher::Auth) }

      before { http_request.to_return status: [200, "OK"] }

      it "signs the request" do
        expect(Escher::Auth).to receive(:new).with(credential_scope, escher_config).and_return(escher)
        expect(escher).to receive(:sign!).with(request_to_sign, { api_key_id: api_key, api_secret: api_secret })
                           .and_return(request_to_sign)

        validation
      end
    end

    context "msid is valid" do
      before { http_request.to_return status: [200, "OK"] }

      it { is_expected.to eq true }
    end

    context "msid is not valid" do
      before { http_request.to_return status: [404, "Not Found"] }

      it { is_expected.to eq false }
    end

    context "client is not configured properly" do
      before { http_request.to_return status: [401, "Unauthorized"] }

      it { is_expected.to eq false }
    end

    context "service is not working properly" do
      before { http_request.to_return status: [500, "Internal Server Error"] }

      it { is_expected.to eq true }
    end

    context "open timeout" do
      before { http_request.to_raise Net::OpenTimeout }

      it { is_expected.to eq true }
    end

    context "read timeout" do
      before { http_request.to_raise Net::ReadTimeout }

      it { is_expected.to eq true }
    end
  end
end
