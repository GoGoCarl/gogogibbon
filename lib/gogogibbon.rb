require 'gogogibbon/commands'
require 'gogogibbon/config'
require 'gogogibbon/version'
require 'gogogibbon/callbacks'
require 'gogogibbon/methods'

module GoGoGibbon
  class << self

    #
    # Add a new user to the MailChimp subscription list
    #
    def subscribe user
      execute { GoGoGibbon::Commands.subscribe user }
    end

    #
    # Remove the user from the MailChimp subscription list.  If there is 
    # a cancellation list configured, they will be subscribed to that.
    #
    def cancel_user user
      execute { GoGoGibbon::Commands.cancel_user user }
    end

    #
    # Update a user subscription given a user with the properties 
    # email, first_name, and last_name.  You can always pass a struct 
    # with these properties if your user object has these fields named 
    # differently.
    #
    def update_subscription old_email, user
      execute { GoGoGibbon::Commands.update_subscription old_email, user }
    end

    def execute &block
      return unless ready?
      yield
    rescue Exception => e
      if GoGoGibbon::Config.errors = :throw
        raise e
      else
        return false
      end
    end

    #
    # Returns true if Gibbon has enough information to run, false otherwise. 
    # API Key and subscription list are minimally required.
    #
    def ready?
      result = GoGoGibbon::Config.configured?
      unless result
        GoGoGibbon::Config.fail!
      end
      result
    end

  end
end
