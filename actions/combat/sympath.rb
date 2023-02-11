module Shiva
  class Sympathy < Action
    def spell()
      Spell[1120]
    end

    def priority
      7
    end

    def ttl
      @ttl || Time.now - 1
    end

    def available?()
      self.spell.known? and
      self.spell.affordable? and
      percentmana > 10 and
      self.env.foes.size > 1 and
      self.env.foes.reject(&:undead?).map(&:status).select(&:empty?).size > 1 and
      Time.now > self.ttl
    end

    def apply(foe)
      fput "prep %s\rcast #%s" % [self.spell.num, GameObj.inv.sample.id]
      @ttl = Time.now + 10
    end
  end
end