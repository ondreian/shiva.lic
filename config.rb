module Shiva
  module Config
    def self.to_array_of_names(str, fallback = "")
      (str || fallback).split(",").map(&:strip)
    end

    def self.get(name)
      Vars["shiva/#{name}"]
    end

    def self.set(name, value)
      Vars["shiva/#{name}"] = value
    end

    def self.town
      self.get(:town)
    end

    def self.bases
      configured_bases = self.get(:bases)
      return nil unless configured_bases
      configured_bases.split(",").map(&:to_i)
    end

    def self.flee(fallback = %(monstrosity))
      self.to_array_of_names(self.get(:flee), fallback)
    end

    def self.healers(fallback =  %(Pixelia, Dithio, Scarface))
      self.to_array_of_names(self.get(:healers), fallback)
    end

    def self.picker
      self.get(:picker)
    end

    def self.exp
      self.get(:exp)
    end

    def self.axp
      self.get(:axp)
    end

    def self.escort(fallback = "")
      self.get(:escort) || fallback
    end

    def self.main_weapon
      self.get(:main)
    end

    def self.offhand_weapon
      self.get(:main)
    end

    def self.shield
      self.get(:shield)
    end

    def self.ranged_weapon
      self.get(:ranged)
    end

    def self.swap_tactics?
      self.get(:swap)
    end

    def self.support_bravery?
      not self.get(:bravery).nil?
    end

    def self.use_boost?
      self.get(:boost)
    end
  end
end