module Shiva
  module Seek
    def self.select_way(room, denied)
      room.wayto.reject {|k, v| denied.include?(k.to_s)}.sample
    end
  end
end