module Shiva
  class Ewave < Action
    def priority
      Char.prof.eql?("Rogue") ? 10 : 90
    end

    def available?()
      Spell[410].known? and
      Spell[410].affordable? and
      not hidden? and
      percentmana > 10 and
      self.env.foes.size > 2 and
      self.env.foes.reject {|f| f.name =~ /vvrael|crawler|cerebralite/i}.map(&:status).select(&:empty?).size > 1 and
      self.env.foes.select {|f| f.status.empty? }.size > self.env.foes.size * 0.7 and
      (@ttl and Time.now > @ttl)
    end

    def apply(foe)
      fput "prep 410\rcast #%s" % GameObj.inv.sample.id
      @ttl = Time.now + 10
    end
  end
end