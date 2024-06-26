module Shiva
  class Quickening < Action
    NAME     = "shiva/sanctum/quickening"
    ATTACK   = /The <a exist="(\d+)" noun="(?<snake>[a-z]+)">(?:[a-z]+)<\/a> wriggles down your arm/
    FAIL     = /but your interference only enrages it!/
    SUCCESS  = /twisting violently until you hear something snap!/
    OUTCOMES = Regexp.union(FAIL, SUCCESS)
    @@snake  = nil

    def self.register()
      Shiva::Hook.register(:quickening) do |str|
        Quickening.parse(str)
      end
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
      Priority.get(:high)
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