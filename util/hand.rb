module Hand
  def self.apply(side)
    waitrt?
    hand = Char.send(side)
    unless hand.nil?
      5.times { 
        Containers.harness.add(hand)
        break if Char.send(side).nil?
      }
    end
    yield(side)
    unless hand.nil?
      5.times {
        Containers.harness.where(id: hand.id).first.take
        break if Char.send(side).id.eql?(hand.id)
      }
    end
  end

  def self.right(&block)
    self.apply(:right, &block)
  end

  def self.left(&block)
    self.apply(:left, &block)
  end

  def self.use(&block)
    return self.right(&block) if Tactic.ranged?
    self.left(&block)
  end

  def self.both()
    waitrt?
    left, right = [Char.left, Char.right]
    Containers.harness.add(left, right)
    yield
    fput "_drag #%s right" % right.id unless right.nil?
    fput "_drag #%s left" % left.id unless left.nil?
  end
end