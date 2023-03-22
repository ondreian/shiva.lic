module Shiva
  class Ewave < Action
    Major = Spell[435]
    Minor = Spell[410]

    def self.which()
      return Major if Major.known? and Major.affordable? and percentmana > 50
      return Minor
    end

    def priority
      1 if Effects::Debuffs.active?("Jaws")
      Char.prof.eql?("Rogue") ? 5 : 90
    end

    def ttl
      @ttl ||= Time.now - 1
    end

    def valid_foes
      self.env.foes.reject {|f| f.name =~ /vvrael|crawler|cerebralite/i}
    end

    def available?
      Ewave.which.known? and
      Ewave.which.affordable? and
      not hidden? and
      percentmana > 40 and
      self.env.foes.size > 2 and
      self.valid_foes.map(&:status).select(&:empty?).size > 1 and
      self.env.foes.map(&:status).reject(&:empty?).size > 2 and
      Time.now > self.ttl
    end

    def apply
      fput "prep %s\rcast #%s" % [self.which.num, GameObj.inv.sample.id]
      @ttl = Time.now + 10
    end
  end
end