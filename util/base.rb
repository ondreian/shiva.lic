module Shiva
  module Base
    DefaultBases = [
      18698, # Oberwood
      29881, # Hinterwilds
      29623, # Kraken's Fall
      23780, # Duskruin Sands
    ]
    
    def self.bases
      return DefaultBases unless Vars["shiva/bases"]
      Vars["shiva/bases"].split(",").map(&:to_i)
    end

    def self.closest
      Room.current.find_nearest(self.bases)
    end
    
    def self.go2
      return :noop if Room.current.id.eql?(self.closest)
      if Group.empty?
        Char.unhide if hidden?
        Script.run("go2", self.closest.to_s)
      else
        $cluster_cli.stop("shiva") if Group.leader? and not Group.empty?
        Script.run("rally", self.closest.to_s)
        fput "disband"
      end
      Team.request_healing if Char.total_wound_severity > 0 or percenthealth < 100
      wait_while("waiting on healing") {Char.total_wound_severity > 1}
    end
  end
end