module GoGoGibbon

  class Callbacks

    def initialize opts={}
      @options = { :thread => false }
      @options.merge! opts
    end

    def after_create record
      run do
        GoGoGibbon.subscribe record
      end
    end

    def after_update record
      if record.email_changed? || record.first_name_changed? || record.last_name_changed?
        run do 
          GoGoGibbon.update_subscription record.email_was, record
        end
      end
    end

    def after_destroy record
      run do
        GoGoGibbon.cancel_user record
      end
    end

    def run &block
      if @options[:thread] == true
        Thread.new do
          yield
        end
      else
        yield
      end
    end

  end

end
