class Creature
  def tall?
    self.name =~ /mammoth|yeti|giant\b|cyclops|monstrosity|construct/
  end
end