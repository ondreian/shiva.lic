module Shiva
  class UseDefault < Action
    def priority
      Priority.get(:high)
    end

    def available?(foe)
      Vars["shiva/main"] &&
      Vars["shiva/offhand"] &&
      !%w(brawler).include?(foe.noun) && # prefer ranged for brawlers
      self.main_hand &&
      self.offhand
    end

    def main_hand()
      Containers.harness.where(name: Vars["shiva/main"]).first
    end

    def offhand()
      Containers.harness.where(name: Vars["shiva/shield"]).first or
      Containers.harness.where(name: Vars["shiva/offhand"]).first
    end

    def arm
      self.main_hand.take
      self.offhand.take
    end

    def apply(foe)
      waitrt?
      waitcastrt?
      fput "rub gorget" if GameObj.inv.map(&:noun).grep(/^gorget$/) and not invisible?
      Containers.harness.add(*[Char.left, Char.right].compact)
      Charm.arm
    end
  end
end