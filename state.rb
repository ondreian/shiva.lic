module Shiva
  module State
    module States
      Hunting = :hunting
      Resting = :resting
      Done    = :done
      Pending = :pending
    end

    @@state = States::Pending

    def self.set(state)
      @@state = state
    end

    def self.get
      return States::Done unless Script.running?("shiva")
      @@state
    end

    def self.hunting?
      self.get.eql? States::Hunting
    end

    def self.resting?
      self.get.eql? States::Resting
    end
  end
end