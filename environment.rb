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
                :scripts, :foes, :boundaries,
                :seen
    attr_accessor :state

    def initialize(name)
      @name = name
      self.reset!
    end

    def reset!
      @seen = []
    end

    def rooms()
      return [] if @boundaries.nil? or @entry.nil?
      @_subgraph ||= self._rooms()
    end

    def _rooms()
      _subgraph   = []
      _boundaries = @boundaries.map(&:to_s)
      _pending    = []
      entry_room  = Room[@entry.to_i]
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
  end
end