module Shiva
  Environment.define :fenghai do
    @entry   = 5251
    @level   = (20..30)
    @town    = %[Solhaven]
    @scripts = %w(reaction)
    @foes    = %w(fenghai)
    @boundaries = %w(5250 5637)
  end
end