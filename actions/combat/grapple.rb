module Shiva
  class Grapple < Action
    def priority
      90
    end

    def should?(foe)
      return true if foe.type =~ /bandit/
      return true if foe.status.empty?
      return false
    end

    def available?(foe)
      not foe.nil? and
      Lich::Claim.mine? and
      Tactic.uac? and
      hidden? and
      self.should?(foe)
    end

    def grapple(foe)
      dothistimeout "grapple #%s neck" % foe.id, 1, %r{You make a precise attempt to grapple}
    end

    def apply(foe)
      return self.grapple foe
    end
  end
end