# frozen_string_literal: true

class HomeController < ActionController::Base
  def index
    request_context = ::Castle::Client.to_context(request)
    track_options = ::Castle::Client.to_options(
      event: '$login.succeeded',
      user_id: '123',
      properties: {
        key: 'value'
      },
      user_traits: {
        key: 'value'
      }
    )
    client = ::Castle::Client.new(request_context)
    client.track(track_options)

    render inline: 'hello'
  end
end
