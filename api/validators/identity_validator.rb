require 'date'
require 'json'
require_relative '../../api/errors/validation_error'
require_relative '../../api/constants/error_constants'
require_relative '../../api/utils/validation_util'

class IdentityValidator
  include ErrorConstants::ValidationErrors

  def validate_new_user(data)
    errors = []

    #fields
    errors.push INVALID_FIRST_NAME unless ValidationUtil.validate_string data[:first_name]
    errors.push INVALID_LAST_NAME unless ValidationUtil.validate_string data[:last_name]
    errors.push INVALID_USERNAME unless ValidationUtil.validate_string data[:username]
    errors.push INVALID_PASSWORD unless ValidationUtil.validate_password data[:password]

    # public_key is optional; however if present must be the correct length
    errors.push INVALID_PUBLIC_KEY unless ValidationUtil.validate_public_ecdsa_key data[:public_key] if data[:public_key].to_s != ''

    raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
  end

  def validate_login(data)
    password = data[:password]

    if password.to_s != ''
      validate_login_with_password data
    else
      validate_login_with_signed_challenge data
    end
  end

  def validate_login_with_password(data)
    errors = []

    #fields
    errors.push INVALID_USERNAME unless ValidationUtil.validate_string data[:username]
    errors.push INVALID_PASSWORD unless ValidationUtil.validate_string data[:password]
    errors.push INVALID_DOMAIN unless ValidationUtil.validate_string data[:domain]

    raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
  end

  def validate_login_with_signed_challenge(data)
    errors = []

    #fields
    errors.push INVALID_USERNAME unless ValidationUtil.validate_string data[:username]
    errors.push INVALID_DOMAIN unless ValidationUtil.validate_string data[:domain]

    challenge_result = validate_challenge data[:challenge]
    errors.concat challenge_result

    raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
  end

  def validate_challenge(data)
    errors = []

    #fields
    if data == nil
      errors.push NO_CHALLENGE_FOUND
    else
      errors.push INVALID_CHALLENGE_DATA unless ValidationUtil.validate_string data[:data]
      errors.push INVALID_CHALLENGE_SIGNATURE unless ValidationUtil.validate_string data[:signature]
    end

    errors

  end

end