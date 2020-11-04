# frozen_string_literal: true

class HomeController < ActionController::Base
  def index1
    request_context = ::Castle::Context::Prepare.call(request)
    payload = {
      event: '$login.succeeded',
      user_id: '123',
      properties: {
        key: 'value'
      },
      user_traits: {
        key: 'value'
      }
    }
    client = ::Castle::Client.new(context: request_context)
    client.track(payload)

    render inline: 'hello'
  end

  def index2
    payload = ::Castle::Payload::Prepare.call(
      {
        event: '$login.succeeded',
        user_id: '123',
        properties: {
          key: 'value'
        },
        user_traits: {
          key: 'value'
        }
      },
      request
    )
    client = ::Castle::Client.new
    client.track(payload)

    render inline: 'hello'
  end

  def index3
    payload = ::Castle::Payload::Prepare.call(
      {
        event: '$login.succeeded',
        user_id: '123',
        properties: {
          key: 'value'
        },
        user_traits: {
          key: 'value'
        }
      },
      request
    )
    Castle::API::Track.call(payload)

    render inline: 'hello'
  end
end
