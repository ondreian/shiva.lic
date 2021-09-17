module Shiva
  class SonicDisruption < Action
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
      percentmana > 60 and
      @env.foes.size > 3
    end

    def available?
      return false unless Spell[1030].known?
      if duskruin?
        self.duskruin_check?
      else
        self.normal_check?
      end
    end

    def apply(foe)
      if @first_use
        multifput "prep 1030", "cast"
        return @first_use = false
      end
      fput "renew 1030"
      sleep 1
      waitcastrt?
    end
  end
end