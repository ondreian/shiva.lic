module Shiva
  class UseRanged < Action
    def priority
      Priority.get(:high)
    end

    def skilled?
      !Tactic.ranged? &&
      Tactic.can?(:rangedweapons) &&
      Config.ranged_weapon &&
      !self.bow.nil?
    end

    def available?(foe)
      %w(brawler).include?(foe.noun) &&
      self.skilled?
    end

    def bow
      Containers.harness.where(name: Config.ranged_weapon).first
    end

    def apply(foe)
      waitrt?
      waitcastrt?
      fput "rub gorget" if GameObj.inv.map(&:noun).grep(/^gorget$/) and not invisible?
      Containers.harness.add(Char.left) if Char.left
      #Containers.harness.add(*[Char.left, Char.right].compact)
      self.bow.take
      Containers.harness.add(Char.right) if Char.right
    end
  end
end