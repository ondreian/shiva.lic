module Shiva
  class Ewave < Action
    def priority
      79
    end

    def available?(foe)
      not foe.nil? and
      Spell[410].known? and
      Spell[410].affordable? and
      not hidden? and
      percentmana > 10 and
      @env.foes.size > 1 and
      @env.foes.reject {|f| f.name =~ /vvrael|crawler|cerebralite/i}.map(&:status).select(&:empty?).size > 1 and
      (@ttl and Time.now > @ttl)
    end

    def apply(foe)
      fput "prep 410\rcast #%s" % GameObj.inv.sample.id
      @ttl = Time.now + 10
    end
  end
end