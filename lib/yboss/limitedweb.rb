module YBoss
  require 'yboss/base'

  class Limitedweb
    include ::YBoss::Base

    attr_reader :credits, :options

    def initialize(options = { })
      @options = {
        'filter'   => nil,
        'type'     => nil,
        'view'     => nil,
        'abstract' => nil,
        'title'    => nil,
        'url'      => nil,
        'style'    => nil,
        'q'        => nil,
      }.merge(options)

      if YBoss.config.proxy
        RestClient.proxy = YBoss.config.proxy
      end
    end

    def call(options = {})
      data = fetch(@options.merge(options))

      Result.new(data)
    end

    class Result
      attr_reader :responsecode, :start, :count, :totalresults, :items

      def initialize(data = {})
        resp          = data['bossresponse']
        @responsecode = resp['responsecode']
        lw            = resp['limitedweb']
        @start        = lw['start']
        @count        = lw['count']
        @totalresults = lw['totalresults']
        @items        = []

        lw['results'].each do |r|
          @items << Item.new(r)
        end
      end

      class Item
        require 'yboss/result'

        include YBoss::Result

        def initialize(data = {})
          @data = data
        end
      end
    end

  end
end
