require 'mongo_mapper'
require 'bson'
require './api/models/user'

class UserRepository
  include Mongo
  include MongoMapper
  include BSON
  include SmartIdentity::Models

  def get_all_users
    User.all
  end

  def get_user(user_id)
    User.find user_id
  end

  def get_by_username(username)
    User.first(:username => username)
    end

  def get_by_username_and_mobile(username, mobile_number)
    User.first(:username => username, :mobile_number => mobile_number)
  end

  def get_associated_users_by_username(username)
    User.where(:registrar => username).all
  end


  def save_user(first_name, last_name, username, password_salt, password_hash, public_key, role, mobile_number = nil,
                webhooks = nil, registrar = nil)

    webhook_arr = create_webhook_array webhooks

    User.create(first_name:first_name,
                    last_name: last_name,
                    username: username,
                    password_salt: password_salt,
                    password_hash: password_hash,
                    public_key: public_key,
                    role: role,
                    mobile_number: mobile_number,
                    webhooks: webhook_arr,
                    registrar: registrar)
  end

  def update_user(user)
    user.save
  end

  def delete_user(user_id)
    User.destroy(user_id)
  end

  def create_webhook_array(webhooks)
    webhook_arr = []

    if webhooks != nil && webhooks.count > 0
      webhooks.each do |webhook|
        webhook_arr << Webhook.new(:uri => webhook[:uri], :headers => webhook[:headers], :body => webhook[:body])
      end
    end
    webhook_arr
  end
end