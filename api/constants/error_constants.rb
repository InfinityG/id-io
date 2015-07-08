module ErrorConstants

  module IdentityErrors
    # NO_CONTRACT_FOUND = 'No contract found with id %s'
    USERNAME_EXISTS = 'Username already exists'
    USER_NOT_FOUND = 'User cannot be found'
    PUBLIC_KEY_NOT_REGISTERED = 'Cannot validate signature - no public key registered for user'
    DOMAIN_NOT_AUTHORIZED = 'Domain not authorized'
    INVALID_PASSWORD = 'Password invalid'
    INVALID_SIGNED_DATA = 'Invalid signed data'
    INVALID_SIGNATURE = 'Invalid signature'
    INVALID_DOMAIN = 'Invalid domain'
    INVALID_AES_KEY = 'Invalid AES key'
    INVALID_USER_ID = 'Invalid user id'
    CONTACT_NOT_FOUND = 'Contact cannot be found'
  end

  module ValidationErrors
    INVALID_FIRST_NAME = 'Invalid first name'
    INVALID_LAST_NAME = 'Invalid last name'
    INVALID_USERNAME = 'Invalid username'
    INVALID_PASSWORD = 'Invalid password. Minimum 8 characters length, with at least 1 upper case, 1 numeric and 1 special character'
    INVALID_PUBLIC_KEY = 'Invalid public key'
    INVALID_DOMAIN = 'Invalid domain'
    NO_DATA_FOUND = 'No data found!'
    NO_CHALLENGE_FOUND = 'No challenge found!'
    INVALID_DIGEST = 'Invalid digest'
    INVALID_SIGNATURE = 'Invalid challenge signature'
    INVALID_USER_ID = 'Invalid user id'
    INVALID_CONTACT_USER_ID = 'Invalid contact user id'
    INVALID_CONFIRMATION = 'Invalid confirmation'
  end
end