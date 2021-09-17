module Shiva
  class BullRush < Action
    def priority
      (5...95).to_a.sample
    end

    def available?(foe)
      CMan.bull_rush > 3 and
      checkstamina > 50 and
      @env.foes.size > 2 and
      @env.foes.map(&:status).select(&:empty?).size > 1 and
      not foe.nil? and
      foe.status.empty? and
      rand > 0.6
    end

    def bull_rush(foe)
      Timer.await()
      Stance.offensive
      fput "cman bull #%s" % foe.id
    end

    def apply(foe)
      return self.bull_rush foe
    end
  end
end