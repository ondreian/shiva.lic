module Rally
  def self.nouns(list)
    list.to_a.map(&:noun)
  end

  def self.should_group(members)
    GameObj.pcs.to_a
      .reject {|pc| 
        Group.members.map(&:id).include?(pc.id) && !members.map(&:id).include?(members.id)
      }
  end

  def self.group(point)
    Group.check()

    members = Group.members
    Log.out(members)

    multifput("disband", "group open")

    members.each do |member| 
      Cluster.cast(member, 
        channel: :go2, 
        room:    point)
    end

    point.go2
    timeout = Time.now + 30
    loop {
      sleep 0.1
      self.should_group(members).each {|member|
        fput "group #%s" % member.id
      }
      break if Group.members.size.eql?(members.size)
      break if Time.now > timeout
    }
    members
  end

end