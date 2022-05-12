module Shiva
  class Teardown
    attr_reader :controller, :env

    def initialize(controller)
      @controller = controller
      @env        = controller.env
    end

    def apply()
      self.env.before_teardown if self.env.respond_to?(:before_teardown)
      Common::Teardown.cleanup(self.env.town) if self.env.town
      exit if Opts["once"]
    end
  end
end