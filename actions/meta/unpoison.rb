module Shiva
  class Unpoison < Action

    def priority
      Priority.get(:high)
    end

    def effected?
      Effects::Debuffs.to_h.any? {|k, v| k =~ /Wall of Thorns/i}
    end

    def available?
      Spell[114].known? and
      self.effected?
    end

    def apply()
      waitrt?
      waitcastrt?
      fput "prep 114\rchannel"
      waitcastrt?
      waitrt?
    end
  end
end