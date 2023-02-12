

module Shiva
  def self.root()
    File.join Dir.home, "gemstone", "shiva"
  end

  def self.import(file)
    load File.join(self.root, file)
  end

  def self.files
    Dir[File.join(self.root, "**", "*.rb")].sort {|f| -f.size}
  end

  def self.load_all_modules
    self.files.reverse.each {|asset| load(asset) }
    Log.out "loaded %s files" % files.size
  end

  def self.reload_actions(verbose: false)
    Shiva::Trash.reload
    Dir[File.join(self.root, "actions", "**", "*.rb")]
      .each {|asset|
        load(asset)
        Log.out "loaded %s" % asset, label: %i(load) if verbose
      }
  end

  def self.run_once(env_name)
    controller = Shiva::Controller.new()
    controller.set_env(env_name)
    $shiva = controller
    controller.run()
  end

  def self.run(env_name)
    loop {
      self.run_once(env_name)
      break if $shiva_graceful_exit
      break unless Opts["daemon"]
      sleep 0.1
    }
  end

  def self.simulate
    Shiva.load_all_modules
    controller = Shiva::Controller.new Opts["env"]
    loop do
      sleep 0.1
      action = controller.best_action
      next if action.eql?(:noop)
      Log.out("would have used -> %s" % action.class.name, 
        label: %i(simulate))
      wait_while {controller.best_action.eql?(action)}
    end
  end

  def self.town()
    return Opts["town"] if Opts["town"]
    return Config.town if Config.town
    town_id = Room.current.find_nearest_by_tag("town")
    fail "could not find the nearest town" if town_id.nil?
    Room[town_id].location
  end

  def self.environments(town)
    Environment::All.select {|env| env.town && env.town.to_s.downcase.include?(town.downcase) }
  end

  def self.best_env(town = self.town)
    available_environments = self.environments(town).select {|area| area.level.include?(Char.level)}
    creature = Bounty.task.creature
     fail "did not find a matching environment for level=%s" % Char.level if available_environments.empty?
    return available_environments.sample if creature.nil?
    creature_noun = creature.split.last
    matching_environments = available_environments
      .select {|env| env.native_foes.include?(creature_noun)}
    fail "did not find a matching environment for #{creature}" if matching_environments.empty?
    matching_environments.sample
  end

  def self.hunt(env: self.best_env, resume: false)
    env_name = env.name
    if resume
      Log.out("resuming %s" % env_name, label: %i(env resume))
    else
      _respond "<b>hunting in %s</b>" % env_name
    end
    self.run_once(env_name)
  end

  def self.task
    Task.advance self.town
  end

  def self.bounty!
    case Bounty.type
    when :succeeded, :report_to_guard, :failed, :get_heirloom, :creature_problem, :get_skin_bounty, :get_bandits
      self.task
    when :none
      self.task unless Task.cooldown?
      if Bounty.type.eql?(:none) and Task.cooldown? and ::EBoost.bounty.available? and Effects::Cooldowns.to_h.dig("Next Bounty") - Time.now > (60 * 7.5) and Script.exists?("use-boost-bounty") and Config.use_boost?
        Script.run("use-boost-bounty")
      else
        self.hunt if Bounty.type.eql?(:none)
      end
    when :dangerous, :cull, :heirloom, :skin, :gem
      self.hunt
    when :herb
      fail "eforage.lic not detected to run herb tasks" unless Script.exists?("eforage")
      Script.run("eforage", "--bounty")
      self.task
    when :bandits
      if %(rogue warrior).include? Char.prof.downcase
        self.bandits
      else
        Bounty.remove
      end
    when :escort
      self.escort(self.town)
    else
      fail "shiva/auto not implemented for %s" % Bounty.type
    end
  end

  def self.available_environments
    self.environments(self.town).select {|env| env.level.include?(Char.level)}
  end

  def self.handle_conditions!
    Boost.experience
    Conditions::Cutthroat.handle!
    Conditions::Saturated.handle! unless Boost.loot?
    Conditions::Overexerted.handle!
    Conditions::Burrowed.handle!
    Conditions::Hypothermia.handle!
  end

  def self.handle_room_desc!
    fput "flag desc off"
    before_dying {fput "flag desc on"}
  end

  def self.preflight!
    fail "no environments found for #{self.town}" if self.available_environments.empty?
    respond "{town=%s, environs=%s}" % [self.town, self.available_environments.map(&:name).join(",")]
    return if available_environments.any?(&:current?)
    Base.go2
    Script.run("waggle")
    self.handle_conditions!
  end

  def self.down!(msg = nil)
    Base.go2
    _respond "<b>%s</b>" % msg if msg.is_a?(String)
    exit
  end

  def self.daemon?
    Log.out("{graceful_exit=%s, daemon=%s}" % [$shiva_graceful_exit, Opts["daemon"]], label: %i(daemon?))
    self.down!("shutting down because of graceful_exit...") if $shiva_graceful_exit
    return if Opts["daemon"]
    self.down! "--daemon flag not detected, exiting..."
  end

  def self.current_env
    self.available_environments.find(&:current?)
  end

  def self.auto()
    $shiva_graceful_exit = false
    fput "exp"
    fput "bounty"
    self.handle_room_desc!
    loop {
      self.preflight!
      if env_to_resume = self.available_environments.find(&:current?)
        self.hunt(env: env_to_resume, resume: true)
      elsif Mind.saturated? && Bounty.done? && Opts["farm"]
        self.hunt
      else
        self.bounty!
      end
      self.daemon?
    }
  end

  def self.escort(town)
    return Task.drop(town) unless Config.escort.split(",").any? {|dest| Bounty.task.destination.downcase.include?(dest) }
    Script.run("escort")
  end

  def self.bandits
    self.run_once(:bandits)
  end

  def self.control_room()
    self.run_once(:escort)
  end

  def self.init
    Shiva.load_all_modules
    Script.run("eboost") if Script.exists?("eboost") && !defined?(::EBoost)
    if Opts["simulate"]
      Shiva.simulate
    elsif Opts["env"]
      Shiva.run Opts["env"]
    elsif Opts["load"]
      exit
    elsif Opts["auto"]
      Shiva.auto
    elsif Opts["sell"]
      Shiva.load_all_modules
      Task.advance($shiva.env.town) if $shiva and %i(gem skin).include?(Bounty.type) and not Task.sellables.empty?
      Shiva::Teardown.new(OpenStruct.new({env: nil})).sell_loot
    else
      _respond <<~HELP
        <b>;shiva:</b>

          --env       environment to load
          --simulate  run as a simulation
      HELP
    end
  end

  Shiva.import "action.rb"
  Shiva.import "actions.rb"
end
