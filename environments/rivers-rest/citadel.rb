module Shiva
  Environment.define :citadel do
    @entry   = 11359
    @level   = (60..70)
    @town    = %[River's Rest]
    @scripts = %w(reaction)
    @foes    = %w(apprentice guardsman arbalester herald swordsman)
    @boundaries = %w(11358 11338 11265)
  end
end