module Shiva
  Environment.define :sanctum do
    @entry   = nil
    @town    = %[Solhaven]
    @scripts = %w(reaction lte effect-watcher)
    @foes    = %w(shaper sidewinder sentinel fanatic lurk monstrosity)
  end
end