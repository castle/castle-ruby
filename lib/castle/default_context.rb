# frozen_string_literal: true

module Castle
  class DefaultContext
    def initialize(headers, ip)
      @headers = headers
      @ip = ip
    end

    # rubocop:disable Metrics/MethodLength
    def call
      context = {
        active: true,
        origin: Castle.config.source_header,
        request: {
          headers: @headers || {}
        },
        ip: @ip,
        library: {
          name: 'castle-rb',
          version: Castle::VERSION
        }
      }
      context[:request][:remoteAddress] = @headers['Remote-Addr'] if @headers['Remote-Addr']
      context[:locale] = @headers['Accept-Language'] if @headers['Accept-Language']
      context[:userAgent] = @headers['User-Agent'] if @headers['User-Agent']
      context
    end
    # rubocop:enable Metrics/MethodLength
  end
end
