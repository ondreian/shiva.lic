module Shiva
  module Actions
    Known ||= []

    def self.register(action)
      Known << action unless Known.include?(action)
      Known.uniq!
    end

    def self.eval_with_foe(action, method, foe)
      arity = action.method(method).arity
      case arity
      when 1
        action.send(method, foe)
      when 0
        action.send(method)
      else
        fail "%s > method:%s is of unhandled arity %s" % [action.class.name, method, arity]
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