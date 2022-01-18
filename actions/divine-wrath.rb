module Shiva
  class DivineWrath < Action
    HordeSize = 2

    def initialize(env)
      @first_use = true
      super(env)
    end

    def priority
      20
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
      Spell[335].affordable? and
      @env.foes.size >= HordeSize
    end

    def available?(foe)
      return false unless Spell[335].known?
      return false if Effects::Cooldowns.active?("Divine Wrath")
      
      if self.duskruin?
        self.duskruin_check?
      else
        self.normal_check?
      end
    end

    def aoe()
      waitcastrt?
      fput "incant 335"
      waitcastrt?
    end

    def apply(foe)
      self.aoe
      sleep 1
      waitcastrt?
    end
  end
end