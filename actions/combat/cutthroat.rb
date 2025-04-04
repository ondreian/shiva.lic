module Shiva
  class Cutthroat < Action
    Cutthroat = []
    Immune    = %w(
      crawler banshee cerebralite golem 
      hinterboar grotesque conjurer ooze 
      oozeling undansormr disir angargeist
      elemental
    )
    DeathMetal = %w(mastodon cannibal shield-maiden crusader destroyer)

    def priority
      61
    end

    def cost
      return 0 if Effects::Buffs.active?("Shadow Dance")
      #return 0 if Effects::Buffs.active?("Stamina Second Wind")
      return 20
    end

    def reachable?(foe)
      not foe.tall? or foe.prone? or foe.status.include?(:frozen)
    end

    def reasonable?(foe)
      return false if Immune.include?(foe.noun)
      return false if foe.name.include?("gigas")
      return false if %w(mutant draugr).include?(foe.noun) and foe.status.empty?
      return Tactic.death_metal? if DeathMetal.include?(foe.noun)
      return true
    end

    def available?(foe)
      Char.prof.eql?("Rogue") and
      not self.env.name.eql?(:duskruin) and
      checkstamina > self.cost and
      Tactic.edged? and
      hidden? and
      not foe.nil? and
      foe.status.empty? and
      not foe.type.include?("noncorporeal") and
      not Cutthroat.include?(foe.id) and
      self.reachable?(foe) and
      self.reasonable?(foe)
    end

    def cutthroat(foe)
      Log.out("{foe=%s, cost=%s}" % [foe.name, self.cost], label: %i(cutthroat))
      return if checkstamina < self.cost
      Stance.offensive
      result = dothistimeout "cman cutthroat #%s" % foe.id, 1, Regexp.union(
        %r[You slice deep into],
        %r{is out of reach!},
        %r[wait],
      )
      Cutthroat << foe.id if result =~ %r[You slice deep into|out of reach]
      sleep 0.5
      Timer.await() if checkrt > 6
    end

    def apply(foe)
      return self.cutthroat foe
    end
  end
end