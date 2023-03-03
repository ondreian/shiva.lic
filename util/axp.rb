module Shiva
  module Axp
    def self.axp
      Config.axp || 100
    end

    def self.exp
      Config.exp || 0
    end

    def self.set_asc(amount)
      times = amount.to_s == "0" ? 1 : 2
      times.times {fput "asc set %s" % amount}
    end

    def self.apply()
      self.set_asc self.axp
      yield
      self.set_asc self.exp
    end
  end
end