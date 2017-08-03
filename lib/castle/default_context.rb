# frozen_string_literal: true

module Castle
  class DefaultContext
    def initialize(request, cookies = nil)
      @client_id = Extractors::ClientId.new(request, cookies || request.cookies).call('__cid')
      @headers = Extractors::Headers.new(request).call
      @ip = Extractors::IP.new(request).call
    end

    # rubocop:disable Metrics/MethodLength
    def call
      context = {
        client_id: @client_id,
        active: true,
        origin: 'web',
        headers: @headers || {},
        ip: @ip,
        library: {
          name: 'castle-rb',
          version: Castle::VERSION
        }
      }
      context[:locale] = @headers['Accept-Language'] if @headers['Accept-Language']
      context[:userAgent] = @headers['User-Agent'] if @headers['User-Agent']
      context
    end
    # rubocop:enable Metrics/MethodLength
  end
end
