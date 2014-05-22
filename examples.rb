require_relative 'duo_api'

IKEY = ARGV[0]
SKEY = ARGV[1]
HOST = ARGV[2]
unless HOST
  abort "Usage: #{$0} IKEY SKEY HOST"
end

# Initialize the api
client = DuoApi.new IKEY, SKEY, HOST

# EXAMPLE 1: Get all users
resp = client.request 'GET', '/admin/v1/users'

# print out some info from the response
puts resp.code
puts resp.header.to_hash
puts resp.message
puts resp.http_version
puts resp.body

# EXAMPLE 2: retreive the user 'john'
resp2 = client.request 'GET', '/admin/v1/users', {username: 'john'}
puts resp2.body

# EXAMPLE 3: create a new user
resp3 = client.request 'POST', '/admin/v1/users', {username: 'john2'}
puts resp3.body

# EXAMPLE 4: delete user with user_id: 'DUAE0W526W52YHOBMDO6'
resp4 = client.request 'DELETE', '/admin/v1/users/DUAE0W526W52YHOBMDO6'
puts resp4.body
