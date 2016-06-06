## RequestLocals 1.0.0 (June 6, 2016) ##

*   Update the `concurrent-ruby` dependency to ensure tests are working in newer versions of Ruby. Thanks [@sgringwe](https://github.com/sgringwe)!

## RequestLocals 1.0.0 (February 1, 2016) ##

*   Update internal cache to use a monitor-locked concurrent map from [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby), which [supports nested `fetch` calls](https://github.com/ElMassimo/request_store_rails/pull/1). Thanks [@Weihrauch](https://github.com/Weihrauch)!


## RequestLocals 0.0.3 (April 13, 2015) ##

*   Removed the dependency for ActiveSupport in favour of Forwardable.


## RequestLocals 0.0.2 (April 13, 2015) ##

*   The `fetch` operation is now atomic (uses `compute_if_absent`).


## RequestLocals 0.0.1 (April 11, 2015) ##

*   Initial Version.
