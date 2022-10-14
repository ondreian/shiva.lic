module Shiva
  class Sympathy < Action
    def which()
      Spell[1120]
    end

    def priority
      7
    end

    def ttl
      @ttl
    end

    def available?()
      self.which.known? and
      self.which.affordable? and
      not hidden? and
      percentmana > 10 and
      self.env.foes.size > 2 and
      self.env.foes.map(&:status).select(&:empty?).size > 2 and
      Time.now > self.ttl
    end

    def apply(foe)
      fput "prep %s\rcast #%s" % [self.which.num, GameObj.inv.sample.id]
      @ttl = Time.now + 10
    end
  end
end