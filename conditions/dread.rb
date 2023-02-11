module Shiva
  module Conditions
    module Dread
      def self.creeping
        Effects::Debuffs.to_h.keys.map(&:to_s)
          .find {|k| k.include? "Creeping Dread"}.match(/\((\d+)\)/)[1].to_i
      end

      def self.crushing
        Effects::Debuffs.to_h.keys.map(&:to_s)
          .find {|k| k.include? "Crushing Dread"}.match(/\((\d+)\)/)[1].to_i
      end
    end
  end
end