module Shiva
  class SonicDisruption < Action
    HordeSize = 2

    attr_accessor :renew_room

    def initialize(env)
      @first_use = true
      super(env)
    end

    def priority
      31
    end

    def duskruin?
      self.env.name.eql?(:duskruin)
    end

    def duskruin_check?
      self.env.foes.size > 1 and
      percentmana > 40 and
      (self.env.main.round > 9 or self.env.main.round % 5 == 0)
    end

    def normal_check?
      percentmana > 60 and
      self.env.foes.size >= HordeSize
    end

    def available?(foe)
      return false unless Spell[1030].known?
      return true if foe.noun.eql?("shaper") and Group.empty? and self.env.seen.include?(foe.id)

      if self.duskruin?
        self.duskruin_check?
      else
        self.normal_check?
      end
    end

    def aoe()
      multifput "prep 1030", "cast"
      @last_cast_type = :aoe
    end

    def focus(foe)
      fput "incant 1030 #%s" % foe.id
      @last_cast_type = foe.id
    end

    def renew()
      fput "renew 1030"
    end

    def apply(foe)
      fput "release" unless checkprep.eql?("None") or checkprep.eql?("Sonic Disruption")
      if self.env.foes.size >= HordeSize
        if @renew_room == XMLData.room_id.eql?(@renew_room) && @last_cast_type.eql?(:aoe)
          self.renew
        else
          self.aoe
        end
      else
        if @renew_room == XMLData.room_id.eql?(@renew_room) && @last_cast_type.eql?(foe.id)
          self.renew
        else
          self.focus(foe)
        end
      end
      @renew_room = XMLData.room_id
      sleep 1
      waitcastrt?
    end
  end
end