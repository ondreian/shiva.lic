module Shiva
  class EmpathicLink < Action
    def priority
      9
    end

    def available?
      not self.env.foes.any? {|foe| self.env.seen.include?(foe.id) } and
      self.env.foes.size > 2 and
      Spell[1117].known? and
      Spell[1117].affordable?
    end

    def apply()
      fput "incant 1117"
      self.env.foes.each {|foe| self.env.seen << foe.id}
      waitcastrt?
    end
  end
end