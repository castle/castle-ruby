module Userbin
  class Authentication

    CLOSING_HEAD_TAG = %r{</head>}
    CLOSING_BODY_TAG = %r{</body>}

    def initialize(app, options = {})
      @app = app
      @restricted_path = options[:restricted_path]
    end

    def call(env)
      request = Rack::Request.new(env)

      begin
        if env["REQUEST_PATH"] == "/userbin" &&
           env["REQUEST_METHOD"] == "POST"
          signature, data = Userbin.authenticate_events!(request)

          MultiJson.decode(data)['events'].each do |event|
            Userbin.trigger(event)
          end

          [ 200, { 'Content-Type' => 'text/html',
            'Content-Length' => '2' }, ['OK'] ]
        else
          signature, data = Userbin.authenticate!(request)

          if restrict && env["REQUEST_PATH"].start_with?(restrict) &&
             !Userbin.authenticated?
            return render_gateway(env["REQUEST_PATH"])
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
          headers, 'userbin_signature', value = {})
        Rack::Utils.delete_cookie_header!(
          headers, 'userbin_data', value = {})

        [ 400, headers, [message] ]
      end
    end

    def restrict
      Userbin.config.restricted_path || @restricted_path
    end

    def link_tags(login_path)
      <<-LINK_TAGS
<link rel="userbin:root" href="/" />
<link rel="userbin:login" href="#{login_path}" />
      LINK_TAGS
    end

    def meta_tag
      <<-META_TAG
<meta property="userbin:events" content="/userbin" />
      META_TAG
    end

    def script_tag
      script_url = ENV.fetch('USERBIN_SCRIPT_URL') {
        "https://userbin.com/js/v0"
      }
      str = <<-SCRIPT_TAG
<script src="#{script_url}?#{Userbin.app_id}"></script>
      SCRIPT_TAG
    end

    def render_gateway(current_path)
      login_page = <<-LOGIN_PAGE
<html>
<head>
  <title>Log in</title>
</head>
<body style="background-color: #DBDBDB;">
  <a class="ub-login-form"></a>
</body>
</html>
      LOGIN_PAGE
      login_page = inject_tags(login_page, current_path)
      [ 200,
        { 'Content-Type' => 'text/html',
          'Content-Length' => login_page.length.to_s },
        [login_page]
      ]
    end

    def inject_tags(body, login_path = restrict)
      if body[CLOSING_HEAD_TAG]
        body = body.gsub(CLOSING_HEAD_TAG, link_tags(login_path) + '\\0')
        body = body.gsub(CLOSING_HEAD_TAG, meta_tag + '\\0')
      end
      if body[CLOSING_BODY_TAG]
        body = body.gsub(CLOSING_BODY_TAG, script_tag + '\\0')
      end
      body
    end

    def generate_response(env, signature, data)
      status, headers, response = @app.call(env)
      if headers['Content-Type'] && headers['Content-Type']['text/html']
        if response.respond_to?(:body)
          body = [*response.body]
        else
          body = response
        end

        body = body.each.map do |chunk|
          inject_tags(chunk)
        end

        if response.respond_to?(:body)
          response.body = body
        else
          response = body
        end

        headers['Content-Length'] = body.join.length.to_s
      end

      if signature && data
        Rack::Utils.set_cookie_header!(
          headers, 'userbin_signature', value: signature, path: '/')
        Rack::Utils.set_cookie_header!(
          headers, 'userbin_data', value: data, path: '/')
      else
        Rack::Utils.delete_cookie_header!(
          headers, 'userbin_signature', value = {})
        Rack::Utils.delete_cookie_header!(
          headers, 'userbin_data', value = {})
      end

      [status, headers, response]
    end
  end
end
