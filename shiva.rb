

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

  def self.run_with_env(env_name)
    #Shiva.load_all_modules
    controller = Shiva::Controller.new()
    controller.set_env(env_name)
    $shiva = controller
    controller.run()
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
    return Vars["shiva/town"] if Vars["shiva/town"]
    town_id = Room.current.find_nearest_by_tag("town")
    fail "could not find the nearest town" if town_id.nil?
    Room[town_id].location
  end

  def self.environments(town)
    Environment::All.select {|env| env.town && env.town.to_s.downcase.include?(town.downcase) }
  end

  def self.best_env(town = self.town)
    available_environments = self.environments(town)
    creature = Bounty.task.creature
    return available_environments.sample if creature.nil?
    creature_noun = creature.split.last
    matching_environments = available_environments.select {|env| env.foe_nouns.include?(creature_noun)}
    fail "did not find a matching environment for #{creature}" if matching_environments.empty?
    matching_environments.sample
  end

  def self.hunt
    env_name = self.best_env.name
    _respond "<b>hunting in %s</b>" % env_name
    self.run_with_env(env_name)
  end

  def self.auto()
    fput "exp"
    fput "bounty"
    #Shiva.load_all_modules
    loop {
      Script.run("waggle")
      closest_town = self.town
      available_environments = self.environments self.town
      fail "no environments found for #{closest_town}" if available_environments.empty?
      respond "{town=%s, environs=%s}" % [closest_town, available_environments.map(&:name).join(",")]
      if Mind.saturated?
        Base.go2
        wait_while("waiting on saturation...") {Mind.saturated?}
      end
      case Bounty.type
      when :succeeded, :report_to_guard, :failed, :get_heirloom
        Task.advance(closest_town)
      when :none
        Task.advance(closest_town) unless Task.cooldown?
        self.hunt if Bounty.type.eql?(:none)
      when :dangerous, :cull, :heirloom, :skin, :gem
        self.hunt
      when :herb
        fail "eforage.lic not detected to run herb tasks" unless Script.exists?("eforage")
        Script.run("eforage", "--bounty")
        Task.advance(closest_town)
      when :bandits
        self.bandits
      when :escort
        self.escort(closest_town)
      else
        fail "shiva/auto not implemented for %s" % Bounty.type
      end
      unless Opts["daemon"]
        Base.go2
        _respond "<b>--daemon flag not detected, exiting...</b>"
        exit
      end
    }
  end

  def self.escort(town)
    return Task.drop(town) unless (Vars["shiva/escort"] || "").split(",").any? {|dest| Bounty.task.destination.downcase.include?(dest) }
    Script.run("escort")
  end

  def self.bandits
    self.run_with_env(:bandits)
  end

  def self.control_room()
    self.run_with_env(:escort)
  end

  def self.init
    Shiva.load_all_modules
    Script.run("eboost") if Script.exists?("eboost") && !defined?(::Boost)
    if Opts["simulate"]
      Shiva.simulate
    elsif Opts["env"]
      Shiva.run_with_env Opts["env"]
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
