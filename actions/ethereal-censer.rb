module Shiva
  class EtherealCenser < Action
    def priority
      89
    end

    def available?(foe)
      not Effects::Buffs.active?("Ethereal Censer") and
      not foe.nil? and
      not foe.name.include?("Vvrael") and
      Spell[320].known? and
      Spell[320].affordable?
    end

    def apply(foe)
      Stance.guarded
      fput "target #%s\rincant 320\rstance guard" % foe.id
      waitcastrt? unless Spell[515].active?
    end
  end
end