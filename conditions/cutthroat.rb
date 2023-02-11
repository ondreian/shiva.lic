module Shiva
  module Conditions
    module Cutthroat
      def self.handle!
        return unless cutthroat?
        Log.out("handling cutthroat", label: %i(condition cutthroat))
        Base.go2
        Team.request_healing
        wait_while("waiting on cutthroat...") {cutthroat?}
      end
    end
  end
end