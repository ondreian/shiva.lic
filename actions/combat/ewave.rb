module Shiva
  class Ewave < Action
    def which()
      return Spell[435] if Spell[435].known? and Spell[435].affordable? and percentmana > 50
      return Spell[410]
    end

    def priority
      Char.prof.eql?("Rogue") ? 10 : 90
    end

    def ttl
      @ttl ||= Time.now - 1
    end

    def available?()
      self.which.known? and
      self.which.affordable? and
      not hidden? and
      percentmana > 10 and
      self.env.foes.size > 2 and
      self.env.foes.reject {|f| f.name =~ /vvrael|crawler|cerebralite/i}.map(&:status).select(&:empty?).size > 1 and
      self.env.foes.select {|f| f.status.empty? }.size > self.env.foes.size * 0.7 and
      Time.now > self.ttl
    end

    def apply(foe)
      fput "prep %s\rcast #%s" % [self.which.num, GameObj.inv.sample.id]
      @ttl = Time.now + 10
    end
  end
end