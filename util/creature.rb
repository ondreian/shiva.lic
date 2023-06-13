class Creature
  module Nouns
    Tall = /golem|mastodon|troll|hinterboar|titan|gigas|massive\s|mammoth|yeti|grahnk|giant\b|cyclops|monstrosity|construct/
  end

  def tall?
    return false if self.prone?
    return false if self.status.include?(:frozen)
    self.name =~ Nouns::Tall
  end

  def effects
    return self.status unless defined? CreatureEffects
    self.status + CreatureEffects.lookup(self.id)
  end

  def cutthroat?
    self.effects.include?(:cutthroat)
  end
end