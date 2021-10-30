module Shiva
  class StanceGuarded < Action
    def priority
      2
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