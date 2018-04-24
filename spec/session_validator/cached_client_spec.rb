RSpec.describe SessionValidator::CachedClient do
  subject(:cached_client) { SessionValidator::CachedClient.new(client, cache) }

  let(:client) { instance_double(SessionValidator::Client) }
  let(:cache) { instance_double(SessionValidator::InMemoryCache) }

  describe "#valid?" do
    subject(:result) { cached_client.valid? msid }

    let(:msid) { "test_12345.67890" }

    before do
      allow(cache).to receive(:cleanup)
      allow(cache).to receive(:get)
      allow(client).to receive(:valid?)
    end

    it do
      expect(cache).to receive(:cleanup).with(no_args)
      result
    end

    context "result is not cached" do
      context "msid is valid" do
        before do
          allow(cache).to receive(:set).with(msid, true)
          allow(client).to receive(:valid?).with(msid).and_return(true)
        end

        it do
          expect(cache).to receive(:set).with(msid, true)
          result
        end
        it { is_expected.to be true }
      end

      context "msid is not valid" do
        before { allow(client).to receive(:valid?).with(msid).and_return(false) }

        it { is_expected.to be false }
      end
    end

    context "result is cached" do
      before { allow(cache).to receive(:get).with(msid).and_return(true) }

      it { is_expected.to be true }
    end
  end

  describe "#filter_invalid" do
    subject(:result) { cached_client.filter_invalid msids }

    let(:msids) { ["test_12345.67890", "test_12345.67891", "test_12345.67892"] }

    before do
      allow(cache).to receive(:cleanup)
    end

    context "when called" do
      before do
        allow(cache).to receive(:set)
        allow(client).to receive(:filter_invalid).with(msids).and_return([])
      end
      it do
        expect(cache).to receive(:cleanup).with(no_args)
        result
      end
    end

    context "when msids are valid" do
      before do
        allow(cache).to receive(:set)
        allow(client).to receive(:filter_invalid).with(msids).and_return([])
      end

      it do
        msids.each do |msid|
          expect(cache).to receive(:set).with(msid, true)
        end
        result
      end
      it { is_expected.to eq [] }
    end

    context "when msids are invalid" do
      before do
        allow(client).to receive(:filter_invalid).with(msids).and_return(msids)
      end

      it { is_expected.to eq msids }
    end

  end

end
