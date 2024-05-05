module Shiva
  class BroochOfLumnis < Action
    @@used ||= false
    @@planar_used ||= false

    def self.used?
      @@used
    end

    def self.planar_used?
      @@planar_used
    end

    module Outcomes
      Ok  = %r[Within seconds, you feel Lumnis' Vigor course through your veins.]
      Err = %r[The quintuple orb brooch ebbs weakly, but nothing further happens.]
      All = Regexp.union(Ok, Err)
    end

    def priority
      Priority.get(:high)
    end

    def planar
      return if @@planar_used
      multifput "whisper my brooch planar", "rub my brooch", "whisper my brooch spirit"
      @@planar_used = true
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

    def apply()
      self.planar
      return if percentmind < 100
      Axp.apply {
        waitrt?
        case dothistimeout("rub #%s" % self.brooch.id, 5, Outcomes::All)
        when Outcomes::Ok
          :ok
        when Outcomes::Err
          Log.out("used for the day!", label: %i(brooch))
          @@used = self.day
          Script.start("lte")
        end
      }
    end
  end
end