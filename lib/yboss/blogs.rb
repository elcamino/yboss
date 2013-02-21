module YBoss
  require 'yboss/base'
  require 'yboss/result/base'

  class Blogs < YBoss::Base
    class Result < YBoss::Result::Base ; end
  end
end
