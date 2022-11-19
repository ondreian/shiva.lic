module Shiva
  class Controller
    attr_reader :name, :env, :stage,
                :setup, :main, :teardown,
                :last_action, :seen, :start_time, :hands

    def initialize()
      $shiva_graceful_exit = false
      @stage      = :unknown
      @start_time = Time.now
    end

    def set_env(name)
      @env = Shiva::Environment.find(name) or fail "could not find environment : #{name}"
    end

    def start_scripts(scripts)
      scripts.each {|script| Script.start(script)}
      before_dying {scripts.each {|script| Script.kill(script) if Script.running?(script)}}
    end

    def stop_scripts(scripts)
      scripts.each {|script| 
        Script.kill(script) if Script.running?(script)
      }
    end

    def reset!
      @env.reset!
    end

    def load
      Log.out File.join __DIR__, "environments", @name.downcase
    end

    def setup!
      @stage = :setup
      @env.setup()
      if @env.scripts.is_a?(Array)
        Log.out("starting scripts: %s" % @env.scripts.join(", "), label: %i(setup scripts))
        self.start_scripts @env.scripts
      end
      self.set_hands!
    end

    def set_hands!
      @hands = [Char.left, Char.right]
    end

    def main!
      @stage = :main
      @env.main()
    end

    def teardown!
      @stage = :teardown
      if @env.scripts.is_a?(Array)
        Log.out("stopping scripts: %s" % @env.scripts.join(", "), label: %i(setup scripts))
        self.stop_scripts @env.scripts
      end
      @env.teardown()
    end

    def run
      fail "no environment attached" if @env.nil?
      self.reset!
      self.setup!
      self.main!
      self.teardown!
      self.reset!
    end
  end
end