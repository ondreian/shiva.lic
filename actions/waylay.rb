module Shiva
  class Waylay < Action
    def priority(foe)
      if foe.noun.eql?("monstrosity") or (foe.noun.eql?("destroyer") && self.dagger?)
        89
      else
        100
      end
    end

    def dagger?
      %w(knife dagger dirk coustille).include?(Char.right.noun)
    end

    def has_melee_skill?
      Skills.polearmweapons > Char.level * 1.5 or
      Skills.edgedweapons > Char.level * 1.5
    end

    def available?(foe)
      not foe.nil? and
      hidden? and
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