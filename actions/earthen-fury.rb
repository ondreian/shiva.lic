module Shiva
  class EarthenFury < Action
    def priority
      90
    end

    def available?(foe)
      not foe.nil? and
      not foe.name.include?("Vvrael") and
      Spell[917].known? and
      Spell[917].affordable? and
      checkmana > 20 and
      Wounds.nsys < 2
    end

    Ok = %r{suddenly frosts and rumbles violently!}
    Err = Regexp.union(%r{dissipating it harmlessly.})
    Outcomes = Regexp.union(Ok, Err)

    def apply(foe)
      Stance.guarded
      case dothistimeout "target #%s\rincant 917" % foe.id, 3, Outcomes
      when Ok
        @env.seen << foe.id
      end

      if Spell[515].active?
        sleep 0.5
      else
        waitcastrt?
      end
    end
  end
end