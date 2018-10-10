RSpec.describe SessionValidator::Client do
  subject(:client) { SessionValidator::Client.new }

  describe "#valid?" do
    subject(:validation) { client.valid? msid }

    let(:msid) { "test_12345.67890" }
    let(:service_url) { "https://example.org" }
    let(:http_request) { stub_request(:get, "#{service_url}/sessions/#{msid}") }
    let(:escher_keypool) { { api_key_id: 'session-validator_smart-insight_v1', api_secret: 'escher_secret' } }

    before do
      stub_const 'ENV', ENV.to_h.merge('SESSION_VALIDATOR_URL' => service_url)
      allow(::Escher::Keypool).to receive_message_chain(:new, :get_active_key).with("session_validator")
                                    .and_return(escher_keypool)
    end

    context "when msid is valid" do
      before { http_request.to_return status: [200, "OK"] }

      it { is_expected.to eq true }
    end

    context "when msid is not valid" do
      before { http_request.to_return status: [404, "Not Found"] }

      it { is_expected.to eq false }
    end

    context "when client is not configured properly" do
      before { http_request.to_return status: [401, "Unauthorized"] }

      it { is_expected.to eq false }
    end

    context "when service is not working properly" do
      before { http_request.to_return status: [500, "Internal Server Error"] }

      it { is_expected.to eq true }
    end

    context "when request times out" do
      before { http_request.to_timeout }

      it { is_expected.to eq true }
    end

    context "when request times out at first but eventually succeeds" do
      before { http_request.to_timeout.then.to_timeout.then.to_return status: [404, 'Not Found'] }

      it 'retries the request and returns the result of the query' do
        expect(validation).to eq false
      end
    end
  end

  describe "#filter_invalid" do
    subject(:validation) { client.filter_invalid msids }

    let(:msids) { ["test_12345.67890", "test_12345.67891", "test_12345.67892"] }
    let(:invalid_msids) { ["test_12345.67890", "test_12345.67892"] }
    let(:service_url) { "https://example.org" }
    let(:http_request) { stub_request(:post, "#{service_url}/sessions/filter") }
    let(:escher_keypool) { { api_key_id: 'session-validator_smart-insight_v1', api_secret: 'escher_secret' } }

    before do
      stub_const 'ENV', ENV.to_h.merge('SESSION_VALIDATOR_URL' => service_url)
      allow(::Escher::Keypool).to receive_message_chain(:new, :get_active_key).with("session_validator")
                                      .and_return(escher_keypool)
    end

    context "when request times out" do
      before { http_request.to_timeout }

      it { is_expected.to eq [] }
    end

    context "when request times out at first but eventually succeeds" do
      before { http_request.to_timeout.then.to_timeout.then.to_return body: JSON.generate(invalid_msids) }

      it 'retries the request and returns the list of invalid msids' do
        expect(validation).to eq invalid_msids
      end
    end

    context "when given a list of msids" do
      before { http_request.to_return body: JSON.generate(invalid_msids) }

      it { is_expected.to have_requested(:post, "#{service_url}/sessions/filter").
          with(body: JSON.generate({msids: msids})) }
    end

    context "when response status code is not 200 OK" do
      before { http_request.to_return status: [404, "Not Found"] }

      it { is_expected.to eq [] }
    end

    context "when server replies with a list of msids" do
      before { http_request.to_return body: JSON.generate(invalid_msids) }

      it { is_expected.to eq invalid_msids }
    end
  end
end
