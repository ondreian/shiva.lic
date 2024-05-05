# wrapper to prevent scripts from spamming shit 
# endlessly, accidentally in logic traps
module SpamGuard
  # 10 max tries for a command
  UPPER_BOUND = 20

  @apis ||= OpenStruct.new(
    fput: Kernel.method(:fput),
    dothistimeout: Kernel.method(:dothistimeout),
    put: Kernel.method(:put),
  )

  @history ||= []

  def self.apis
    @apis
  end

  def self.history
    @history
  end

  def self.happened(cmd)
    history.reverse.take_while { |entry| entry.eql?(cmd) }.size
  end

  def self.guard(cmd)
    return yield if %w(song-manager keepalive).include?(Script.current.name)
    @history << cmd
    # only store last 300 commands
    @history.shift while @history.size > 300
    number_in_a_row = self.happened(cmd)
    if number_in_a_row > (UPPER_BOUND * 2)
      Shiva::Base.go2
      _respond "<b>spam guard error: %s was sent %s times!</b>" % [cmd, number_in_a_row]
      Script.current.exit
    else
      yield
    end
  end

  def self.fput(cmd, *args)
    self.guard(cmd) { self.apis.fput.call(cmd, *args) }
  end

  def self.put(cmd, *args)
    self.guard(cmd) { self.apis.put.call(cmd, *args) }
  end

  def self.dothistimeout(cmd, *args)
    self.guard(cmd) { self.apis.dothistimeout.call(cmd, *args) }
  end
end

def dothistimeout(*args)
  SpamGuard.dothistimeout(*args)
end

def fput(*args)
  SpamGuard.fput(*args)
end

def put(*args)
  SpamGuard.put(*args)
end