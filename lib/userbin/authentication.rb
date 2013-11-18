module Userbin
  class Authentication

    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      begin
        if env["PATH_INFO"] == "/userbin" &&
           env["REQUEST_METHOD"] == "POST"
          signature, data = Userbin.authenticate_events!(request)

          MultiJson.decode(data)['events'].each do |event|
            Userbin::Events.trigger(event)
          end

          [ 200, { 'Content-Type' => 'text/html',
            'Content-Length' => '2' }, ['OK'] ]
        else
          signature, data = Userbin.authenticate!(request)

          if !Userbin.authenticated? && Userbin.config.restricted_path &&
            env["PATH_INFO"].start_with?(Userbin.config.restricted_path)

            return render_gateway(env["PATH_INFO"])
          end

          generate_response(env, signature, data)
        end
      rescue Userbin::SecurityError
        message =
          'Userbin::SecurityError: Invalid signature. Refresh to try again.'
        headers = {
          'Content-Type' => 'text/text',
          'Content-Length' => message.length.to_s
        }

        Rack::Utils.delete_cookie_header!(
          headers, '_ubs', value = {})
        Rack::Utils.delete_cookie_header!(
          headers, '_ubd', value = {})

        [ 400, headers, [message] ]
      end
    end

    def render_gateway(current_path)
      script_url = ENV["USERBIN_SCRIPT_URL"] || '//js.userbin.com'

      login_page = <<-LOGIN_PAGE
<!DOCTYPE html>
<html>
<head>
  <title>Log in</title>
</head>
<body>
  <a class="ub-login-form"></a>
  <script src="#{script_url}"></script>
</body>
</html>
      LOGIN_PAGE

      headers = { 'Content-Type' => 'text/html' }

      Rack::Utils.set_cookie_header!(
        headers, '_ubc_lu', value: current_path, path: '/')

      [403, headers, [login_page]]
    end

    def generate_response(env, signature, data)
      status, headers, response = @app.call(env)

      if signature && data
        Rack::Utils.set_cookie_header!(
          headers, '_ubs', value: signature, path: '/')
        Rack::Utils.set_cookie_header!(
          headers, '_ubd', value: data, path: '/')
      else
        Rack::Utils.delete_cookie_header!(
          headers, '_ubs', value = {})
        Rack::Utils.delete_cookie_header!(
          headers, '_ubd', value = {})
      end

      if headers['Content-Type'] && headers['Content-Type']['text/html']
        login_path = Userbin.config.restricted_path || env["PATH_INFO"]

        Rack::Utils.set_cookie_header!(
          headers, '_ubc_id', value: Userbin.config.app_id, path: '/')
        Rack::Utils.set_cookie_header!(
          headers, '_ubc_ru', value: Userbin.config.root_path, path: '/')
        Rack::Utils.set_cookie_header!(
          headers, '_ubc_lu', value: login_path, path: '/')
      end

      [status, headers, response]
    end
  end
end
