module Imagery
  class FaviconFilter
    Empty = [200, {'Content-Type' => 'text/plain'}, ['']].freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      if env['REQUEST_URI'] == '/favicon.ico'
        return Empty
      else
        @app.call(env)
      end
    end
  end
end
