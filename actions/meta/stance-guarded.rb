module Shiva
  class StanceGuarded < Action
    def priority
      Priority.get(:high)
    end

    def available?
      %w(Empath Cleric Wizard).include?(Char.prof) and
      percentstance < 80
    end

    def apply
      fput "stance guarded"
    end
  end
end