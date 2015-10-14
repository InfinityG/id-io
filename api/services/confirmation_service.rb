require 'json'
require './api/gateways/ripple_rest_gateway'
require './api/services/transaction_service'
require './api/services/user_service'

class ConfirmationService

  # this will start a new thread which will periodically retrieve pending
  # transactions from the DB and attempt to validate them
  def start
    @service_thread = Thread.new {

      gateway = RippleRestGateway.new
      transaction_service = TransactionService.new
      user_service = UserService.new

      while true
        pending_transactions = transaction_service.get_pending_transactions

        pending_transactions.each do |transaction|

          confirmation_url = transaction.confirmation_url

          begin
            result = gateway.confirm_transaction confirmation_url
          rescue IdentityError => e
            LOGGER.error "Error confirming transaction || Error: #{e.message}"
          end

          begin
            transaction_service.confirm_transaction transaction, result
            user = user_service.get_user transaction.user_id.to_s
            user_service.update_block_status user, result[:status]
          rescue Exception => e
            LOGGER.error "Error updating transaction info on database || Error: #{e.message}"
          end if result[:status] == 'validated'

        end

        sleep 5.0

      end

    }
  end

end