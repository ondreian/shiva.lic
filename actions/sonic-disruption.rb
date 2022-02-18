module Shiva
  class SonicDisruption < Action
    HordeSize = 2

    def initialize(env)
      @first_use = true
      super(env)
    end

    def priority
      31
    end

    def duskruin?
      @env.namespace.eql?(Duskruin)
    end

    def duskruin_check?
      @env.foes.size > 1 and
      percentmana > 40 and
      (@env.main.round > 9 or @env.main.round % 5 == 0)
    end

    def normal_check?
      percentmana > 60 and
      @env.foes.size >= HordeSize
    end

    def available?(foe)
      return false unless Spell[1030].known?
      return true if foe.noun.eql?("shaper") and Group.empty?

      if self.duskruin?
        self.duskruin_check?
      else
        self.normal_check?
      end
    end

    def aoe()
      multifput "prep 1030", "cast"
    end

    def focus(foe)
      fput "incant 1030 #%s" % foe.id
    end

    def apply(foe)
      fput "release" unless checkprep.eql?("None") or checkprep.eql?("Sonic Disruption")
      if @env.foes.size >= HordeSize
        self.aoe
      else
        self.focus(foe)
      end
      sleep 1
      waitcastrt?
    end
  end
end