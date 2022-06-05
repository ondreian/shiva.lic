

module Shiva
  def self.root()
    File.join Dir.home, "gemstone", "shiva"
  end

  def self.import(file)
    load File.join(self.root, file)
  end

  def self.load_all_modules
    Dir[File.join(self.root, "**", "*.rb")].sort {|f| -f.size}.reverse
      .each {|asset|
        load(asset)
        Log.out "loaded %s" % asset, label: %i(load)
      }
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
    Shiva.load_all_modules
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

  def self.init
    if Opts["simulate"]
      Shiva.simulate
    elsif Opts["env"]
      Shiva.run_with_env Opts["env"]
    elsif Opts["load"]
      Shiva.load_all_modules
    elsif Opts["sell"]
      Shiva.load_all_modules
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
