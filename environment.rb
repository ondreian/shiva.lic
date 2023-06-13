module Shiva
  class Environment
    All = []

    def self.find(name)
      name = name.downcase.to_sym if name.is_a?(String)
      All.find {|env| env.name.eql?(name)}
    end

    def self.define(name, &block)
      fail "#{name} is already defined" if self.find(name)
      env = self.new(name)
      env.dsl(&block)
      All << env
      return env
    end

    attr_reader :name, :entry, :town,
                :scripts, :boundaries,
                :seen, :foes,
                :controller, :actions, :action_history
    attr_accessor :state

    def initialize(name)
      @name = name
      @action_history = []
      self.reset!
    end

    def count(action_name)
      self.action_history.take_while {|action| action.to_sym.eql?(action_name.to_sym)}.size
    end

    def divergence?
      @divergence.eql?(true)
    end

    def reset_start_time!
      @start_time = Time.now
    end

    def uptime()
      Time.now - @start_time
    end

    def native_foes
      @foes || []
    end

    def wandering_foes
      @wandering_foes || []
    end

    def foe_nouns
      self.wandering_foes + self.native_foes
    end

    def level
      @level
    end

    def setup
      self.before_setup if self.respond_to?(:before_setup)
      Setup.new(self).apply()
      self.after_setup if self.respond_to?(:after_setup)
    end

    def main
      self.before_main if self.respond_to?(:before_main)
      Main.new(self).apply()
      self.after_main if self.respond_to?(:after_main)
    end

    def teardown
      self.before_teardown if self.respond_to?(:before_teardown)
      Teardown.new(self).apply()
      self.after_teardown if self.respond_to?(:after_teardown)
    end

    def reset!
      @seen     = []
      @actions  = Actions.create(self)
    end

    def rooms()
      return [] if self.boundaries.nil? or self.entry.nil?
      @_subgraph ||= self._rooms()
    end

    def _rooms()
      _subgraph   = []
      _boundaries = self.boundaries.map(&:to_s)
      _pending    = []
      entry_room  = Room[self.entry.to_i]
      process_room = -> room {
        room.wayto.keys
          .reject {|id| _boundaries.include?(id) or _subgraph.include?(id) }
          .each {|id|
            unless room.timeto[id].is_a?(StringProc) or room.wayto[id].is_a?(StringProc)
              _pending  << id
              _subgraph << id
            end
          }
      }
      process_room.(entry_room)

      until _pending.empty?
        next_room_id = _pending.shift
        process_room.(Room[next_room_id.to_i])
        fail "shiva.env: infinite expansion detected in #{self.name} / did you forget a boundary?" if _pending.size > 500
        fail "shiva.env: subgraph for #{self.name} is to too large %s" % [_subgraph.size] if _subgraph.size > 500
      end

      return _subgraph
    end

    def dsl(&block)
      self.instance_eval(&block)
    end

    def current?
      return true if self.rooms.empty?
      return self.rooms.map(&:to_i).include?(Room.current.id)
    end

    def foes
      return [] unless Claim.mine?
      return GameObj.targets.map {|f| Creature.new(f)} if self.foe_nouns.empty?
      Foes.select {|foe| self.foe_nouns.include?(foe.noun) }.sort_by do |foe|
        if foe.name =~ /grizzled|ancient/
          0
        elsif checkbounty.include?(foe.noun) and not Group.empty?
          1
        else
          2 + self.foe_nouns.index(foe.noun) - foe.status.size
        end
      end
    end

    def foe
      self.foes.first
    end

    def action(query)
      if query.is_a?(Symbol)
        self.actions.find {|a| a.to_sym.eql?(query)}
      else
        self.actions.find {|a| a.class.name =~ /#{query}/i}
      end
    end

    def best_action
      current_foe = self.foe
      proposed_action = Shiva::Actions.best_action(@actions, current_foe)
      Log.out(proposed_action.is_a?(Symbol) ? proposed_action : proposed_action.to_sym, 
        label: %i(proposed action)) unless proposed_action == @action_history.last
      @action_history << proposed_action
      @action_history.shift while @action_history.size > 10
      [proposed_action, current_foe]
    end
  end
end