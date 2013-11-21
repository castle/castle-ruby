module Userbin
  class Authentication

    CLOSING_BODY_TAG = %r{</body>}

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

          if !Userbin.authenticated? && Userbin.config.protected_path &&
            env["PATH_INFO"].start_with?(Userbin.config.protected_path)

            return render_gateway(env["PATH_INFO"])
          end

          generate_response(env, signature, data)
        end
      rescue Userbin::SecurityError
        message =
          'Userbin::SecurityError: Invalid signature. Refresh to try again.'
        headers = {
          'Content-Type' => 'text/text'
        }

        Rack::Utils.delete_cookie_header!(
          headers, '_ubs', value = {})
        Rack::Utils.delete_cookie_header!(
          headers, '_ubd', value = {})

        [ 400, headers, [message] ]
      end
    end

    def script_tag(login_path)
      script_url = ENV.fetch('USERBIN_SCRIPT_URL') {
        "//js.userbin.com"
      }
      path = login_path || Userbin.config.protected_path

      tag =  "<script src='#{script_url}?#{Userbin.config.app_id}'></script>\n"
      tag += "<script type='text/javascript'>\n"
      tag += "  Userbin.config({\n"
      if Userbin.config.root_path
        tag += "    logoutRedirectUrl: '#{Userbin.config.root_path}',\n"
      end
      tag += "    loginRedirectUrl: '#{path}',\n" if path
      tag += "    reloadOnSuccess: true\n"
      tag += "  });\n"
      tag += "</script>\n"
    end

    def inject_tags(body, login_path = nil)
      if body[CLOSING_BODY_TAG]
        body = body.gsub(CLOSING_BODY_TAG, script_tag(login_path) + '\\0')
      end
      body
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
</body>
</html>
      LOGIN_PAGE

      login_page = inject_tags(login_page, current_path)

      headers = { 'Content-Type' => 'text/html' }

      [403, headers, [login_page]]
    end

    def generate_response(env, signature, data)
      status, headers, response = @app.call(env)

      if headers['Content-Type'] && headers['Content-Type']['text/html']
       if response.respond_to?(:body)
         body = [*response.body]
       else
         body = response
       end
       if !Userbin.config.skip_script_injection
         body = body.each.map do |chunk|
           inject_tags(chunk)
         end
       end
       if response.respond_to?(:body)
         response.body = body
       else
         response = body
       end
        unless body.empty?
          headers['Content-Length'] = body.flatten[0].length.to_s
        end
      end

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

      [status, headers, response]
    end
  end
end
