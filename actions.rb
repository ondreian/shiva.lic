module Shiva
  module Actions
    Known ||= []

    def self.register(action)
      Known << action unless Known.include?(action)
      Known.uniq!
    end

    def self.eval_with_foe(action, method, foe)
      #Log.out("%s.%s" % [action.class.name, method], label: %i(eval_with_foe))
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

    def self.create(controller)
      Known.map {|action|
        Log.out(action.name, label: %i(action loaded)) if Opts["debug"]
        action.new(controller)
      }
    end
  end
end