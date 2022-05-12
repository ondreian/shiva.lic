module Shiva
  module Scatter
    class Teardown < Stage
      def go2_sands
        return self.symbol_of_return if Society.status =~ /Voln/ && Society.rank.eql?(26)
        Go2.sands
      end

      def symbol_of_return
        from_id = Room.current.id
        fput "symbol return"
        ttl = Time.now + 2
        wait_while {Room.current.id.eql?(from_id) and Time.now < ttl}
      end


      def apply(env)
        waitcastrt?
        waitrt?
        self.go2_sands
        Common::Teardown.cleanup("Icemule Trace")
      end
    end
  end
end