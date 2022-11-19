class Creature
  module Nouns
    Tall = /golem|mastodon|troll|hinterboar|titan|gigas|massive\s|mammoth|yeti|grahnk|giant\b|cyclops|monstrosity|construct/
  end

  def tall?
    return false if self.prone?
    return false if self.status.include?(:frozen)
    self.name =~ Nouns::Tall
  end
end