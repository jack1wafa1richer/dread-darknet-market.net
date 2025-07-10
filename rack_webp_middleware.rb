# rack_webp_middleware.rb
class RackWebP
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    if env['PATH_INFO'].end_with?('.webp')
      headers['Content-Type'] = 'image/webp'
    end
    [status, headers, response]
  end
end
