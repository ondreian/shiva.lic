module Shiva
  class Berserk < Action
    def priority
      if muckled? or stunned? or Effects::Debuffs.active?("Net")
        0
      else
        (90...110).to_a.sample
      end
    end

    def available?
      return true if Spell["Berserk"].active?
      not Spell[1035].active? and
      CMan.berserk > 5 and
      Char.stamina > 35 and
      muckled? and
      Group.empty?
    end

    def apply(_foe)
      waitrt?
      fput "berserk" unless Spell["Berserk"].active?
      ttl = Time.now + 3
      wait_until {Spell["Berserk"].active? or Time.now > ttl}
      loop do
        sleep 0.1
        fput "stop berserk" #unless self.env.stage.eql?(:main)
        break unless Spell["Berserk"].active?
      end
    end
  end
end