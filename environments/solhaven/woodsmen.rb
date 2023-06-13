module Shiva
  Environment.define :woodsmen do
    @entry   = 9033
    @level   = (20..30)
    @town    = %[Solhaven]
    @scripts = %w(reaction)
    @foes    = %w(woodsman wight)
    @boundaries = %w(5063)
  end
end