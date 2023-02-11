module Shiva
  class Ewave < Action
    def which()
      return Spell[435] if Spell[435].known? and Spell[435].affordable? and percentmana > 50
      return Spell[410]
    end

    def priority
      Char.prof.eql?("Rogue") ? 5 : 90
    end

    def ttl
      @ttl ||= Time.now - 1
    end

    def valid_foes
      self.env.foes.reject {|f| f.name =~ /vvrael|crawler|cerebralite/i}
    end

    def available?()
      self.which.known? and
      self.which.affordable? and
      #not hidden? and
      percentmana > 40 and
      self.env.foes.size > 2 and
      self.valid_foes.map(&:status).select(&:empty?).size > 1 and
      self.env.foes.map(&:status).reject(&:empty?).size > 2 and
      Time.now > self.ttl
    end

    def apply(foe)
      fput "prep %s\rcast #%s" % [self.which.num, GameObj.inv.sample.id]
      @ttl = Time.now + 10
    end
  end
end