module Shiva
  module Location
    def self.nearest_town
      Room[Room.current.find_nearest_by_tag("town")].location
    end
  end
end