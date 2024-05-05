module Shiva
  module Hook
    def self.register(name, &block)
      name = "shiva/%s" % name
      DownstreamHook.add(name, -> line {
        begin
          block.call(line)
        rescue => err
          Log.out(err, "hook.#{name}")
          DownstreamHook.remove(name)
        ensure
          return line
        end
      })

      before_dying do DownstreamHook.remove(name) end
    end
  end
end