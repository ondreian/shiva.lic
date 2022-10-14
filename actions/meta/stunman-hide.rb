module Shiva
  class StunmanHide < Action

    def priority
      Priority.get(:high)
    end

    def effected?
      stunned?
    end

    def available?
      checkstamina > 20 and
      self.effected? and
      Skills.stalkingandhiding > 250
    end

    def apply()
      waitrt?
      waitcastrt?
      fput "stunman hide"
      waitcastrt?
      waitrt?
    end
  end
end