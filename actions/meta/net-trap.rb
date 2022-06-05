module Shiva
  class NetTrap < Action
    def priority
      Priority.get(:high)
    end

    def available?
      Effects::Debuffs.active?("Net") and
      not Char.prof.eql?("Warrior")
    end

    def apply
      wait_while {Effects::Debuffs.active?("Net")}
    end
  end
end