module Aiming
  Head    = %i(head neck back)
  Eyes    = %i(left_eye right_eye head neck)
  Default = Head

  def self.lookup(foe)
    return Head   if %w(crawler siphon).include?(foe.noun)
    return Head   if foe.name =~ /cyclops/
    #return Eyes   if foe.name.include?("cerebralite") 
    #return Eyes   if %w(spear harpoon).include?(Char.right.noun)
    #return Eyes   if %w(dagger dirk tanto).include?(Char.right.noun)
    return Eyes
  end
end