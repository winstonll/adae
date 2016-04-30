location = ENV["REDISCLOUD_URL"] || 'redis://127.0.0.1:6379/0'
uri = URI.parse(location)
$redis = Redis.new(:host => "127.0.0.1", :port => 6379)
