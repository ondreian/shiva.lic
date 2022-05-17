module Shiva
  Environment.define :woodsmen do
    @entry   = 9033
    @town    = %[Solhaven]
    @scripts = %w(reaction lte effect-watcher)
    @foes    = %w(woodsman wight)
    @boundaries = %w(5063)
  end
end