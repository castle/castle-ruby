# frozen_string_literal: true

describe Castle::Extractors::IP do
  subject(:extractor) { described_class.new(headers) }

  describe 'ip' do
    after do
      Castle.config.ip_headers = []
      Castle.config.trusted_proxies = []
    end

    context 'when regular ip' do
      let(:headers) { { 'X-Forwarded-For' => '1.2.3.5' } }

      it { expect(extractor.call).to eql('1.2.3.5') }
    end

    context 'when we need to use other ip header' do
      let(:headers) do
        { 'Cf-Connecting-Ip' => '1.2.3.4', 'X-Forwarded-For' => '1.1.1.1, 1.2.2.2, 1.2.3.5' }
      end

      context 'with uppercase format' do
        before { Castle.config.ip_headers = %w[CF_CONNECTING_IP X-Forwarded-For] }

        it { expect(extractor.call).to eql('1.2.3.4') }
      end

      context 'with regular format' do
        before { Castle.config.ip_headers = %w[Cf-Connecting-Ip X-Forwarded-For] }

        it { expect(extractor.call).to eql('1.2.3.4') }
      end

      context 'with value from trusted proxies it get seconds header' do
        before do
          Castle.config.ip_headers = %w[Cf-Connecting-Ip X-Forwarded-For]
          Castle.config.trusted_proxies = %w[1.2.3.4]
        end

        it { expect(extractor.call).to eql('1.2.3.5') }
      end
    end

    context 'with all the trusted proxies' do
      let(:http_x_header) do
        '127.0.0.1,10.0.0.1,172.31.0.1,192.168.0.1,::1,fd00::,localhost,unix,unix:/tmp/sock'
      end

      let(:headers) { { 'Remote-Addr' => '127.0.0.1', 'X-Forwarded-For' => http_x_header } }

      it 'fallbacks to first available header when all headers are marked trusted proxy' do
        expect(extractor.call).to eql('127.0.0.1')
      end
    end

    context 'when list of not trusted ips provided in X_FORWARDED_FOR' do
      let(:headers) do
        {
          'X-Forwarded-For' => '6.6.6.6, 2.2.2.3, 192.168.0.7',
          'Client-Ip' => '6.6.6.6'
        }
      end

      it 'does not allow to spoof ip' do
        expect(extractor.call).to eql('2.2.2.3')
      end

      context 'when marked 2.2.2.3 as trusted proxy' do
        before { Castle.config.trusted_proxies = [/^2.2.2.\d$/] }

        it { expect(extractor.call).to eql('6.6.6.6') }
      end
    end
  end
end
