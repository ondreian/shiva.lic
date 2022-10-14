module Voln
  def self.available?
    Society.status =~ /Voln/ && Society.rank.eql?(26)
  end

  def self.fog
    return unless self.available?
    waitcastrt?
    waitrt?
    from_id = Room.current.id
    fput "symbol return"
    ttl = Time.now + 2
    wait_while {Room.current.id.eql?(from_id) and Time.now < ttl}
  end
end