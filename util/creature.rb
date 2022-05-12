class Creature
  def tall?
    self.name =~ /titan|giga|massive\s|mammoth|yeti|giant\b|cyclops|monstrosity|construct/
  end
end