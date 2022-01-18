module Shiva
  module Peer
    PEER_HOOK = Script.current.name + "::" + "peer"
    MONSTER_REGEX = /\<pushBold\/\>\<pushBold\/\>[^<]*\s*\<a[^<]+\>(?<critter>[^<]*)?\<\/a\>\<popBold\/\>\<popBold\/\>/
    PC_REGEX = /^Also here: (?<pcs>.*)$/
    EXIST_TAG = %r{[^<]*\s*\<a[^<]+\>(?<critter>[^<]*)?\<\/a\>}
    before_dying {  DownstreamHook.remove(PEER_HOOK) }  

    def self.ingest(line, state)
      #Log.out(line, label: PEER_HOOK)
      state[:started] = true if line.include?(%[You peer])
      state[:foes] = line.scan(MONSTER_REGEX).flatten if line =~ MONSTER_REGEX
      if line.include?("Also here:")
        state[:pcs] = line.scan(EXIST_TAG).flatten
      end
      return line if line =~ /You peer|You can't peer through|roomDesc|roomName/ 
      if line.include?("You are unable to determine what lies beyond") or line.include?("but see nothing of interest.")
        DownstreamHook.remove(PEER_HOOK)
        return line
      end

      if state[:started] && (line.include?("<prompt") or line.include?("compass")) or Time.now > state[:ttl]
        DownstreamHook.remove(PEER_HOOK)
        return line
      end
    end


    def self.call(dir)
      dir   = dir.gsub(/^(go|climb)\s+/, "")
      state = {foes: [], pcs: [], started: false, ttl: Time.now + 2, dir: dir}
      DownstreamHook.add(PEER_HOOK, Proc.new {|line| ingest(line, state) })
      fput "peer #{state[:dir]}"
      wait_while("waiting on peer") { DownstreamHook.list.include?(PEER_HOOK) }
      Log.out(state, label: :peer)
      return OpenStruct.new(state)
    end

    def self.peer_until_clear(way, seconds: 120)
      ttl = Time.now + seconds # 2 minutes
      state = nil
      while Time.now < ttl
        state = peer(way)
        break unless $shiva.foes.empty?
        return state if state.pcs.empty?
        sleep 1
      end
    end
  end
end
