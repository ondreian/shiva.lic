module Shiva
  class SonicDisruption < Action
    HordeSize = 2

    attr_accessor :renew_room

    def initialize(env)
      @first_use = true
      super(env)
    end

    def priority
      21
    end

    def duskruin?
      self.env.name.eql?(:duskruin)
    end

    def duskruin_check?
      return false if self.env.foes.size.eql?(1) && !self.env.foes.first.status.empty?
      return true if self.env.foes.size.eql?(1) && %w(slave wildling).include?(self.env.foes.first.noun) && percentmana > 20
      return true if self.env.round % 5 == 0 and percentmana > 10
      return false if percentmana < 40
      return true if self.env.round > 9 && rand > 0.5
      return self.env.foes.size > 1
    end

    def normal_check?
      percentmana > 60 and
      self.env.foes.size >= HordeSize and
      not %i(moonsedge_castle).include?(self.env.name)
    end

    def available?(foe)
      return false if foe.nil?
      return false unless Spell[1030].known?
      return true if foe.noun.eql?("shaper") and Group.empty? and self.env.seen.include?(foe.id)

      if self.duskruin?
        self.duskruin_check?
      else
        self.normal_check?
      end
    end

    def aoe()
      #if dothistimeout("incant 1030 #%s" % foe.id, 2, %r{You weave another verse into your harmony})
      multifput "prep 1030", "cast"
      @last_cast_type = :aoe
      @renew_room = XMLData.room_id
    end

    def focus(foe)
      if dothistimeout("incant 1030 #%s" % foe.id, 2, %r{You weave another verse into your harmony})
        @last_cast_type = foe.id
        @renew_room = XMLData.room_id
      end
    end

    module Outcomes
      Fail = %r{But you are not singing that spellsong.}
      Ok = Regexp.union(
        %r{Sing Roundtime 3 Seconds.},
        %r{You weave another verse into your harmony.},
        %r{You sing with renewed vigor!})

      All = Regexp.union(Fail, Ok)
    end

    def renew()
      result = dothistimeout("renew 1030", 3, Outcomes::All)
      Log.out(result)
      case result
      when Outcomes::Fail
        @renew_room = nil
        Log.out( "%s <=> %s == %s" % [XMLData.room_id, @renew_room, XMLData.room_id.eql?(@renew_room)], label: %i(renew))
      else
        @renew_room = XMLData.room_id
        :ok
      end
    end

    def apply(foe)
      waitcastrt?
      waitrt?
      fput "release" unless checkprep.eql?("None") or checkprep.eql?("Sonic Disruption")
      Log.out("{foe=%s, room=%s}" % [@last_cast_type, @renew_room], label: %i(sonic disruption state))
      if self.env.foes.size >= HordeSize
        if XMLData.room_id.eql?(@renew_room) && @last_cast_type.eql?(:aoe)
          self.renew
        else
          self.aoe
        end
      else
        if XMLData.room_id.eql?(@renew_room) && @last_cast_type.eql?(foe.id)
          self.renew
        else
          self.focus(foe)
        end
      end
      sleep 1
      #waitcastrt?
    end
  end
end