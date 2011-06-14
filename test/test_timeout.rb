
if respond_to?(:require_relative, true)
  require_relative 'common'
else
  require File.dirname(__FILE__) + '/common'
end

describe RestGraph do
  should 'respect timeout' do
    stub_request(:get, 'https://graph.facebook.com/me').to_return(
      lambda{ |r| sleep(0.05); '{}' })
    e = nil
    begin
      RestGraph.new(:timeout => 0.01).get('me')
      nil.should == 'timeout must be thrown'
    rescue Timeout::Error => e
    end
    e.should.kind_of?(Timeout::Error)
  end

  should 'override timeout' do
    mock(Timeout).timeout(99){ {RestCore::RESPONSE_BODY => true} }
    RestGraph.new(:timeout => 1).get('me', {}, :timeout => 99).should == true
  end
end
