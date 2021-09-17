module Shiva
  class Ewave < Action
    def priority
      5
    end

    def available?(foe)
      not foe.nil? and
      Spell[410].known? and
      Spell[410].affordable? and
      not hidden? and
      percentmana > 60 and
      @env.foes.size > 1 and
      @env.foes.map(&:status).select(&:empty?).size > 2
    end

    def apply(foe)
      fput "prep 410\rcast #%s" % GameObj.inv.sample.id
    end
  end
end