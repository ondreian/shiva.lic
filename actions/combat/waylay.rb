module Shiva
  class Waylay < Action
    Nouns = %w(monstrosity crusader golem psionicist protector automaton grotesque)

    def priority(foe)
      return 100 unless Tactic.edged?
      if Nouns.include?(foe.noun) or self.skinning?(foe)
        89
      else
        100
      end
    end

    def skinning?(foe)
      false
    end

    def has_melee_skill?
      Tactic.polearms? or Tactic.edged?
    end

    def conditions?
      self.has_melee_skill? and
      Skills.ambush > Char.level * 1.5 and
      hidden?
    end

    def available?(foe)
      not foe.nil? and
      self.conditions?
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