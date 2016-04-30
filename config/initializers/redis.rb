if Rails.env == 'production'
  $redis = Redis.new(:host => "127.0.0.1", :port => 6379, :db => 0)
elsif Rails.env == 'development'
  $redis = Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0)
end
