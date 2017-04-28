RSpec.describe SessionValidator::InMemoryCache do
  subject(:cache) { SessionValidator::InMemoryCache.new(ttl) }

  let(:ttl) { 10 }
  let(:key) { "test_12345.67890" }

  describe "#get" do
    subject(:result) { cache.get key }

    context "key does not exist" do
      it { is_expected.to be_nil }
    end

    context "key is expired" do
      before { cache.set key, "value" }

      let(:ttl) { 0 }

      it { is_expected.to be_nil }
    end

    context "cache hit" do
      before { cache.set key, "value" }

      it { is_expected.to eq "value" }
    end
  end

  describe "#cleanup" do
    context "expired key" do
      before { cache.set key, "value" }

      let(:ttl) { 0 }

      it "removes expired key" do
        expect(cache.empty?).to be false
        cache.cleanup
        expect(cache.empty?).to be true
      end
    end

    context "valid key" do
      before { cache.set key, "value" }

      it "does not remove valid key" do
        expect(cache.empty?).to be false
        cache.cleanup
        expect(cache.empty?).to be false
      end
    end
  end

  describe "#empty?" do
    subject(:result) { cache.empty? }

    context "empty cache" do
      it { is_expected.to be true }
    end

    context "not empty cache" do
      before { cache.set key, "value" }

      it { is_expected.to be false }
    end
  end
end
