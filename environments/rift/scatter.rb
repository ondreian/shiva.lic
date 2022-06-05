module Shiva
  Environment.define :scatter do
    @entry      = 12240
    @town       = %[Icemule Trace]
    @scripts    = %w(reaction lte effect-watcher)
    @foes       = %w(crawler siphon master destroyer cerebralite doll)
    @boundaries = %w(12151 12254 12256 12249 12247 12241)

    def self.before_teardown
      return unless Society.status =~ /Voln/ && Society.rank.eql?(26)
      waitcastrt?
      waitrt?
      from_id = Room.current.id
      fput "symbol return"
      ttl = Time.now + 2
      wait_while {Room.current.id.eql?(from_id) and Time.now < ttl}
    end
  end
end