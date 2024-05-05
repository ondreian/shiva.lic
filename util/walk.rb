module Shiva
  module Walk
    def self.apply()
      starting_room = Room.current.id
      Walk.away
      yield
      Script.run("go2", starting_room.to_s) unless Room.current.id.eql?(starting_room)
    end

    def self.away
      return unless checkpaths
      until GameObj.targets.empty? do walk end
    end
  end
end