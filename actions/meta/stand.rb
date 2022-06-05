module Shiva
  class Stand < Action
    def priority
      Priority.get(:high)
    end

    def available?
      not standing? and 
      not muckled? and 
      not Effects::Debuffs.active?("Jaws")
    end

    def apply()
      fput "stand"
    end
  end
end