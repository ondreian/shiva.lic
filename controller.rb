module Shiva
  class Controller
    attr_reader :actions, :name, :env, :stage,
                :setup, :main, :teardown,
                :last_action, :seen, :start_time

    def initialize(name)
      $shiva_graceful_exit = false
      @name       = name.capitalize
      @env        = Shiva::Environment.find(name) or fail "could not find environment : #{name}"
      @stage      = :unknown
      @start_time = Time.now
    end

    def reset_start_time!
      @start_time = Time.now
    end

    def uptime()
      Time.now - @start_time
    end

    def start_scripts(scripts)
      scripts.each {|script| Script.start(script)}
      before_dying {scripts.each {|script| Script.kill(script) if Script.running?(script)}}
    end

    def reset!
      @actions  = Actions.create(self)
      @main     = Main.new(self)
      @teardown = Teardown.new(self)
      @setup    = Setup.new(self)
    end

    def load
      Log.out File.join __DIR__, "environments", @name.downcase
    end

    def best_action(foe)
      proposed_action = Shiva::Actions.best_action(@actions, foe)
      Log.out(proposed_action.is_a?(Symbol) ? proposed_action : proposed_action.to_sym, 
        label: %i(proposed action)) unless proposed_action == @last_action
      @last_action = proposed_action
    end

    def action(query)
      if query.is_a?(Symbol)
        @actions.find {|a| a.class.name.downcase.split("::").last.to_sym.eql?(query)}
      else
        @actions.find {|a| a.class.name =~ /#{query}/}
      end
    end

    def setup!
      @stage = :setup
      @setup.apply()
      if @env.scripts.is_a?(Array)
        Log.out("starting scripts: %s" % @env.scripts.join(", "), label: %i(setup scripts))
        self.start_scripts @env.scripts
      end
    end

    def main!
      @stage = :main
      @main.apply()
    end

    def teardown!
      @stage = :teardown
      @teardown.apply()
    end

    def run
      self.reset!
      loop {
        self.setup!
        self.main!
        self.teardown!
        self.reset!
      }
    end
  end
end