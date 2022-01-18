module Shiva
  module Scatter
    class Teardown < Stage
      def apply(env)
        fput "symbol return"
      end
    end
  end
end