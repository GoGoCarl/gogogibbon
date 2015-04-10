module GoGoGibbon
  module Methods

    def self.included base
      base.send :extend, ClassMethods
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

      #
      # Return a list of users eligible to receive mail. Defaults to this class, 
      # but can return anything relation
      #
      def Mailable
        self
      end

    end

  end
end

ActiveRecord::Base.send :include, GoGoGibbon::Methods
