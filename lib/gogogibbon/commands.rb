require 'gibbon'

module GoGoGibbon
  module Commands
    class << self
      #
      # Subscribe to the subscription list
      #
      def subscribe user, list_name=sub_list
        result = false
        sub_id = list list_name
        unless sub_id.nil?
          begin
            result = chimp.list_subscribe :id => sub_id, 
              :email_address => user.email,
              :merge_vars => { 'FNAME' => user.first_name, 'LNAME' => user.last_name }, 
              :double_optin => false, 
              :send_welcome => false
          rescue Gibbon::MailChimpError => e
            raise e unless e.code == 214
          end
        end
        result
      end

      def subscribe_all list_name=sub_list
        result = false

        sub_id = list list_name
        unless sub_id.nil?
          batch = []

          User.all.each do |user|
            batch << { 
              'EMAIL' => user.email, 'FNAME' => user.first_name, 'LNAME' => user.last_name
            }
          end

          result = chimp.list_batch_subscribe :id => sub_id,
            :batch => batch, 
            :double_optin => false,
            :update_existing => false
        end
        result
      end

      def unsubscribe user, list_name=unsub_list
        result = false

        sub_id = list list_name
        unless sub_id.nil?
          begin
            result = chimp.list_unsubscribe :id => sub_id,
              :email_address => user.email,
              :delete_member => true,
              :send_goodbye => false,
              :send_notify => false
          rescue Gibbon::MailChimpError => e
            raise e unless e.code == 215
          end
        end
        result
      end

      #
      # Unsubscribe from the subscription list, 
      # subscribe to the unsubscription list.
      #
      def cancel_user user
        result = false
        unsubscribe user, sub_list
        result = subscribe user, unsub_list
        result
      end

      def list list_name
        lists = nil
        list  = nil
        begin
          lists = chimp.lists :filters => {:list_name => list_name, :exact => true}
        rescue Gibbon::MailChimpError => e
          raise e unless e.code == 200
        end
        unless lists.nil?
          if lists['error'].nil?
            list = lists['data'].first['id'] if lists['total'] > 0
          elsif lists['code'] == -90
            puts 'No Mailchimp API key supplied.'
          end
        end
        list
      end

      def update_subscription old_email, user, list_name=sub_list
        result = false

        sub_id = list list_name
        unless sub_id.nil?
          batch = []
          batch << {
            'EMAIL' => user.email, 'FNAME' => user.first_name, 'LNAME' => user.last_name
          }

          result = chimp.list_batch_subscribe :id => sub_id,
            :batch => batch, 
            :double_optin => false,
            :update_existing => true
        end
        result
      end

      def chimp
        GoGoGibbon::Config.chimp
      end

      def sub_list
        GoGoGibbon::Config.subscribed
      end

      def unsub_list
        GoGoGibbon::Config.unsubscribed
      end
    end
  end
end
