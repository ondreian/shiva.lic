module Shiva
  module Conditions
    module Hypothermia
      def self.status
        Effects::Debuffs.to_h.keys.map(&:to_s)
          .find {|k| k.start_with? "Hypothermia"}.match(/\((\d+)\)/)[1].to_i
      end

      def self.handle!
        wait_while("waiting on hypothermia") {self.status > 0}
      end
    end
  end
end