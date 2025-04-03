# Doing Things The Simple Way

### Making Admin API requests using `DuoApi::Admin`
###### - These methods return only the Array, Hash, or String response data from the parsed JSON response body (except for get_logo(), which returns raw image data)
```
require 'duo_api'

# Initialize the api
admin_api = DuoApi::Admin.new(IKEY, SKEY, HOST)

# EXAMPLE 1: Get all users
users = admin_api.get_users()

# EXAMPLE 2: Get user matching specific username
user = admin_api.get_users(username: 'john')

# EXAMPLE 3: Get users matching specific usernames
users = admin_api.get_users(username_list: ['jane', 'john'])

# EXAMPLE 4: Create new user
admin_api.create_user(username: 'john2')

# EXAMPLE 5: Create new user with optional parameters
### 'aliases' can be an Array (['alias1value', 'alias2value']),
###   a Hash ({alias1: 'alias1value', alias2: 'alias2value'}), or
###   a String ('alias1=alias1value&alias2=alias2value')
admin_api.create_user(
  username: 'john3',
  realname: 'Johnny Johnson III',
  firstname: 'Johnny',
  lastname: 'Johnson',
  email: 'john3@example.com',
  aliases: [ 'johnny3' ]
)

# EXAMPLE 6: Same thing, but you want to pass a Hash
new_user = {
  username: 'john3',
  realname: 'Johnny Johnson III',
  firstname: 'Johnny',
  lastname: 'Johnson',
  email: 'john3@example.com',
  aliases: { alias1: 'johnny3' }
}
admin_api.create_user(**new_user)

TODO: MORE EXAMPLES HERE
```

### Making Accounts API requests using `DuoApi::Accounts`
###### - These methods return only the Array, Hash, or String response data from the parsed JSON response body
```
require 'duo_api'

# Initialize the api
accounts_api = DuoApi::Accounts.new(IKEY, SKEY, HOST)

# EXAMPLE 1: List child accounts
child_accounts = accounts_api.get_child_accounts()

# EXAMPLE 2: Use Accounts API to make Admin API calls on child account
account_id = 'DAFAKECHILDACCOUNTID'
child_account_admin_api = accounts_api.admin_api(child_account_id: account_id)
child_account_users = child_account_admin_api.get_users()
child_account_integrations = child_account_admin_api.get_integrations()

TODO: MORE EXAMPLES HERE
```

### Making Auth API requests using `DuoApi::Auth`
###### - These methods return only the Array, Hash, or String response data from the parsed JSON response body (except for logo(), which returns raw image data)
```
require 'duo_api'

# Initialize the api
auth_api = DuoApi::Auth.new(IKEY, SKEY, HOST)

# EXAMPLE 1: Start a synchronous auth, waiting for and returning auth result
auth_result = auth_api.auth(factor: 'auto', username: 'john')

# EXAMPLE 2: Start an asynchronous auth, then request auth result
auth_txid = auth_api.auth(factor: 'auto', username: 'john', async: '1')[:txid]
auth_result = auth_api.auth_status(txid: auth_txid)

TODO: MORE EXAMPLES HERE
```

### Making Device API requests using `DuoApi::Device`
###### - These methods return only the Array, Hash, or String response data from the parsed JSON response body
```
require 'duo_api'

# Initialize the api
device_api = DuoApi::Device.new(IKEY, SKEY, HOST, mkey: MKEY)

# EXAMPLE 1: Get list of all existing active device caches
caches = device_api.get_device_caches(status: 'active')

# EXAMPLE 2: Get all devices for a specific device cache
cache_devices = device_api.get_device_cache_devices(cache_key: 'CACHEKEY')

TODO: MORE EXAMPLES HERE
```