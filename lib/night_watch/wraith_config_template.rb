require 'erb'

module NightWatch
  class WraithConfigTemplate
    attr_reader :template

    def initialize(path)
      erb = ERB.new(IO.read(path))
      erb.filename = path
      @template = erb.def_class(Struct.new(:name), 'render()')
    end

    def generate(name)
      template.new(name).render
    end
  end
end
