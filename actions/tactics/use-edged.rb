module Shiva
  class UseEdged < Action
    def priority
      Priority.get(:high)
    end

    def available?(foe)
      return true if %w(conjurer grotesque).include?(foe.noun) and Tactic.brawling? and Tactic.can?(:edgedweapons)
      return true if checkleft.nil? and checkright.nil? and Tactic.can?(:edgedweapons) and not Shiva::Config.uac.include?(self.env.name)
      return false
    end

    def apply(foe)
      waitrt?
      waitcastrt?
      Char.arm
    end
  end
end