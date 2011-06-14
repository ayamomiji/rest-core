
if respond_to?(:require_relative, true)
  require_relative 'common'
else
  require File.dirname(__FILE__) + '/common'
end

describe RestGraph do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'be serialized with lighten' do
    engines = if RUBY_VERSION >= '1.9.2'
                require 'psych'
                YAML::ENGINE.yamler = 'psych' # TODO: probably a bug?
                [Marshal, YAML, Psych]
              elsif defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
                [Marshal]
              else
                [YAML]
              end

    engines.each{ |engine|
      test = lambda{ |obj| engine.load(engine.dump(obj)) }
        rg = RestGraph.new(:log_handler => lambda{})
      lambda{ test[rg] }.should.raise(TypeError)
      test[rg.lighten].should == rg.lighten
      lambda{ test[rg] }.should.raise(TypeError)
      rg.lighten!
      test[rg.lighten].should == rg
    }
  end

  should 'lighten takes options to change attributes' do
    RestGraph.new.lighten(:timeout => 100    ).timeout.should == 100
    RestGraph.new.lighten(:lang    => 'zh-TW').lang   .should == 'zh-TW'
  end
end
