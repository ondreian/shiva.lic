module Shiva
  class Berserk < Action
    def priority
      if self.break_out?
        -100
      else
        (90...110).to_a.sample
      end
    end

    def break_out?
      muckled? or stunned? or Effects::Debuffs.active?("Net")
    end

    def available?
      return true if Spell["Berserk"].active?
      not Spell[1035].active? and
      CMan.berserk > 5 and
      Char.stamina > 35 and
      self.break_out? and
      Group.empty?
    end

    def apply(_foe)
      waitrt?
      fput "berserk" unless Spell["Berserk"].active?
      ttl = Time.now + 3
      wait_until {Spell["Berserk"].active? or Time.now > ttl}
      loop do
        ttl = Time.now + 3
        wait_while {Spell["Berserk"].active? or Time.now < ttl}
        fput "stop berserk" #unless self.env.stage.eql?(:main)
        break unless Spell["Berserk"].active?
      end
    end
  end
end