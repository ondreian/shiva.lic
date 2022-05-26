module Shiva
  Environment.define :plane4 do
    @entry      = 12145
    @town       = %[Icemule Trace]
    @scripts    = %w(reaction lte effect-watcher)
    @foes       = %w(crawler crusader cerebralite)
    @boundaries = %w(12122 12207 12235)

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