
require 'rest-core/test'

describe RC::MethodOverride do
  before do
    @app = RC::MethodOverride.new(RC::Dry.new, true)
    @env = {}
  end

  should 'do nothing if request query is blank' do
    @app.call(@env).should.eq({})
  end

  should 'do nothing if request method is not need to override' do
    all_methods = [:head, :option, :get, :post, :put, :patch, :delete]

    (all_methods - RC::MethodOverride::OVERRIDE_METHODS).each do |method|
      @app.call(@env.merge(RC::REQUEST_METHOD => method)).
        should.eq(RC::REQUEST_METHOD => method)
    end
  end

  should 'do nothing if request payload is blank' do
    RC::MethodOverride::OVERRIDE_METHODS.each do |method|
      @app.call(@env.merge(RC::REQUEST_METHOD => method)).
        should.eq(RC::REQUEST_METHOD => method)
    end
  end

  should 'override with post if request payload is present' do
    RC::MethodOverride::OVERRIDE_METHODS.each do |method|
      @app.call(@env.merge(RC::REQUEST_METHOD => method,
                           RC::REQUEST_PAYLOAD => {'pay' => 'load'})).
        should.eq(RC::REQUEST_METHOD => :post,
                  RC::REQUEST_PAYLOAD => {'_method' => method.to_s,
                                          'pay' => 'load'})
    end
  end

  describe do
    before do
      @app = RC::MethodOverride.new(RC::Dry.new, :always)
    end

    should 'still override with post if request payload is blank' do
      RC::MethodOverride::OVERRIDE_METHODS.each do |method|
        @app.call(@env.merge(RC::REQUEST_METHOD => method)).
          should.eq(RC::REQUEST_METHOD => :post,
                    RC::REQUEST_PAYLOAD => {'_method' => method.to_s})
      end
    end

    should 'override with post if request payload is present' do
      RC::MethodOverride::OVERRIDE_METHODS.each do |method|
        @app.call(@env.merge(RC::REQUEST_METHOD => method,
                             RC::REQUEST_PAYLOAD => {'pay' => 'load'})).
          should.eq(RC::REQUEST_METHOD => :post,
                    RC::REQUEST_PAYLOAD => {'_method' => method.to_s,
                                            'pay' => 'load'})
      end
    end
  end
end
