require 'gogogibbon/commands'
require 'gogogibbon/config'
require 'gogogibbon/version'

module GoGoGibbon
  class << self

    #
    # Add a new user to the MailChimp subscription list
    #
    def subscribe user
      return unless ready?
      GoGoGibbon::Commands.subscribe user
    end

    #
    # Add all users in the database to the MailChimp subscription list. 
    # This will not re-add them if they are already there.
    #
    def subscribe_all
      return unless ready?
      GoGoGibbon::Commands.subscribe_all
    end

    #
    # Remove the user from the MailChimp subscription list.  If there is 
    # a cancellation list configured, they will be subscribed to that.
    #
    def cancel_user user
      return unless ready?
      GoGoGibbon::Commands.cancel_user user
    end

    #
    # Update a user subscription given a user with the properties 
    # email, first_name, and last_name.  You can always pass a struct 
    # with these properties if your user object has these fields named 
    # differently.
    #
    def update_subscription old_email, user
      return unless ready?
      GoGoGibbon::Commands.update_subscription old_email, user
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
