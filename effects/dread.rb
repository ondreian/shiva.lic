module Dread
  def self.status
    Effects::Debuffs.to_h.keys.map(&:to_s)
      .find {|k| k.include? "Dread"}.match(/\((\d+)\)/)[1].to_i
  end
end