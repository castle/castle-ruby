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
        if request.params['userbin_token'] && request.request_method == 'GET'
          session = Userbin::Session.create(identity: request.params['userbin_token'])
          jwt = session[:cookie] if session

          if jwt
            uri = URI(request.url)
            uri.query = nil
            redirect_headers = {"Location" => uri.to_s}
            Rack::Utils.set_cookie_header!(
              redirect_headers, '_ubt', value: jwt, path: '/')
            return [301, redirect_headers, []]
          end
        end

        jwt = request.cookies['_ubt']

        jwt = Userbin.authenticate!(jwt, request.ip, request.user_agent)

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
      rescue JWT::DecodeError
        generate_response(env, nil)
      end
    end

    def script_tag(login_path)
      script_url = ENV.fetch('USERBIN_SCRIPT_URL') {
        "//d3paxvrgg3ab3f.cloudfront.net/js/v0"
      }
      path = login_path || Userbin.config.protected_path

      tag  = "<script>"
      tag += "(function(w,d,t,s,o,a,b) {";
      tag += "  w[o]=function(){(w[o].c=w[o].c||[]).push(arguments)};a=d.createElement(t);a.async=1;a.src=s;b=d.getElementsByTagName(t)[0];b.parentNode.insertBefore(a,b);";
      tag += "  }(window,document,'script','#{script_url}','ubin'));";
      tag += "ubin({appId: '#{Userbin.config.app_id}'});";
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
       if response.respond_to?('body=')
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
