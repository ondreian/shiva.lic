module Shiva
  class SecondWind < Action
    Name = "Stamina Second Wind"

    def priority
      Priority.get(:medium)
    end

    def available?()
      Skills.physicalfitness >= 150 and
      @env.foes.any? {|foe| foe.name =~ /grizzled|ancient/} and
      not Effects::Cooldowns.active?(Name) and
      not Effects::Buffs.active?("Stamina Second Wind")
    end

    def apply()
      waitcastrt?
      waitrt?
      fput "stamina second wind"
    end
  end
end