module Shiva
  class SecondWind < Action
    Name = "Stamina Second Wind"
    Ok   = %r{All thoughts of exhaustion vanish as your body and mind are as one.}
    Err  = %r{Your muscles are far too tired for that right now.}

    def priority
      Priority.get(:medium)
    end

    def cooldown?
      Effects::Cooldowns.active?(Name)
    end

    def active?
      Effects::Buffs.active?("Stamina Second Wind")
    end

    def available?()
      Skills.physicalfitness >= 150 and
      @env.foes.any? {|foe| foe.name =~ /grizzled|ancient/} and
      not self.active? and
      not self.cooldown?
    end

    def apply()
      waitcastrt?
      waitrt?
      result = dothistimeout "stamina second wind", 2, Regexp.union(Ok, Err)
      ttl = Time.now + 2
      wait_until {self.active? or Time.now > ttl} if result =~ Ok
    end
  end
end