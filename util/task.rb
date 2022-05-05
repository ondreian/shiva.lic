module Task
  def self.log()
    Log.out(Bounty::Util.short_bounty, label: %i(bounty current))
  end

  def self.cycle(town)
    Bounty.remove
    return unless defined? BountyHUD
    return unless BountyHUD.session.dig(:expedites) > 0
    self.log()
    dothistimeout("ask #%s for exp" % Bounty.npc.id, 4, %r[I'll expedite your task reassignment.])
  end

  def self.advance(town)
    sleep 0.2
    guild = World.advguilds_by_town[town] or fail "unknown town : #{town}"
    self.log()
    guild.id.go2
    case Bounty.type
    when :none
      return :cooldown if Effects::Cooldowns.active?("Next Bounty")
      Bounty.ask_for_bounty
      self.advance(town)
    when :get_rescue, :creature_problem, :get_heirloom
      Bounty.find_guard
      Bounty.ask_for_bounty
      self.advance(town)
    when :report_to_guard
      Bounty.find_guard
      Bounty.ask_for_bounty
      self.advance(town)
    when :succeeded
      return :saturated if Mind.saturated?
      Bounty.ask_for_bounty
      self.advance(town)
    when :gem
      gems = Containers.lootsack.where(name: Bounty.gem)
      return if gems.empty?
      gemshop = World.gemshops_by_town[town] or fail "could not find a gemshop for : #{town}"
      gemshop.id.go2
      empty_hands
      will_be_completed = gems.size >= Bounty.number
      gems.take(Bounty.number).each {|g| g.sell}
      fill_hands
      return unless will_be_completed
      self.advance(town)
    when :get_skin_bounty
      Go2.furrier
      Bounty.ask_for_bounty
    when :get_gem_bounty
      Go2.gemshop
      Bounty.ask_for_bounty
    when :skin
      return :ok if Bounty.task.skin !~ /lich finger bones/
      self.cycle(town)
      self.advance(town)
    when :dangerous, :cull, :heirloom
      return :ok unless Bounty.creature =~ /lich$/
      self.cycle(town)
      self.advance(town)
    when :heirloom_found
      Bounty.find_guard
      heirloom = Containers.lootsack.where(name: /#{Bounty.task.heirloom}/).first
      fail "could not find #{Bounty.task.heirloom}" if heirloom.nil?
      empty_hands
      heirloom.take
      fput "give #%s" % Bounty.npc.id
      ttl = Time.now + 5
      wait_while {Bounty.type.eql?(:heirloom_found) and Time.now < ttl}
      fail "error / happened while turning in #{Bounty.task.heirloom}" if Time.now > ttl
      fill_hands
      self.advance(town)
    when :escort
      self.cycle(town)
      self.advance(town)
    else
      fail "Bounty(#{Bounty.task.type}) / not implemented"
    end
  end
end