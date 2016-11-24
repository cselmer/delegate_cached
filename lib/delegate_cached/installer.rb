module DelegateCached
  class Installer
    attr_reader :source, :target, :options

    def initialize(source, target, options)
      @source = source
      @target = target
      @options = options
    end
  end
end
