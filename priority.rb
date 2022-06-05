module Shiva
  module Priority
    High    = 1
    Medium  = 10
    Low     = 100

    def self.get(kind)
      case kind
      when :high
        High
      when :medium
        Medium
      when :low
        Low
      else
        kind
      end
    end
  end
end