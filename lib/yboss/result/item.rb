module YBoss
  module Result
    module Item

      def initialize(data = {})
        @data = data
      end

      def keys
        @data.keys
      end

      def each(name, *args, &block)
        yield @data
      end

      def to_hash
        @data
      end

      def method_missing(name, *args, &block)
        raise YBoss::ArgumentException.new("there is no data field called \"#{name}\" here!") unless @data.has_key?(name.to_s)
        @data[name.to_s]
      end
    end
  end
end
