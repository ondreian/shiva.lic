module Shiva
  class Action
    def self.call(action, *args)
      begin
        exit if dead?
        return if action == :noop
        if action.method(:apply).arity > 0
          action.apply(*args)
        else
          action.apply
        end
      rescue => exception
        Log.out(exception)
      end
    end

    def self.inherited(action)
      Actions.register(action)
    end

    attr_reader :env
    def initialize(env)
      @env = env
    end

    def to_s
      self.to_sym.to_s
    end

    def inspect
      self.to_s
    end

    def to_sym
      self.class.name.split("::").last.downcase.to_sym
    end
  end
end