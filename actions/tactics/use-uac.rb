module Shiva
  class UseBrawling < Action
    def priority
      Priority.get(:high)
    end

    def skilled?
      Tactic.can?(:brawling)
    end

    def available?(foe)
      return false if %w(conjurer grotesque).include?(foe.noun)
      checkright && checkleft && self.skilled? && Shiva::Config.uac.include?(self.env.name)
    end

    def apply(foe)
      waitrt?
      waitcastrt?
      Arms.away
    end
  end
end