module Shiva
  class UseTwc < Action
    def priority
      Priority.get(:high)
    end

    def available?(foe)
      !Tactic.twc? &&
      Tactic.can?(:edgedweapons) &&
      Tactic.can?(:twoweaponcombat) &&
      Vars["shiva/main"] &&
      Vars["shiva/offhand"] &&
      !%w(brawler).include?(foe.noun) &&
      self.main_hand &&
      self.offhand
    end

    def main_hand()
      Containers.harness.where(name: Vars["shiva/main"]).first
    end

    def offhand()
      Containers.harness.where(name: Vars["shiva/offhand"]).first
    end

    def dual_wield
      self.main_hand.take
      self.offhand.take
    end

    def apply(foe)
      waitrt?
      waitcastrt?
      fput "rub gorget" if GameObj.inv.map(&:noun).grep(/^gorget$/) and not invisible?
      Containers.harness.add(*[Char.left, Char.right].compact)
      self.dual_wield
    end
  end
end