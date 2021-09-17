module Shiva
  class Quickening < Action
    NAME     = ":quickening"
    ATTACK   = /The <a exist="(\d+)" noun="(?<snake>[a-z]+)">(?:[a-z]+)<\/a> wriggles down your arm/
    FAIL     = /but your interference only enrages it!/
    SUCCESS  = /twisting violently until you hear something snap!/
    OUTCOMES = Regexp.union(FAIL, SUCCESS)
    @@snake  = nil

    def self.register()
      DownstreamHook.add(NAME, Proc.new do |str|       
        Quickening.parse(str)
        str
      end)
    
      before_dying do DownstreamHook.remove(NAME) end
    end

    def self.parse(str)
      if result = str.match(ATTACK)
        Quickening.active(result[:snake])
      end
    end
  
    def self.active(snake)
      @@snake = snake
      self
    end
  
    def self.active?
      !@@snake.nil?
    end
  
    def self.counter()
      while active?
        result = dothistimeout("clench #{@@snake}", 1, OUTCOMES)
        waitrt?
        @@snake = nil if result =~ SUCCESS
      end
      self
    end

    def priority
      1
    end

    def available?
      Quickening.active?
    end

    def apply
      Quickening.counter
    end
  end

  Quickening.register()
end