# Doing Things The Less Hard Way

### Making requests using `get()`, `post()`, `put()`, and `delete()`
###### - These methods return a Hash (with symbol keys) of the parsed JSON response body
```
require 'duo_api'

# Initialize the api
client = DuoApi.new(IKEY, SKEY, HOST)

# EXAMPLE 1: Get single user by username
user = client.get('/admin/v1/users', { username: 'john' })[:response]

# EXAMPLE 2: Create new user
new_user = client.post('/admin/v1/users', { username: 'john2' })[:response]

TODO: MORE EXAMPLES HERE
```

### Making requests using `get_all()`
###### - This method handles paginated responses automatically and returns a Hash (with symbol keys) of the combined parsed JSON response bodies
```
require 'duo_api'

# Initialize the api
client = DuoApi.new(IKEY, SKEY, HOST)

# EXAMPLE 1: Get all users
users = client.get_all('/admin/v1/users')[:response]

TODO: MORE EXAMPLES HERE
```

### Making requests using `get_image()`
###### - This method expects an image content-type and returns the raw response body
```
require 'duo_api'

# Initialize the api
client = DuoApi.new(IKEY, SKEY, HOST)

# EXAMPLE 1: Download logo from Admin API and write to disk
image_data = client.get_image('/admin/v1/logo')
File.write('logo.png', image_data)
```