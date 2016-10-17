require 'redis' # https://github.com/redis/redis-rb
redis_uri = URI.parse(ENV["REDISTOGO_URL"])
redis = Redis.new(:host => redis_uri.host, :port => redis_uri.port, :password => redis_uri.password)

if redis.exists('widget-id-history')
    points_history = redis.lrange('widget-id-history', 0, 9) # get latest 10 records
    points = []
    (1..points_history.count).each do |i|
        points << { x: i, y: points_history[i-1].to_i }
    end
    last_x = points.last[:x]
else
    points = []
    last_x = 0
end

SCHEDULER.every '10s', :first_in => 0 do |job|
  if points.count > 9 # display 10 records only
    points.shift
  end
  last_x += 1
  rand_value = rand(50) # replace this line with the code to get latest value
  points << { x: last_x, y: rand_value }
  redis.lpush('widget-id-history', rand_value)

  send_event('convergence', points: points)
end


# SCHEDULER.every '20s', :first_in => 0 do |job|
#   rand_value = rand(1000) # replace this line with the code to get your data
#   prev_value = redis.get("widget-id-prev-value") # read previous value from the Redis datastore
#   redis.set("widget-id-prev-value", rand_value) # store current value to the Redis datastore

#   send_event('karma', { current: rand_value, last: prev_value })
# end
