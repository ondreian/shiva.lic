module Shiva
  Environment.define :sanctum do
    @entry      = 25172
    @boundaries = %w(25177 25158 25231)
    @town       = %[Solhaven]
    @scripts    = %w(reaction lte effect-watcher)
    @foes       = %w(shaper sidewinder sentinel fanatic lurk monstrosity)
  end
end