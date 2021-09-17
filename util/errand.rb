module Shiva
  module Errand
    def self.go2(id)
      Script.run("go2", "%s" % id)
      ttl = Time.now + 3
      wait_until {Room.current.id.eql?(id) or Room.current.tags.include?(id) or Time.now > ttl}
      fail "error traveling to %s" % id unless Room.current.id.eql?(id) or Room.current.tags.include?(id)
    end

    def self.run(target_id)
      fail "target cannot be nil" if target_id.nil?
      starting_room_id = Room.current.id
      go2(target_id)
      outcome = yield
      go2(starting_room_id)
      return outcome
    end
  end
end