require 'ostruct'
require 'oga'

module Shiva
  module Move
    

    def self.call(way)
      move way, 2, 10
    end
  
    def self.rand(ways, peer: false)
      way = ways.sample
      if peer
        peered = Peer.call(way)
        return if yield if block_given?
        unless peered.pcs.empty?
          sleep 1
          return self.rand(ways, peer: true) 
        end
      end

      self.call(way)
    end
  end
end