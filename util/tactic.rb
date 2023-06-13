module Tactic
  module Nouns
    Dagger   = %w(dagger dirk knife tanto)
    Edged    = Dagger + %w(sword shortsword axe hatchet wakizashi kris coustille)
    Ranged   = %w(bow longbow crossbow)
    Polearms = %w(spear harpoon longhammer)
    Shields  = %w(buckler targe shield)
  end

  def self.can?(method)
    Skills.send(method) > 1.5 * Char.level
  end

  def self.ranged?
    Nouns::Ranged.include?(Char.left.noun) && self.can?(:rangedweapons)
  end

  def self.edged?
    Nouns::Edged.include?(Char.right.noun) && self.can?(:edgedweapons)
  end

  def self.polearms?
    Nouns::Polearms.include?(Char.right.noun) && self.can?(:polearmweapons)
  end

  def self.brawling?
    Char.left.nil? && Char.right.nil? && self.can?(:brawling)
  end

  def self.shield?
    Nouns::Shields.include?(Char.left.noun) && self.can?(:shielduse)
  end

  def self.thrown?
    Shiva::Config.thrown_weapon && self.can?(:thrownweapons) && Char.right.name.eql?(Shiva::Config.thrown_weapon)
  end

  def self.twc?
    Nouns::Edged.include?(Char.left.noun) && self.can?(:edgedweapons) && self.can?(:twoweaponcombat)
  end

  def self.dagger?
    self.edged? && Nouns::Dagger.include?(Char.right.noun)
  end

  def self.death_metal?
    Char.right.name.include?("xazkruvrixis")
  end
end