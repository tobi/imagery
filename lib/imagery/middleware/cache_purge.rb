module Imagery
  class CachePurge
    Success = [200, {'Content-Type' => 'text/plain'}, ['OK']]

    def initialize(app)
      @app = app
    end

    # PURGE /s/files/1/0001/4168/files/thumbs/pic_thumb.jpg?12428536032 HTTP/1.0

    def call(env)
      # Rack cache automatically invalidates resource if the verbs are not GET/POST so
      # we don't actually have to do anything. Simply don't delegate those to the backend
      if env['REQUEST_METHOD'] == 'PURGE'
        Success
      else
        @app.call(env)
      end
    end
  end
end
