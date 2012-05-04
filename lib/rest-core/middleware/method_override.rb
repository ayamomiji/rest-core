require 'multi_json'
require 'rest-core/middleware'
require 'rest-core/patch/multi_json'

# This middleware GET and DELETE.
class RestCore::MethodOverride
  def self.members; [:method_override]; end
  include RestCore::Middleware

  OVERRIDE_METHODS = [:head, :get, :delete].freeze

  def call env
    return app.call(env) unless method_override(env)

    method = env[REQUEST_METHOD]
    payload = env[REQUEST_PAYLOAD] || {}
    if OVERRIDE_METHODS.include?(method) && payload.any?
      env = env.merge(
        REQUEST_METHOD  => :post,
        REQUEST_PAYLOAD => payload.merge('_method' => method.to_s))
    end

    app.call(env)
  end
end
