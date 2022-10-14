module Shiva
  module Forage
    def self.bounty_rooms
      Map.list
        .select {|r| r.location.eql? Bounty.area}
        .select {|r| r.tags.include? Bounty.herb }
        .shuffle
    end
    
    def self.bounty
      
    end
  end
end