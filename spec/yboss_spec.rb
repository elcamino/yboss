# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

if ENV['YAHOO_BOSS_API_KEY_SUFFIX']
  ENV['YAHOO_BOSS_API_KEY'] += ENV['YAHOO_BOSS_API_KEY_SUFFIX']
end

YBoss::Config.instance.oauth_key = ENV['YAHOO_BOSS_API_KEY']
YBoss::Config.instance.oauth_secret = ENV['YAHOO_BOSS_API_SECRET']

puts YBoss::Config.instance.oauth_key

def trySearch(search_type, query_string)
  res = YBoss.send search_type, {:q => query_string}
  res.responsecode.to_i.should == 200
  res.count.to_i.should > 0
end

describe "Yboss Test API Credentials" do
  it "should have a consumer key" do
    YBoss::Config.instance.oauth_key.should_not == nil
  end
  it "should have a consumer secret" do
    YBoss::Config.instance.oauth_secret.should_not == nil
  end
end

describe "Yboss Basic Queries" do
  it "should return some results for a purely alpha-numeric query" do
    trySearch(:web, 'yahoo')
  end

  it "should return some results for a query string with a space" do
    trySearch(:web, 'yahoo sports')
  end

  it "should return some results for a query string with parentheses" do
    trySearch(:web, 'yahoo (sports)')
  end

  it "should return some results for a query string with punctuation" do
    trySearch(:web, "yahoo's stock price")
  end

  it "should return some results for a query string with non-english characters" do
    trySearch(:web, "café au lait")
  end

  it "should return some results for a query string with numbers and a percent sign" do
    trySearch(:web, "who are the 99%?")
  end

  it "should return some results for a query string with brackets" do
    trySearch(:web, "andrew [carnegie]")
  end

  it "should return some results for a query string with a colon" do
    trySearch(:web, "mission: impossible")
  end

  it "should return some results for a query string with an at sign" do
    trySearch(:web, "@Twitter")
  end

  it "should return some results for a query string with a comma-delimited list" do
    trySearch(:web, "Tyson, Neil deGrasse")
  end

  it "should return some results for a query string with an exclamation point" do
    trySearch(:web, "yahoo ruby gems!")
  end

  it "should return some results for a query string with an hash sign" do
    trySearch(:web, "#colbert_bump")
  end

  it "should return some results for a query string with a dollar sign" do
    trySearch(:web, "Ke$ha")
  end

  it "should return some results for a query string with an equals sign" do
    trySearch(:web, "1 + 1 = 3")
  end

  it "should return some results for a query string with ampersand sign" do
    trySearch(:web, "h&m")
  end
end
