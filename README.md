RequestLocals
=====================
[![Gem Version](https://badge.fury.io/rb/request_store_rails.svg)](http://badge.fury.io/rb/request_store_rails)
[![Build Status](https://travis-ci.org/ElMassimo/request_store_rails.svg)](https://travis-ci.org/ElMassimo/request_store_rails)
[![Test Coverage](https://codeclimate.com/github/ElMassimo/request_store_rails/badges/coverage.svg)](https://codeclimate.com/github/ElMassimo/request_store_rails)
[![Code Climate](https://codeclimate.com/github/ElMassimo/request_store_rails/badges/gpa.svg)](https://codeclimate.com/github/ElMassimo/request_store_rails)
[![Inline docs](http://inch-ci.org/github/ElMassimo/request_store_rails.svg)](http://inch-ci.org/github/ElMassimo/request_store_rails)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/ElMassimo/request_store_rails/blob/master/LICENSE.txt)

If you have ever needed to use a global variable in Rails, you know it sucks.

One of the usual tricks is to go for `Thread.current`, or if you have done your
homework, to use the awesome [`request_store`](https://github.com/steveklabnik/request_store).

```ruby
# Using Thread.current
def self.foo
  Thread.current[:foo] ||= 0
end

def self.foo=(value)
  Thread.current[:foo] = value
end

# Using RequestStore
def self.foo
  RequestStore.fetch(:foo) { 0 }
end

def self.foo=(value)
  RequestStore.store[:foo] = value
end
```

### The problem

- Using `Thread.current`, values can stick around even after the request is over,
since some servers have a pool of Threads that they reuse, which [can cause bugs](https://github.com/steveklabnik/request_store#the-problem).

- Using `request_store`, the storage is _*not actually*_ request local. Variables
are stored in `Thread.current`, except that the storage is cleared after each
request. However, this does not work when you need to use multiple threads per
request, _different_ threads access _different_ stores.

### The solution

Add this line to your Gemfile:

```ruby
gem 'request_store_rails'
```

And change the code to this:

```ruby
def self.foo
  RequestLocals.fetch(:foo) { 0 }
end

def self.foo=(value)
  RequestLocals.store[:foo] = value
end
```

Oh yeah, everywhere you used `Thread.current` or `RequestStore.store` just
change it to `RequestLocals.store`. Now your variables will actually be stored
in a true _request-local_ way.

### No Rails? No Problem!

A Railtie is added that configures the Middleware for you, but if you're not
using Rails, no biggie! Just use the Middleware yourself, however you need.
You'll probably have to shove this somewhere:

```ruby
use RequestStoreRails::Middleware
```

## Multi-Threading
The middleware in the gem sets a thread-local variable `:request_store_id` in
`Thread.current` for the main thread that is executing the request.

If you need to spawn threads within a server that is already using thread-based
concurrency, all you need to do is to make sure that the `:request_store_id`
variable is set for your threads, and you will be able to access the
`RequestLocals` as usual.

A good way to apply this pattern is by encapsulating it into a helper class:

```ruby
# Public: Custom thread class that allows us to preserve the request context.
class ThreadWithContext

  # Public: Returns a new Thread that preserves the context of the current request.
  def ThreadWithContext.new(*args)
    store_id = RequestLocals.current_store_id
    Thread.new {
      RequestLocals.set_current_store_id(store_id)
      yield *args
    }
  end
end

RequestLocals[:foo] = 1

ThreadWithContext.new {
  puts RequestLocals[:foo] # => 1
}
```
The gem does not provide such construct to avoid name collisions, you are free
to reuse the snippet above and adjust it to match your use case.

If you are feeling adventurous, you could try using this [fire and forget script](https://gist.github.com/ElMassimo/e2f99848db6a415f1aaa) and make all of your threads request aware, or
should I say _prepend and forget_ :smile:? Probably not something to be used in
a production environment, but whatever floats your boat :boat:

### Atomicity
Have in mind that the `RequestLocals.fetch(:foo) { 'default' }` operation is
[atomic](https://github.com/ElMassimo/request_store_rails/blob/master/lib/request_locals.rb#L62),
while `RequestLocal[:foo] ||= 'default'` is not. In most scenarios, there is not
a lot of difference, but if you are in a concurrent environment make sure to
use the one that is more suitable for your use case :wink:

## Replacing `request_store`
While the plan is not to achieve 100% compatibility, this gem usually works well
as a drop-in replacement. If you are using gems that rely on `RequestStore` but
for some reason you need them to use the appropriate request/thread scope, you
can try something like this on `application.rb` or similar:3
```ruby
if RequestStore != RequestLocals
  RequestStore::Railtie.initializers.clear
  Kernel.suppress_warnings { RequestStore = RequestLocals }
end
```

## Usage in Sidekiq
If your code depends on these global variables, it's likely that you'll need
to avoid collisions in Sidekiq workers (which would happen if the current store
id is `nil`).

You can use the following middleware, using the job id to identify the store:

```ruby
class Sidekiq::Middleware::Server::RequestStoreRails
  def call(_worker, job, _queue)
    RequestLocals.set_current_store_id(job['jid'])
    yield
  ensure
    RequestLocals.clear!
    RequestLocals.set_current_store_id(nil)
  end
end
```

Make sure to configure it as server middleware:

```ruby
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::RequestStoreRails
  end
end
```

## Special Thanks
The inspiration for this gem, tests, and a big part of the readme were borrowed
from the really cool [`request_store`](https://github.com/steveklabnik/request_store) gem.
Thanks [Steve](https://github.com/steveklabnik) :smiley:

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Don't forget to run the tests with `rake`.

License
--------

    Copyright (c) 2015 Máximo Mussini

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
