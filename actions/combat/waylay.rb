module Shiva
  class Waylay < Action
    Nouns = %w(monstrosity destroyer crusader golem psionicist protector automaton grotesque)

    def priority(foe)
      if Nouns.include?(foe.noun) && self.dagger?
        89
      else
        100
      end
    end

    def dagger?
      %w(knife dagger dirk coustille).include?(Char.right.noun)
    end

    def has_melee_skill?
      Tactic.polearms? or Tactic.edged?
    end

    def available?(foe)
      not foe.nil? and
      self.has_melee_skill? and
      Skills.ambush > Char.level * 1.5 and
      hidden?
    end

    def waylay(foe)
      #Char.aim :clear
      Timer.await()
      Stance.offensive
      if Effects::Buffs.active?("Shadow Dance") && hidden?
        fput "feat silentstrike waylay #%s clear" % foe.id
      else
        fput "waylay #%s clear" % foe.id
      end
    end

    def apply(foe)
      return self.waylay foe
    end
  end
end