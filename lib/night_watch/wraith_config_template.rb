require 'erb'

module NightWatch
  class WraithConfigTemplate
    attr_reader :template

    def initialize(path)
      erb = ERB.new(IO.read(path))
      erb.filename = path
      @template = erb.def_class(Struct.new(:name, :paths), 'render()')
    end

    def generate(name, paths)
      template.new(name, paths).render
    end
  end
end
