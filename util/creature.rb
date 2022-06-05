class Creature
  def tall?
    self.name =~ /golem|mastodon|hinterboar|titan|gigas|massive\s|mammoth|yeti|giant\b|cyclops|monstrosity|construct/
  end
end