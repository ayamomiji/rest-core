
require 'erb'
require 'yaml'

require 'rest-core'

module RestCore::Config
  extend self

  DefaultModuleName = 'DefaultAttributes'

  def load_for_rails klass, app=Rails
    root = File.expand_path(app.root)
    path = ["#{root}/config/rest-core.yaml", # YAML should use .yaml
            "#{root}/config/rest-core.yml" ].find{|p| File.exist?(p)}
    RestCore::Config.load(klass, path, app.env)
  end

  def load klass, path, env
    return false if klass.const_defined?(DefaultModuleName)
    RestCore::Config.load!(klass, path, env)
  end

  def load! klass, path, env
    config   = YAML.load(ERB.new(File.read(path)).result(binding))
    defaults = config[env]
    return false unless defaults
    raise ArgumentError.new("#{defaults} is not a hash") unless
      defaults.kind_of?(Hash)

    mod = if klass.const_defined?(DefaultModuleName)
            klass.const_get(DefaultModuleName)
          else
            m = Module.new
            klass.send(:extend, m)
            klass.send(:const_set, DefaultModuleName, m)
            m
          end

    mod.module_eval(defaults.inject([]){ |r, (k, v)|
      # quote strings, leave others free (e.g. false, numbers, etc)
      r << <<-RUBY
        def default_#{k}
          #{v.kind_of?(String) ? "'#{v}'" : v}
        end
      RUBY
    }.join, __FILE__, __LINE__)
  end
end