## RequestLocals 1.0.3 (2017-06-06) ##

*   Improve API compatibility with `request_store` by adding `key?` and `exist?`. Thanks [@abrisse](https://github.com/abrisse)!

## RequestLocals 1.0.2 (2017-01-25) ##

*   Remove Rails deprecation warning for `ActionDispatch::Reloader`. Thanks [@abrisse](https://github.com/abrisse)!

## RequestLocals 1.0.1 (2016-06-6) ##

*   Update the `concurrent-ruby` dependency to ensure tests are working in newer versions of Ruby. Thanks [@sgringwe](https://github.com/sgringwe)!

## RequestLocals 1.0.0 (2016-02-1) ##

*   Update internal cache to use a monitor-locked concurrent map from [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby), which [supports nested `fetch` calls](https://github.com/ElMassimo/request_store_rails/pull/1). Thanks [@Weihrauch](https://github.com/Weihrauch)!


## RequestLocals 0.0.3 (2015-04-13) ##

*   Removed the dependency for ActiveSupport in favour of Forwardable.


## RequestLocals 0.0.2 (2015-04-13) ##

*   The `fetch` operation is now atomic (uses `compute_if_absent`).


## RequestLocals 0.0.1 (2015-04-11) ##

*   Initial Version.
