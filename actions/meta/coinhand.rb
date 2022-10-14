module Shiva
  class Coinhand < Action

    attr_accessor :gained_silver

    def initialize(*args)
      super(*args)
      @gained_silver = false
      self.attach()
    end

    def attach
      coinhand = self
      DownstreamHook.add("coinhand/watcher", -> line {
      begin
        coinhand.gained_silver = true if line.start_with?("You gather the remaining")
      rescue => exception
        Log.out(exception)
      ensure
        return line
      end
    })
    end

    def gained_silver?
      @gained_silver
    end

    def hand
      GameObj.inv.find {|item| item.noun.eql?("hand")}
    end

    def priority
      6
    end

    def available?
      self.env.foes.empty? and
      !self.hand.nil? and
      self.gained_silver?
    end

    def apply
      waitrt?
      fput "close #%s" % self.hand.id
      @gained_silver = false
    end
  end
end