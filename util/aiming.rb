module Aiming
  Head    = %i(head neck back)
  Eyes    = %i(left_eye right_eye head neck)
  NonCorp = %i(back chest)
  Default = Head

  def self.lookup(foe)
    return NonCorp if foe.name =~ /spectral|ethereal|fallen crusader/
    return %i(neck back chest) if %w(dreadsteed).include?(foe.noun) and not Tactic.uac?
    return Head   if %w(crawler siphon).include?(foe.noun)
    return Head   if Tactic.uac?
    return Head   if foe.name =~ /cyclops/
    return Eyes.reject {|loc| %i(neck).include?(loc)} if foe.name.include?("cerebralite")
    return Head   if %w(axe hatchet longhammer).include?(Char.right.noun)
    #return Eyes   if %w(spear harpoon).include?(Char.right.noun)
    #return Eyes   if %w(dagger dirk tanto).include?(Char.right.noun)
    return Eyes
  end
end