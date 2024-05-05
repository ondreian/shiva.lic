module Shiva
  module Arms
    def self.use
      Log.out("called", label: %i(arms use))
      return if Tactic.uac?
      Char.arm
    end

    def self.away
      Char.unarm
    end
  end
end
