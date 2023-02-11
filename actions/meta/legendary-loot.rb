# 

module Shiva
  class LegendaryTreasure < Action
    Messaging = %[A prismatic display of color tints the air around you and arcs away, heralding your discovery of a legendary treasure!]

    attr_accessor :found_legendary, :timestamp

    def initialize(*args)
      super(*args)
      @found_legendary = false
      @timestamp       = nil
      self.attach()
    end

    def attach
      handler = self
      DownstreamHook.add("shiva/legendary-treasure", -> line {
        begin
          if line.include? Messaging
            handler.found_legendary = true
            handler.timestamp = Time.now
          end
        rescue => exception
          Log.out(exception)
        ensure
          return line
        end
      })
    end

    def found_legendary?
      @found_legendary
    end

    def priority
      -1
    end

    def available?
      self.found_legendary?
    end

    def reliquary
      GameObj.loot.find {|o| o.noun.eql?("reliquary")}
    end

    def notify
      return unless defined? Notify
      Notify::Sounds.play %[big_loot]
      Notify.notify(body: "You found a legendary!", type: :legendary, from: :shiva)
      Notify::Sounds.play %[big_loot]
    end

    def apply
      waitrt?
      fput "stow left"
      fput "get #%s" % self.reliquary.id if self.reliquary
      self.notify
      exit
    end
  end
end