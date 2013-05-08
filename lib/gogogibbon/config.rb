require 'gibbon'

module GoGoGibbon
  class Config
    class << self

      attr_accessor :subscribed, :unsubscribed, :api_key, :chimp, :on_fail

      def api_key=(value)
        @chimp = Gibbon.new value
        @api_key = value
      end

      def configured?
        !(@api_key.nil? || @subscribed.nil?)
      end

      def fail!
        msg = 'MailChimp Configuration not complete. Please specify an api_key and subscription list.'
        if @on_fail == :error
          raise Exception.new msg
        else
          puts msg unless @on_fail == :silent
        end
      end
    end
  end
end
