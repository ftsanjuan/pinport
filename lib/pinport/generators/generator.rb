module Pinport
  module Generator
    def self.templates_path
      File.expand_path('../templates', __FILE__)
    end

    def self.generate_config(output = 'config.yml')
      FileUtils.copy("#{templates_path}/config/config.yml", "#{output}")
    end
  end
end