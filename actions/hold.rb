module Shiva
  class Hold < Action
    def priority
      2
    end

    def reason
      return :monstrosity if GameObj.targets.any? {|f| %w(monstrosity).include?(f.noun)}
      return false
    end

    def reason?
      self.reason.is_a?(Symbol)
    end

    def available?
      return false if Group.leader?
      return false unless standing?
      return false if muckled?
      return self.reason?
    end

    def apply()
      wait_while("waiting on reason=%s" % self.reason) {self.available?}
    end
  end
end