module Shiva
  class EmpathicLink < Action
    def priority
      9
    end

    def available?
      not @env.foes.any? {|foe| @env.seen.include?(foe.id) } and
      @env.foes.size > 2 and
      Spell[1117].known? and
      Spell[1117].affordable?
    end

    def apply()
      fput "incant 1117"
      @env.foes.each {|foe| @env.seen << foe.id}
      waitcastrt?
    end
  end
end