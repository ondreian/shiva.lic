module Shiva
  class SwapWeapon < Action
    def priority
      Priority.get(:medium)
    end

    def available?(foe)
      return false

      #Config.swap_tactics? and
      #self.needs_swap?(foe) and
      #self.env.name.eql?(:sanctum)
    end

    def needs_swap?(foe)
      case foe.noun
      when "shaper"
        Char.right.name !~ /kroderine/
      else
        Char.right.name !~ /xazkruvrixis/
      end
    end

    def ondreian(foe)
      case foe.noun
      when "shaper"
        Containers.harness.where(name: /kroderine dagger/).first.take
      else
        Containers.harness.where(name: /xazkruvrixis dirk/).first.take
      end
    end

    def apply(foe)
      waitrt?
      Containers.harness.add(Char.right)
      case Char.name
      when "Ondreian"
        self.ondreian(foe)
      end
    end
  end
end