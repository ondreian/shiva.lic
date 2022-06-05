module Shiva
  class WeightlessCoinbag < Action
    def bag
      Vars["coinbag"] && GameObj.inv.find {|i| i.name.eql?(Vars["coinbag"])}
    end

    def full?
      self.bag and @state = :full
    end

=begin
    module Bag
      module Silvers
        FIND    = /You gather the remaining (?<silver>\d+) coins\.$/
        RM      = /You reach into your #{BAG_STR} and remove (?<silver>\d+) silver coins\.$/
        ADD     = %r{^You place (?<silver>\d+) silver coins inside your #{BAG_STR}.$}
        HAVE    = /^Inside the #{BAG_STR} you see approximately (?<silver>\d+) silver coins\.$/

        def self.parse(line)
          
        end
      end
      ##
      ## interaction outcomes for dealing with a bag
      ##
      module Outcomes
        FAIL      = %r{^Your (.*?) is already full!$}
        NOT_FOUND = %r{^But you do not have that many coins!$}
        ALL       = Regexp.union(Silvers::ADD, FAIL, NOT_FOUND)
      end

      @count ||= 0

      def self.store(silvers)
        dothistimeout("put #{coins} silver in ##{BAG.id}", 
          2, Bag::Outcomes::ALL)
      end

      DownstreamHook.add("shiva/coinbag", -> line {
       begin
         Silvers.parse(line)
       rescue => exception
         Log.out(exception)
       ensure
         return line
       end
      })
    end

    module Wealth
      module Outcome
        NO_SILVER   = %r(You have no silver coins with you.)
        ONE_SILVER  = %r(You have but one coin with you.)
        MANY_SILVER = %r(You have ([\d,]+) coins with you.)
        WEALTH      = Regexp.union(NO_SILVER, ONE_SILVER, MANY_SILVER)
      end

      def self.check()
        case dothistimeout("wealth quiet", 5, WEALTH)
        in NO_SILVER   then return 0
        in ONE_SILVER  then return 1
        in MANY_SILVER then return $1.delete(",").to_i
        end
      end
    end
=end

    def available?(foe)
      return false unless foe.nil?
      return false unless self.bag
      return false if self.full?
      return true
    end

    def add_silvers()
    end

    def apply()
      #empty_left
      #self.add_silvers()
      #fill_left
    end
  end

end