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

    def divergence?
      @divergence.eql?(true)
    end

    def reset_start_time!
      @start_time = Time.now
    end

    def uptime()
      Time.now - @start_time
    end

    def foe_nouns
      @foes
    end

    def setup
      Setup.new(self).apply()
    end

    def main
      Main.new(self).apply()
    end

    def teardown
      Teardown.new(self).apply()
    end

    def reset!
      @seen     = []
      @actions  = Actions.create(self)
    end

    def rooms()
      return [] if @boundaries.nil? or self.entry.nil?
      @_subgraph ||= self._rooms()
    end

    def _rooms()
      _subgraph   = []
      _boundaries = @boundaries.map(&:to_s)
      _pending    = []
      entry_room  = Room[self.entry.to_i]
      process_room = -> room {
        room.wayto.keys
          .reject {|id| _boundaries.include?(id) or _subgraph.include?(id) }
          .each {|id|
            _pending  << id
            _subgraph << id
          }
      }
      process_room.(entry_room)

      until _pending.empty?
        next_room_id = _pending.shift
        process_room.(Room[next_room_id.to_i])
        fail "infinite expansion detected in #{self.name} / did you forget a boundary?" if _pending.size > 500
      end

      return _subgraph
    end

    def dsl(&block)
      self.instance_eval(&block)
    end

    def foes
      return [] unless Claim.mine?
      return GameObj.targets.map {|f| Creature.new(f)} if @foes.nil?
      Foes.select {|foe| @foes.include?(foe.noun) }.sort_by do |foe|
        if foe.name =~ /grizzled|ancient/
          0
        elsif checkbounty.include?(foe.noun) and not Group.empty?
          1
        else
          2 + @foes.index(foe.noun) - foe.status.size
        end
      end
    end

    def foe
      self.foes.first
    end

    def action(query)
      if query.is_a?(Symbol)
        @env.actions.find {|a| a.class.name.downcase.split("::").last.to_sym.eql?(query)}
      else
        @env.actions.find {|a| a.class.name =~ /#{query}/i}
      end
    end

    def best_action
      current_foe = self.foe
      proposed_action = Shiva::Actions.best_action(@actions, current_foe)
      Log.out(proposed_action.is_a?(Symbol) ? proposed_action : proposed_action.to_sym, 
        label: %i(proposed action)) unless proposed_action == @action_history.last
      @action_history << proposed_action
      [proposed_action, current_foe]
    end
  end
end