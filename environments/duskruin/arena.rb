module Shiva
  Environment.define :duskruin do
    Rooms = OpenStruct.new(
      combat:   [24550],
      entrance: [23780],
      exit:     [23798],
      team:     [26387],
      solo:     [23780],
    )

    self.class.attr_accessor :round

    def done?
      return true if Rooms.exit.include?(Room.current.id)
      self.round.eql?(25) and Foes.empty? and not Opts["endless"]
    end

    def alert_endless
      _respond %[<b>***\nENDLESS MODE\n***</b>]
    end

    def self.entry
      Group.empty? ? 23780 : 26387
    end

    def self.activate_group()
      return unless Group.leader?
      return if Group.empty?
      Group.members.map(&:noun).map do |member|
        Cluster.cast(member, 
          channel: :script, 
          script:  :shiva,
          args:    %(--env=#{self.env.name}),
        )
      end
    end

    Round = /An announcer shouts, "Round (?<round>\d+), send in/

    def self.add_round_hook()
      DownstreamHook.add("shiva/round-count", -> line {
        begin
          @round = line.match(Round)[:round].to_i if line =~ Round
        rescue => exception
          Log.out(exception)
        ensure
          return line
        end
      })
    end

    def self.setup
      fail "you are encumbered" if percentencumbrance > 0
      Conditions::Saturated.handle!
      self.activate_group
      $shiva_graceful_exit = false
      return if Rooms.combat.include?(Room.current.id)
      Script.run("shiva_setup") if Script.exists?("shiva_setup")
      empty_hands
      self.entry.go2 if Group.leader? or Group.empty?
      booklet = Containers.harness.where(name: /(booklet|stamped voucher)$/).first or fail "no booklet in #{Containers.harness.name}"
      booklet.take
      if Group.leader? or Group.empty?
        move "go entrance"
      else
        wait_until("waiting for arena") {Rooms.combat.include?(Room.current.id)}
      end
      Containers.harness.add(booklet) if Char.right
      Arms.use
      if Group.leader? or Group.empty?
        while line=get
          break if line =~ /An announcer shouts/
          break unless self.foes.empty?
        end
      end
      @round = 1
      
      fput "shout" if (Group.leader? or Group.empty?) and self.foes.empty?
    end

    def self.main
      Log.out(:main)
      self.add_round_hook
      self.alert_endless if Opts["endless"]
      #wait_while("waiting on foe...") {self.foes.empty?}
      until self.done? do 
        (proposed_action, foe) = self.best_action
        Action.call(proposed_action, foe)
        Log.out("proposed.action=%s foe=%s" % [proposed_action.to_sym, foe.name || :nil], label: %i(duskruin logic)) unless proposed_action.eql?(@previous_action)
        @previous_action = proposed_action
        sleep 0.1
      end
    end

    def self.teardown
      sleep 1.0
      waitrt?
      Char.unarm unless Char.right.noun.eql?("package")
      #fput "pray" if Rooms.combat.include?(Room.current.id)
      waitcastrt?
      fput "renew all" if Char.prof.eql?("Bard")
      num = %w(430 120 425 103 107 101).select {|num| Spell[num].known? && Spell[num].timeleft < 60}.sort_by {|num| Spell[num].timeleft}.sample
      Spell[num].cast if Rooms.combat.include?(Room.current.id) && !num.nil?
      
      wait_until {
        Char.right.noun.eql?("package") or get? =~ /You have instantly absorbed 20 experience points|He hands you 310 bloodscrip/
      }

      if Char.right.noun.eql?("package")
        multifput "open #%s" % Char.right.id, "look in #%s" % Char.right.id
        wait_until{Containers.right_hand.contents.is_a?(Array)}
        Containers.lootsack.add(*Containers.right_hand)
        fail "could not unload package" unless Containers.right_hand.contents.empty?
        fput "drop #%s" % Char.right.id
      end
      
      
      self.entry.go2 if Group.leader? or Group.empty?
      exit if $shiva_graceful_exit.eql?(true)
    end
  end
end