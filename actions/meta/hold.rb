module Shiva
  class Hold < Action
    def priority
      Priority.get(:medium) - 1
    end

    def reason
      return :healing if Script.running?("mend")
      return :give if Script.running?("give")
      return :monstrosity if GameObj.targets.any? {|f| %w(monstrosity).include?(f.noun)} and not Group.leader?
      return false
    end

    def reason?
      self.reason.is_a?(Symbol)
    end

    def available?
      return false unless standing?
      return false if muckled?
      return self.reason?
    end

    def apply()
      wait_while("waiting on reason=%s" % self.reason) {self.available?}
    end
  end
end