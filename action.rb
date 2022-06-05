module Shiva
  class Action
    def self.call(action, *args)
      exit if dead?
      return if action == :noop
      if action.method(:apply).arity > 0
        action.apply(*args)
      else
        action.apply
      end
    end

    def self.inherited(action)
      Actions.register(action)
    end

    def initialize(controller)
      @controller = controller
    end

    def controller
      @controller
    end

    def env
      @controller.env
    end

    def to_sym
      self.class.name.split("::").last.downcase.to_sym
    end
  end
end