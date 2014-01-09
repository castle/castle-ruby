module Userbin
  class Authentication

    CLOSING_BODY_TAG = %r{</body>}

    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      if !Userbin.config.app_id || !Userbin.config.api_secret
        raise ConfigurationError, "app_id and api_secret must be present"
      end

      Thread.current[:userbin] = nil
      env['userbin.unauthenticated'] = false

      request = Rack::Request.new(env)

      begin
        jwt = Userbin.authenticate!(request)

        if !Userbin.authenticated? && Userbin.config.protected_path &&
          env["PATH_INFO"].start_with?(Userbin.config.protected_path)

          return render_gateway(env["PATH_INFO"])
        end

        generate_response(env, jwt)
      rescue Userbin::SecurityError
        message =
          'Userbin::SecurityError: Invalid session. Refresh to try again.'
        headers = {
          'Content-Type' => 'text/text'
        }

        Rack::Utils.delete_cookie_header!(
          headers, '_ubt', value = {})

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
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Log in</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
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

    def generate_response(env, jwt)
      status, headers, response = @app.call(env)

      # application stack is responsible for setting userbin.authenticated
      return render_gateway(env["PATH_INFO"]) if env['userbin.unauthenticated']

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
          headers['Content-Length'] = Rack::Utils.bytesize(body.flatten[0]).to_s
        end
      end

      if jwt
        Rack::Utils.set_cookie_header!(
          headers, '_ubt', value: jwt, path: '/')
      else
        Rack::Utils.delete_cookie_header!(
          headers, '_ubt', value = {})
      end

      [status, headers, response]
    end
  end
end
