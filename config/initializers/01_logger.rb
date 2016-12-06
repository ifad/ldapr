require 'ldapr'
require 'logger'
require 'rollbar'

if env == 'production'
  Rollbar.configure do |config|
    config.access_token = 'POST_SERVER_ITEM_ACCESS_TOKEN'
  end

  LDAPR.logger = Rollbar::Logger.new
else
  LDAPR.logger = Logger.new(File.expand_path("../../../log", __FILE__) + "/" + env + ".log")
end
