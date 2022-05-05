module Shiva
  class SwapWeapon < Action
    def priority
      5
    end

    def available?(foe)
      %w(Ondreian).include?(Char.name) and
      self.needs_swap?(foe) and
      @env.namespace.eql?(Duskruin).eql?(Sanctum)
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