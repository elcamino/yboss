module YBoss
  module Result
    class Base
      attr_reader :responsecode, :start, :count, :totalresults, :items

      def initialize(data = {})
        resp          = data['bossresponse']
        @responsecode = resp['responsecode']
        lw            = resp[self.class.to_s.split(/::/)[1].downcase]
        @start        = lw['start']
        @count        = lw['count']
        @totalresults = lw['totalresults']
        @items        = []

        clazz = YBoss.class_from_string(self.class.to_s + '::Item')

        lw['results'].to_a.each do |r|
          @items << clazz.new(r)
        end
      end

      class Item
        require 'yboss/result/item'
        include YBoss::Result::Item
      end


    end
  end
end
