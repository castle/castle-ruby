# frozen_string_literal: true

class HomeController < ActionController::Base
  def index
    request_context = ::Castle::Context::Prepare.call(request)
    payload = ::Castle::Client.to_options(
      event: '$login.succeeded',
      user_id: '123',
      properties: {
        key: 'value'
      },
      user_traits: {
        key: 'value'
      }
    )
    client = ::Castle::Client.new(context: request_context)
    client.track(payload)

    render inline: 'hello'
  end
end
