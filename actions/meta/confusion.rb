# wait for Confusion state to dissipate 
module Shiva
  class Confused < Action
    def priority
      Priority.get(:high)
    end

    def confused?
      Effects::Debuffs.active?("Confused")
    end

    def available?
      self.confused?
    end

    def apply()
      Walk.apply do
        wait_while("waiting on Confused status") { self.confused? and GameObj.targets.empty? }
      end
    end
  end
end