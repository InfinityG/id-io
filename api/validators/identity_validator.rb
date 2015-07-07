require 'date'
require 'json'
require 'ig-validator-utils'

require_relative '../../api/errors/validation_error'
require_relative '../../api/constants/error_constants'

class IdentityValidator
  include ErrorConstants::ValidationErrors
  include ValidatorUtils

  def validate_new_user(data)
    errors = []

    #fields
    errors.push INVALID_FIRST_NAME unless GeneralValidator.validate_string_strict data[:first_name]
    errors.push INVALID_LAST_NAME unless GeneralValidator.validate_string_strict data[:last_name]
    errors.push INVALID_USERNAME unless GeneralValidator.validate_username_strict data[:username]
    errors.push INVALID_PASSWORD unless GeneralValidator.validate_password data[:password]

    # public_key is optional; however if present must be the correct length
    errors.push INVALID_PUBLIC_KEY unless GeneralValidator.validate_public_ecdsa_key data[:public_key] if data[:public_key].to_s != ''

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
    errors.push INVALID_USERNAME unless GeneralValidator.validate_username_strict data[:username]
    errors.push INVALID_PASSWORD unless GeneralValidator.validate_password data[:password]
    errors.push INVALID_DOMAIN unless GeneralValidator.validate_string_strict data[:domain]
    # errors.push INVALID_REDIRECT unless GeneralValidator.validate_boolean data[:redirect]

    raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
  end

  def validate_login_with_signed_challenge(data)
    errors = []

    #fields
    errors.push INVALID_USERNAME unless GeneralValidator.validate_username_strict data[:username]
    errors.push INVALID_DOMAIN unless GeneralValidator.validate_string_strict data[:domain]

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
      errors.concat validate_signature_fields data
    end

    errors

  end

  # validates an initial contact ('friend') request
  def validate_connection_request(data)
    errors = []

    #fields
    if data == nil
      errors.push NO_DATA_FOUND
    else
      errors.push INVALID_USERNAME unless GeneralValidator.validate_username_strict data[:username]
      errors.concat validate_signature_fields data
    end

    errors

  end

  # validates a contact confirmation
  def validate_connection_confirmation(data)
    errors = []

    #fields
    if data == nil
      errors.push NO_DATA_FOUND
    else
      errors.push INVALID_CONFIRMATION unless GeneralValidator.validate_string_strict data[:confirmed]
      errors.concat validate_signature_fields data
    end

    errors

  end

  def validate_signature_fields(data)
    errors = []

    errors.push INVALID_DATA unless GeneralValidator.validate_base_64 data[:data]
    errors.push INVALID_SIGNATURE unless GeneralValidator.validate_base_64 data[:signature]

    errors
  end

end