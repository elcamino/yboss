module YBoss
  require 'yboss/base'

  class Images
    include ::YBoss::Base

    attr_reader :credits, :options

    def initialize(options = { })
      @options = {
        'format'   => 'json',
        'q'        => nil,
        'service' => nil,
        'count' => nil,
        'market' => nil,
        'callback' => nil,
        'sites' => nil,
        'filter'   => nil,
        'queryfilter' => nil,
        'dimensions' => nil,
        'refereurl' => nil,
        'url' => nil,
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
        lw            = resp['images']
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
