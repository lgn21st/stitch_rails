require 'tilt'

module Stitch
  class CoffeeScriptTemplate < Tilt::Template
    self.default_mime_type = 'application/javascript'

    @@default_bare = false

    def self.default_bare
      @@default_bare
    end

    def self.default_bare=(value)
      @@default_bare = value
    end

    @@excludes = []

    def self.engine_initialized?
      defined? ::CoffeeScript
    end

    def self.excludes=(excludes)
      @@excludes = excludes
    end

    def self.javascripts_path
      File.expand_path('../../assets/javascripts', __FILE__)
    end

    def initialize_engine
      require_template_library 'coffee_script'
    end

    def prepare
      if !options.key?(:bare)
        options[:bare] = self.class.default_bare
      end
    end

    def evaluate(scope, locals, &block)
      name = module_name(scope)
      if (name == 'stitch_rails') || excluded?(name)
        @output ||= CoffeeScript.compile(data, options)
      else
        @output ||= <<JS
require.define({
  #{name.inspect}: function(exports, require, module) {
#{indent_lines(CoffeeScript.compile(data, options.merge(:bare => true)), 4)}
  }
});
JS
      end
    end

    private
    def excluded?(name)
      @@excludes.any? { |pattern| File.fnmatch(pattern, name) }
    end

    def indent_lines(content, indention)
      content.gsub(/^/, ' ' * indention)
    end
    # this might need to be customisable to generate the desired module names
    # this implementation lops off the first segment of the path
    def module_name(scope)
      scope.logical_path
    end
  end
end
