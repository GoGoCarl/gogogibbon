require 'gibbon'

module GoGoGibbon
  module Commands
    class << self
      # Store a hash of list name to ID
      LIST_CACHE = {}

      #
      # Subscribe to the subscription list
      #
      def subscribe user, list_name=sub_list
        result = false
        sub_id = list list_name
        unless sub_id.nil?
          begin
            body = {
              'email_address' => user.email,
              'status' => 'subscribed',
              'merge_fields' => { 'FNAME' => user.first_name, 'LNAME' => user.last_name }
            }
            result = chimp.lists(sub_id).members.create(body: body)
          rescue Gibbon::MailChimpError => e
            raise e unless e.body['status'] == 400 && e.body['title'] == 'Member Exists'
          end
        end
        result
      end

      def subscribe_set users, list_name=sub_list
        result = false

        sub_id = list list_name
        unless sub_id.nil?
          batch = []

          defaults = { 'method' => 'POST', 'path' => "lists/#{sub_id}/members" }
          handler = lambda do |user|
            batch << defaults.merge("body" => {
              'email_address' => user.email, 'status' => 'subscribed',
              'merge_fields' => { 'FNAME' => user.first_name, 'LNAME' => user.last_name }
            }.to_json)
          end

          if users.respond_to? :find_each
            users.find_each { |user| handler.call(user) }
          else
            users.each { |user| handler.call(user) }
          end

          body = { "operations" => batch }

          result = chimp.batches.create(body: body)
          batch_id = result['id']
          attempts = 1, backoff = 2
          while result['status'] != 'finished' && attempts <= 10
            sleep attempts * backoff
            result = chimp.batches(batch_id).retrieve
            attempts += 1
          end

          if result['status'] == 'finished'
            result = {
              'add_count' => result['finished_operations'],
              'update_count' => 0,
              'error_count' => result['errored_operations'],
              'total_count' => result['total_operations'],
              'errors' => []
            }

          else
            result = false
          end

        end
        result
      end

      def unsubscribe user, list_name=unsub_list
        result = false

        sub_id = list list_name
        unless sub_id.nil?
          md5 = Digest::MD5.new
          md5.update user.email.downcase
          user_id = md5.hexdigest
          begin
            result = chimp.lists(sub_id).members(user_id).delete
          rescue Gibbon::MailChimpError => e
            if e.body['status'] == 404
              return true
            else
              raise e
            end
          end
        end
        result.nil?
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
        return LIST_CACHE[list_name] if LIST_CACHE.key?(list_name)
        items = lists
        list = nil
        if items
          p = items.select { |i| i['name'] == list_name }
          if p.any?
            list = p.first['id']
          end
        end
        list
      end

      def update_subscription old_email, user, list_name=sub_list
        result = false

        sub_id = list list_name
        unless sub_id.nil?
          if old_email != user.email
            unsubscribe Struct.new(:email).new(old_email), list_name
          end

          body = { 
            'email_address' => user.email, 'status' => 'subscribed',
            'merge_fields' => { 'FNAME' => user.first_name, 'LNAME' => user.last_name }
          }

          result = chimp.lists(sub_id).members.upsert(body: body)
        end
        result
      end

      def lists
        result = nil
        begin
          result = chimp.lists.retrieve(params: { "count" => 100, "fields" => "lists.id,lists.name" })["lists"]
          result.each do |item|
            LIST_CACHE[item['name']] = item['id']
          end
        rescue Gibbon::MailChimpError => e
          puts e.detail
          raise e unless e.body['status'] == 200
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
