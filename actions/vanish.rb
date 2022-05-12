module Shiva
  class Vanish < Action
    def priority
      1
    end

    def available?
      Char.prof.eql?("Rogue") and
      checkrt > 10 and
      self.env.foes.size > 1 and
      checkstamina > 50 and
      not muckled? and
      not hidden?
    end

    def apply()
      fput "feat vanish"
    end
  end
end