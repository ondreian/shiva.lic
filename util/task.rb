module Task
  @last_expedite_expiry = Time.now

  def self.log()
    Log.out(Bounty::Util.short_bounty, label: %i(bounty current))
  end

  def self.expedites?
    defined? BountyHUD and BountyHUD.session.dig(:expedites) > 0
  end

  def self.cycle(town)
    Bounty.remove
    return unless self.expedites?
    self.log()
    dothistimeout("ask #%s for exp" % Bounty.npc.id, 4, %r[I'll expedite your task reassignment.])
    @last_expedite_expiry = Time.now + (15 * 60)
  end

  def self.room(town, tag)
    World.by_town(tag).find {|k, v| k.include?(town)}.last or fail "could not find #{tag} for : #{town}"
  end

  def self.sell_by_tag(town, tag, sellable)
    sellables = Containers.lootsack.where(name: sellable)
    return :none if sellables.empty?
    shop = self.room(town, tag)
    shop.id.go2
    empty_hands
    will_be_completed = sellables.size >= Bounty.number
    sellables.take(Bounty.number).each {|g|
      g.take
      fput "sell #%s" % g.id
    }
    fill_hands
    return unless will_be_completed
    self.advance(town)
  end

  def self.advance(town)
    sleep 0.2
    guild = self.room(town, "advguild")
    self.log()
    guild.id.go2
    case Bounty.type
    when :none
      return :cooldown if Effects::Cooldowns.active?("Next Bounty") and not self.expedites?
      self.cycle(town) if Effects::Cooldowns.active?("Next Bounty") and self.expedites?
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
      return :waiting if Time.now < @last_expedite_expiry
      self.advance(town)
    when :gem
      return self.sell_by_tag(town, "gemshop", Bounty.task.gem) if Bounty.task.gem !~ /urglaes/
      self.cycle(town)
      return self.advance(town)  
    when :get_skin_bounty
      Go2.furrier
      Bounty.ask_for_bounty
      self.advance(town)
    when :get_gem_bounty
      Go2.gemshop
      Bounty.ask_for_bounty
      self.advance(town)
    when :skin
      return self.sell_by_tag(town, "furrier", Bounty.task.skin.slice(0..-2)) if Bounty.task.skin !~ /lich finger bones|rift crawler/
      self.cycle(town)
      self.advance(town)
    when :get_bandits
      self.cycle(town)
      self.advance(town)
    when :dangerous, :cull, :heirloom
      return :ok unless Bounty.creature =~ /(lich|crusader|crawler|monstrosity)$/
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
    when :escort, :get_herb_bounty
      self.cycle(town)
      self.advance(town)
    else
      fail "Bounty(#{Bounty.task.type}) / not implemented"
    end
  end
end