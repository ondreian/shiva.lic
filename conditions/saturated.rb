module Shiva
  module Conditions
    module Saturated
      def self.handle!
        return unless Mind.saturated?
        Shiva::Boost.absorb
        return Log.out("farming...", label: %i(condition saturated)) if Opts.farm
        Log.out("handling saturated", label: %i(condition saturated))
        Base.go2
        wait_while("waiting on saturated...") {Mind.saturated?}
      end
    end
  end
end