module Shiva
  module Support
    def self.sigil_of_power()
      return unless Society.status.eql?("Guardians of Sunfist")
      return if percentmana > 80
      (checkstamina/50).times do fput "sigil power" end
    end

    def self.small_statue
      return self unless Char.spell(1712).minutes < 8
      Containers.harness.where(name: "small statue").first.use do |item| fput "rub ##{item.id}" end
      waitcastrt?
    end

    def self.pure_potion
      return self unless Char.spell(211).minutes < 8
      Containers.harness.where(name: "pure potion").first.use do |potion| 
        fput "drink ##{potion.id}" 
      end
      waitcastrt?
    end

    def self.quartz_orb()
      return self if Spell[1711].active?
      Containers.harness.where(name: "heavy quartz orb").first.use do |orb| fput "rub ##{orb.id}" end
      waitcastrt?
    end

    def self.haste
      return unless Spell[506].known? or Spell[1035].known?
      return if Spell[506].known? and Spell[506].active?
      return if Spell[1035].known? and Spell[1035].active?
      Stance.defensive
      Spell[506].cast unless Spell[506].active? || !Spell[506].known?
      Spell[1035].cast unless Spell[1035].active? || !Spell[1035].known?
    end
  end
end