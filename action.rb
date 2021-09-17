module Shiva
  class Action
    def self.call(action, *args)
      return if action == :noop
      if action.method(:apply).arity > 0
        action.apply(*args)
      else
        action.apply
      end
    end

    def initialize(env)
      @env = env
    end

    def self.inherited(action)
      Actions.register(action)
    end
  end
end