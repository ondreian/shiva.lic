module Shiva
  class Stand < Action
    def priority
      1
    end

    def available?
      not standing?
    end

    def apply()
      fput "stand"
    end
  end
end