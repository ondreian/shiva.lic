module Shiva
  Environment.define :glatoph do
    @entry   = 2567
    @level   = (30..40)
    @town    = %[Landing]
    @scripts = %w(reaction)
    @foes    = %w(titan giant crone)
    @boundaries = %w(2568 2557)
  end
end