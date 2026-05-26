# frozen_string_literal: true

class HomeController < ActionController::Base
  # prepare context and call risk via the client
  def index1
    request_context = ::Castle::Context::Prepare.call(request)
    payload = { event: '$login', status: '$succeeded', user: { id: '123' }, properties: { key: 'value' } }
    client = ::Castle::Client.new(context: request_context)
    client.risk(payload)

    render inline: 'hello'
  end

  # prepare payload via Payload::Prepare and call risk via the client
  def index2
    payload =
      ::Castle::Payload::Prepare.call(
        { event: '$login', status: '$succeeded', user: { id: '123' }, properties: { key: 'value' } },
        request
      )
    client = ::Castle::Client.new
    client.risk(payload)

    render inline: 'hello'
  end

  # prepare payload via Payload::Prepare and call Castle::API::Risk directly
  def index3
    payload =
      ::Castle::Payload::Prepare.call(
        { event: '$login', status: '$succeeded', user: { id: '123' }, properties: { key: 'value' } },
        request
      )

    Castle::API::Risk.call(payload)

    render inline: 'hello'
  end
end
