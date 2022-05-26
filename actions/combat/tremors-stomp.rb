module Shiva
  class TremorsStomp < Action
    def priority
      10
    end

    def available?(foe)
      Spell[909].active? and
      @env.foes.size > 1
    end

    def apply(foe)
      Stance.guarded
      fput "stomp"
    end
  end
end