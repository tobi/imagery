
class ServerName
  def initialize(app)
    @app = app
  end

  def call(env)     
    hash = @app.call(env)
    hash[1]['Server'] = 'Shopify Imagery'
    hash
  end
end