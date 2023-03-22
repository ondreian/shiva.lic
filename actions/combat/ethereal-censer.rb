module Shiva
  class EtherealCenser < Action
    def priority
      89
    end

    def available?(foe)
      not Effects::Cooldowns.active?("Ethereal Censer") and
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
      ttl = Time.now + 2
      wait_until {Effects::Cooldowns.active?("Ethereal Censer") or Time.now > ttl}
    end
  end
end