require 'date'
require 'json'
require 'ig-validator-utils'

require_relative '../../api/errors/validation_error'
require_relative '../../api/constants/error_constants'

class IdentityValidator
  include ErrorConstants::ValidationErrors
  include ErrorConstants::IdentityErrors
  include ValidatorUtils

  def validate_trust(data)
    errors = []

    if data == nil
      errors.push NO_DATA_FOUND
    else
      #fields
      errors.push INVALID_DOMAIN unless GeneralValidator.validate_string data[:domain]
      errors.push INVALID_AES_KEY unless GeneralValidator.validate_base_64 data[:aes_key]

      errors.push INVALID_LOGIN_URI unless GeneralValidator.validate_uri data[:login_uri] if data[:login_uri].to_s != ''

      raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
    end
  end

  def validate_new_user(data)
    errors = []

    if data == nil
      errors.push NO_DATA_FOUND
    else
      #fields
      errors.push INVALID_FIRST_NAME unless GeneralValidator.validate_string_strict data[:first_name]
      errors.push INVALID_LAST_NAME unless GeneralValidator.validate_string_strict data[:last_name]
      errors.push INVALID_USERNAME unless GeneralValidator.validate_username_strict data[:username]
      errors.push INVALID_PASSWORD unless GeneralValidator.validate_password data[:password]

      errors.push INVALID_EMAIL unless GeneralValidator.validate_email data[:email] if data[:email].to_s != ''
      errors.push INVALID_MOBILE unless GeneralValidator.validate_mobile data[:mobile_number] if data[:mobile_number].to_s != ''
      errors.push INVALID_META unless GeneralValidator.validate_alpha_numeric data[:meta] if data[:meta].to_s != ''

      errors.concat validate_public_key data

      raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
    end
  end

  def validate_user_update(data, enforce_user_sig)
    errors = []

    if data == nil
      errors.push NO_DATA_FOUND
    else

      # if no password or public key then there is nothing to update!
      errors.push NO_DATA_FOUND if data[:public_key].to_s == '' && data[:password].to_s == ''

      # password is not required, but if present, must be valid
      errors.push INVALID_PASSWORD unless GeneralValidator.validate_password data[:password] if data[:password].to_s != ''

      # public key is not required, but if present, must be valid
      errors.concat validate_public_key data

      # signature required if 'enforce_user_sig' true
      errors.concat validate_signature_fields data if enforce_user_sig

      raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
    end

  end

  def validate_login(data)
    errors = []

    if data == nil
      errors.push NO_DATA_FOUND
    else
      password = data[:password]
      (password.to_s != '') ?
          (errors.concat validate_login_with_password data) :
          (errors.concat validate_login_with_signed_challenge data)
    end

    raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
  end

  def validate_login_with_password(data)
    errors = []

    #fields
    errors.push INVALID_USERNAME unless GeneralValidator.validate_username_strict data[:username]
    errors.push INVALID_PASSWORD unless GeneralValidator.validate_password data[:password]
    errors.push INVALID_DOMAIN unless GeneralValidator.validate_string_strict data[:domain]

    if data[:redirect].to_s != ''
      errors.push INVALID_REDIRECT unless GeneralValidator.validate_boolean data[:redirect]
    end

    errors
  end

  def validate_login_with_signed_challenge(data)
    errors = []

    #fields
    errors.push INVALID_USERNAME unless GeneralValidator.validate_username_strict data[:username]
    errors.push INVALID_DOMAIN unless GeneralValidator.validate_string_strict data[:domain]

    challenge_result = validate_challenge data[:challenge]
    errors.concat challenge_result

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

    raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0

  end

  # validates a contact confirmation
  def validate_connection_confirmation(data)
    errors = []

    #fields
    if data == nil
      errors.push NO_DATA_FOUND
    else
      status = data[:status]
      errors.push INVALID_CONFIRMATION unless GeneralValidator.validate_string_strict status
      errors.push INVALID_CONFIRMATION if (status != 'connected' || status != 'rejected' ||
          status != 'disconnected' || status != 'pending')
      errors.concat validate_signature_fields data
    end

    errors

  end

  def validate_public_key(data)
    errors = []

    if GeneralValidator.validate_string data[:public_key]
      errors.push INVALID_PUBLIC_KEY unless GeneralValidator.validate_public_ecdsa_key(data[:public_key])
    else
      errors.push INVALID_PUBLIC_KEY
    end

    errors
  end

  def validate_signature_fields(data)
    errors = []

    if GeneralValidator.validate_string data[:digest]
      errors.push INVALID_DIGEST unless GeneralValidator.validate_base_64 data[:digest]
    else
      errors.push INVALID_DIGEST
    end

    if GeneralValidator.validate_string data[:signature]
      errors.push INVALID_SIGNATURE unless GeneralValidator.validate_base_64 data[:signature]
    else
      errors.push INVALID_SIGNATURE
    end

    errors
  end

  def validate_otp_request(data)
    errors = []

    #fields
    if data == nil
      errors.push INVALID_OTP_REQUEST
    else
      errors.push INVALID_USERNAME unless GeneralValidator.validate_username_strict data[:username]
    end

    raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
  end

  def validate_reset_request(data)
    errors = []

    #fields
    if data == nil
      errors.push INVALID_PASSWORD_RESET_REQUEST
    else
      errors.push INVALID_USERNAME unless GeneralValidator.validate_username_strict data[:username]
      errors.push INVALID_NONCE unless GeneralValidator.validate_uuid data[:nonce]
      errors.push INVALID_OTP unless GeneralValidator.validate_integer data[:otp]
      errors.push INVALID_PASSWORD unless GeneralValidator.validate_password data[:password]
    end

    raise ValidationError, {:valid => false, :errors => errors}.to_json if errors.count > 0
  end

end