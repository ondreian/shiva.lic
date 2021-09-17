module Shiva
  module Location
    def self.nearest_town
      Room[Room.current.find_nearest_by_tag("town")].location
    end

    Oberwood = 18698
    HandOfArkati = 29623
    Bases = [Oberwood, HandOfArkati]

    def self.resting_room
      return Vars["shiva/base"] if Vars["shiva/base"]
      Room.current.find_nearest(Bases).to_s
    end
  end
end