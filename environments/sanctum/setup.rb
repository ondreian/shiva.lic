require_relative "../../stage"

module Shiva
  module Sanctum
    class Setup < Stage
      Entry = 25172

      def scripts
        %w(reaction lte effect-watcher)
      end

      def transport
        if Group.empty?
          Script.run("go2", "%s --disable-confirm" % Entry)
        else
          Script.run("rally", "%s" % Entry)
        end
      end

      def bard
        fput "incant 1009" unless checkleft
      end

      def activate_group
        return unless Group.leader?
        return if Group.empty?
        Group.members.map(&:noun).map do |member|
          Cluster.cast(member, 
            channel: :script, 
            script:  :shiva,
            args:    %(--env=sanctum),
          )
        end
      end

      def apply(env)
        #empty_hands
        Group.check
        Char.arm
        self.bard if Char.prof.eql?("Bard")
        return if XMLData.room_title.include?("[Sanctum of Scales") or not Group.leader?
        self.transport
        fail "did not travel to sanctum" unless Room.current.id.eql?(Entry)
        self.activate_group
      end
    end
  end
end