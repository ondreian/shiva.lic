# module Shiva
#   class Loot < Action
#     Skinnable = %w(
#       cerebralite lich crawler
#       sidewinder
#       warg mastodon hinterboar
#       brawler warlock fanatic
#       dreadsteed titan giant
#       bear lion
#     )

#     def priority
#       Priority.get(:high) - 2
#     end

#     def dead
#       GameObj.npcs.to_a
#       .select {|foe| foe.status.include?("dead")}
#       .reject {|foe| %w(glacei).include?(foe.noun)}
#     end

#     def should_unhide?
#       return false if self.env.foes.any? {|f| %w(crawler siphon).include?(f.noun)} and hidden?
#       return false if self.env.foes.any? {|f| f.name =~ /gigas|warg/} and hidden?
#       return false if self.env.foes.any? {|f| f.name =~ /grizzled|ancient/} and hidden?
#       return true unless hidden?
#       return true if hidden? and self.env.foes.size < 5
#       return false
#     end

#     def not_wounded?
#       Wounds.head < 2 and
#       Wounds.nsys < 2 and
#       Wounds.leftEye < 2 and
#       Wounds.rightEye < 2
#     end

#     def available?
#       Lich::Claim.mine? and
#       not self.env.name.eql?(:duskruin) and
#       not self.dead.empty? and
#       self.should_unhide? and
#       self.not_wounded? and
#       (Group.leader? or Group.empty?)
#     end


#     def apply()
#       waitrt?
#       return if self.dead.empty?
#       self.dead.each do |dead|
#         fput "search #%s" % dead.id
#         ttl = Time.now + 1
#         wait_while { GameObj[dead.id] and Time.now < ttl }
#         waitrt?
#       end
#     end
#   end
# end