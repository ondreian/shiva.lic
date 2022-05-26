module Shiva
  class BroochOfLumnis < Action
    @@used ||= false

    module Outcomes
      Ok  = %r[Within seconds, you feel Lumnis' Vigor course through your veins.]
      Err = %r[The quintuple orb brooch ebbs weakly, but nothing further happens.]
      All = Regexp.union(Ok, Err)
    end

    def priority
      3
    end

    def day
      Time.now.day.to_s + ":" + Time.now.month.to_s
    end

    def brooch
      GameObj.inv.find {|i| i.name.eql?("quintuple orb brooch")}
    end

    def used
      @@used
    end

    def available?
      not brooch.nil? and
      !@@used.eql?(self.day) and
      not Script.running?("lte") and
      percentmind >= 100
    end

    def axp
      Vars["shiva/axp"] || 100
    end

    def exp
      Vars["shiva/exp"] || 0
    end

    def set_asc(amount)
      times = amount.to_s == "0" ? 1 : 2
      times.times {fput "asc set %s" % amount}
    end

    def apply()
      self.set_asc self.axp
      waitrt?
      case dothistimeout("rub #%s" % self.brooch.id, 5, Outcomes::All)
      when Outcomes::Ok
        :ok
      when Outcomes::Err
        Log.out("used for the day!", label: %i(brooch))
        @@used = self.day
      end
      self.set_asc self.exp
    end
  end
end