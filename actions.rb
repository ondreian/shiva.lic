module Shiva
  module Actions
    Known ||= []

    def self.register(action)
      Known << action unless Known.include?(action)
      Known.uniq!
    end

    def self.eval_with_foe(action, method, foe)
      if action.method(method).arity == 1
        action.send(method, foe)
      else
        action.send(method)
      end
    end

    def self.best_action(actions, foe)
      actions.uniq
        .select {|action| self.eval_with_foe(action, :available?, foe) }
        .sort_by {|action| self.eval_with_foe(action, :priority, foe) }
        .first or :noop
    end

    def self.create_for_env(env)
      Known
        .reject {|action|
          action.respond_to?(:allowed) and 
          not action.allowed.include?(env.namespace)
        }
        .map {|action|
          Log.out(action.name, label: %i(action loaded)) if Opts["debug"]
          action.new(env)
        }
    end
  end
end