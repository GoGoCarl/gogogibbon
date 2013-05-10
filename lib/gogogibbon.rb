require 'gogogibbon/commands'
require 'gogogibbon/config'
require 'gogogibbon/version'
require 'gogogibbon/callbacks'

module GoGoGibbon
  class << self

    #
    # Add a new user to the MailChimp subscription list
    #
    def subscribe user
      execute { GoGoGibbon::Commands.subscribe user }
    end

    #
    # Add all users in the database to the MailChimp subscription list. 
    # This will not re-add them if they are already there.
    #
    def subscribe_all
      execute { GoGoGibbon::Commands.subscribe_all }
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

    def included base
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      #
      # Options map can contain the following:
      # * :thread -- true to run in a new thread, false otherwise (default false)
      #

      #
      # When a user is created, subscribe that user to the mailing list
      #
      def mailchimp_on_create opts={}
        after_create GoGoGibbon::Callbacks.new opts
      end

      #
      # When a user is updated, update their profile, if necessary
      #
      def mailchimp_on_update opts={}
        after_update GoGoGibbon::Callbacks.new opts
      end

      #
      # When a user is deleted, cancel that user.
      #
      def mailchimp_on_destroy opts={}
        after_destroy GoGoGibbon::Callbacks.new opts
      end

    end

  end
end
