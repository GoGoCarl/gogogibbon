GoGoGibbon
==========

GoGoGibbon is a simple extension of Gibbon that provides wrapper methods 
for subscribing and unsubscribing users to lists.  It also works off of 
initialization files instead of environment variables.

## Rails Installation

1.  Add the GoGoGibbon gem entry to your Gemfile

    ```ruby
    gem 'gogogibbon', :git => 'git://github.com/GoGoCarl/gogogibbon.git'
    ```
2.  Run <code>bundle install</code>

3.  Configure GoGoGibbon with your MailChimp information.  You will need 
    an API key from your MailChimp account, and the name of the list you 
    to which you want new users subscribed.  You can specify this in a 
    global initialization file under config/initializers, or to get 
    different behavior in development vs. production, specify thse in 
    the approprivate config/enviroment/ file:

    ```ruby
    GoGoGibbon::Config.api_key = 'Your API Key'
    GoGoGibbon::Config.subscribed = 'Subscription List'
    ```

4.  A restart is required to pick up new gems and configuration.

## Additional Configuration

Optionally, you can name a cancellation list, and users will be removed 
from the subscription list and added to the cancellation list when 
calling <code>cancel_user</code>.

```ruby
GoGoGibbon::Config.unsubscribed = 'Cancellation List'
```

Optionally, you can specify how you want error handled when you have 
misconfigured MailChimp:

```ruby
GoGoGibbon::Config.on_fail = :error || :silent || :warn
```

<code>:warn</code> will print a message to the console,
<code>:error</code> will thrown an Exception, and <code>:silent</code> 
will do nothing.  The default is warn.

## Usage

See <code>lib/gogogibbon.rb</code> for a list of all available methods. 
Of course, you can still use gibbon directly, these are simply helpers 
to speed up the process.
