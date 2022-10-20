module Shiva
  Environment.define :invasion do

    def self.setup
      return unless Group.leader?
      return if Group.empty?
      Group.members.map(&:noun).map do |member|
        Cluster.cast(member, 
          channel: :script, 
          script:  :shiva,
          args:    %(--env=#{self.env.name}),
        )
      end
    end

    def self.main
      loop do
        (proposed_action, foe) = self.best_action
        Action.call(proposed_action, foe)
        Log.out("proposed.action=%s foe=%s" % [proposed_action.to_sym, foe.name], label: %i(invasion logic)) unless proposed_action.eql?(@previous_action)
        @previous_action = proposed_action
        sleep 0.1
      end
    end

    def self.teardown
      :noop
    end
  end
end