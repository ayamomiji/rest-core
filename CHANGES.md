# CHANGES

## rest-core 1.0.0 -- 2012-03-17

This is a very significant release. The most important change is now we
support asynchronous requests, by either passing a callback block or using
fibers in Ruby 1.9 to make the whole program still look synchronous.

Please read [README.md](https://github.com/cardinalblue/rest-core/blob/master/README.md)
or [example](https://github.com/cardinalblue/rest-core/tree/master/example)
for more detail.

* [`Client`] Client#inspect is fixed for clients which do not have any
  attributes.

* [`Client`] HEAD, OPTIONS, and PATCH requests are added. For example:

  ``` ruby
      client = Client.new
      client.head('path')
      client.options('path')
      client.patch('path')
  ```

* [`Client`] Now if you passed a block to either `get` or `post` or other
  requests, the response would be returned to the block instead the caller.
  In this case, the return value of `get` or `post` would be the client
  itself. For example:

  ``` ruby
      client = Client.new
      client.get('path'){ |response| puts response.insepct }.
             get('math'){ |response| puts response.insepct }
  ```

* [`RestClient`] Now all the response headers names are converted to upper
  cases and underscores (_). Also, if a header has only presented once, it
  would not be wrapped inside an array. This is more consistent with
  em-http-request, cool.io-http, and http_parser.rb

* [`RestClient`] From now on, the default HTTP client, i.e. `RestClient` won't
  follow any redirect. To follow redirect, please use `FollowRedirect`
  middleware. Two reasons. One is that the underlying HTTP client should
  be minimal. Another one is that a FollowRedirect middleware could be
  used for all HTTP clients. This would make it more consistent across
  all HTTP clients.

* [`RestClient`] Added a patch to avoid `"123".to_i` returning `200`,
  please see: <https://github.com/archiloque/rest-client/pull/103>
  I would remove this once after this patch is merged.

* [`RestClient`] Added a patch to properly returning response whenever
  a redirect is happened. Please see:
  <https://github.com/archiloque/rest-client/pull/118>
  I would remove this once after this patch is merged.

* [`FollowRedirect`] This middleware would follow the redirect. Pass
  :max_redirects for the maximum redirect times. For example:

  ``` ruby
      Client = RestCore::Builder.client do
        use FollowRedirect, 2 # default :max_redirects
      end
      client = Client.new
      client.get('path', {}, :max_redirects => 5)
  ```

* [`Middleware`] Added `Middleware#run` which can return the underlying HTTP
  client, if you need to know the underlying HTTP client can support
  asynchronous requests or not.

* [`Cache`] Now it's asynchrony-aware.
* [`CommonLogger`] Now it's asynchrony-aware.
* [`ErrorDetector`] Now it's asynchrony-aware.
* [`ErrorHandler`] Now it's asynchrony-aware.
* [`JsonDecode`] Now it's asynchrony-aware.
* [`Timeout`] Now it's asynchrony-aware.

* [`Universal`] `FollowRedirect` middleware is added.
* [`Universal`] `Defaults` middleware is removed.

* Added `RestCore::ASYNC` which should be the callback function which is
  called whenever the response is available. It's similar to Rack's
  async.callback.

* Added `RestCore::TIMER` which is only used in Timeout middleware. We need
  this to disable timer whenever the response is back.

* [`EmHttpRequestAsync`] This HTTP client accepts a block to make asynchronous
  HTTP requests via em-http-request gem.

* [`EmHttpRequestFiber`] This HTTP client would make asynchronous HTTP
  requests with em-http-request but also wrapped inside a fiber, so that it
  looks synchronous to the program who calls it.

* [`EmHttpRequest`] This HTTP client would would use `EmHttpRequestAsync` if
  a block (`RestCore::ASYNC`) is passed, otherwise use `EmHttpRequestFiber`.

* [`CoolioAsync`] This HTTP client is basically the same as
  `EmHttpRequestAsync`, but using cool.io-http instead of em-http-request.

* [`CoolioFiber`] This HTTP client is basically the same as
  `EmHttpRequestFiber`, but using cool.io-http instead of em-http-request.

* [`Coolio`] This HTTP client is basically the same as `EmHttpRequest`,
    but using cool.io-http instead of em-http-request.

* [`Auto`] This HTTP client would auto-select a suitable client. Under
  eventmachine, it would use `EmHttpRequest`. Under cool.io, it would use
  `Coolio`. Otherwise, it would use `RestClient`.

## rest-core 0.8.2 -- 2012-02-18

### Enhancement

* [`DefaultPayload`] This middleware allows you to have default payload for
  POST and PUT requests.

* [`Client`] Now `lighten` would give all Unserializable to nil instead of
  false

### Bugs fixes

* [`ErrorDetector`] Now it would do nothing instead of crashing if there's no
  any error_detector.

## rest-core 0.8.1 -- 2012-02-09

### Enhancement

* [`Wrapper`] Introducing `Wrapper.default_app` (also `Builder.default_app`)
  which you can change the default app from `RestClient` to other HTTP
  clients.

### Bugs fixes

* [`OAuth1Header`] Correctly handle the signature when it comes to multipart
  requests.

* [`ErrorDetectorHttp`] Fixed argument error upon calling `lighten` for
  clients using this middleware. (e.g. rest-more's Twitter client)

## rest-core 0.8.0 -- 2011-11-29

Changes are mostly related to OAuth.

### Incompatible changes

* [`OAuth1Header`] `callback` is renamed to `oauth_callback`
* [`OAuth1Header`] `verifier` is renamed to `oauth_verifier`

* [`Oauth2Header`] The first argument is changed from `access_token` to
  `access_token_type`. Previously, the access_token_type is "OAuth" which
  is used in Mixi. But mostly, we might want to use "Bearer" (according to
  [OAuth 2.0 spec][]) Argument for the access_token is changed to the second
  argument.

* [`Defaults`] Now we're no longer call `call` for any default values.
  That is, if you're using this: `use s::Defaults, :data => lambda{{}}`
  that would break. Previously, this middleware would call `call` on the
  lambda so that `data` is default to a newly created hash. Now, it would
  merely be default to the lambda. To make it work as before, please define
  `def default_data; {}; end` in the client directly. Please see
  `OAuth1Client` as an example.

[OAuth 2.0 spec]: http://tools.ietf.org/html/draft-ietf-oauth-v2-22

### Enhancement

* [`AuthBasic`] Added a new middleware which could do
  [basic authentication][].

* [`OAuth1Header`] Introduced `data` which is a hash and is used to store
  tokens and other information sent from authorization servers.

* [`ClientOauth1`] Now `authorize_url!` accepts opts which you can pass
  `authorize_url!(:oauth_callback => 'http://localhost/callback')`.

* [`ClientOauth1`] Introduced `authorize_url` which would not try to ask
  for a request token, instead, it would use the current token as the
  request token. If you don't understand what does this mean, then keep
  using `authorize_url!`, which would call this underneath.

* [`ClientOauth1`] Introduced `authorized?`
* [`ClientOauth1`] Now it would set `data['authorized'] = 'true'` when
  `authorize!` is called, and it is also used to check if we're authorized
  or not in `authorized?`

* [`ClientOauth1`] Introduced `data_json` and `data_json=` which allow you to
  serialize and deserialize `data` with JSON along with a `sig` to check
  if it hasn't been changed. You can put this into browser cookie. Because
  of the `sig`, you would know if the user changed something in data without
  using `consumer_secret` to generate a correct sig corresponded to the data.

* [`ClientOauth1`] Introduced `oauth_token`, `oauth_token=`,
  `oauth_token_secret`, `oauth_token_secret=`, `oauth_callback`,
  and `oauth_callback=` which take the advantage of `data`.

* [`ClientOauth1`] Introduced `default_data` which is a hash.

[basic authentication]: http://en.wikipedia.org/wiki/Basic_access_authentication

## rest-core 0.7.2 -- 2011-11-04

* Moved rib-rest-core to [rest-more][]
* Moved `RestCore::Config` to [rest-more][]
* Renamed `RestCore::Vendor` to `RestCore::ParseQuery`

## rest-core 0.7.0 -- 2011-10-08

### IMPORTANT CHANGE!

From now on, prebuilt clients such as `RC::Facebook`, `RC::Twitter` and
others are moved to [rest-more][]. Since bundler didn't like cyclic
dependency, so rest-core is not depending on rest-more. Please install
_rest-more_ if you want to use them.

[rest-more]: https://github.com/cardinalblue/rest-more

## rest-core 0.4.0 -- 2011-09-26

### Incompatible changes

* [dry] Now `RestCore::Ask` is renamed to `RestCore::Dry` for better
  understanding. Thanks miaout17

* [client] Now `request` method takes an env and an app to make requests,
  instead of a weird requests array.

* [client] Now if you really want to disable something, for example,
  disabling cache when the default cache is `Rails.cache`, you'll need to
  pass `false` instead of `nil`. This is because `nil` stands for using
  defaults in rest-core.

* [client] Defaults priorities are changed to:
  per-request > instance variable > class defaults > middleware defaults
  See *test_client.rb* for more detailed definition. If you don't understand
  this, don't worry, since then this won't affect you.

### Compatible changes

* [client] Introduced a new method `request_full` which is exactly the same
  as `request` but also returns various information from the app, including
  `RESPONSE_STATUS` and `RESPONSE_HEADERS`

* [client] Removed various unused, untested, undocumented legacy from
  rest-graph.

* [error] Introduced `RestCore::Error` which is the base class for all
  exceptions raised by rest-core

* [builder] Now `RestCore::Builder.default_app` is the default app which
  would be used for building clients without setting an app. By default,
  it's `RestClient`, but you can change it if you like.

* [builder] It no longer builds a @wrapped app. If you don't understand this,
  then this does nothing for you. It's an internal change. (or bug fix)

* [wrapper] Now `RestCore::Wrapper.default_app` is the default app which
  would be used for wrapping middlewares without setting an app. By default,
  it's `Dry`, but you can change it if you like.

* [wrapped] Fixed a bug that force middlewares to implement `members` method,
  which should be optional. Thanks miaout17

* [facebook][rails_util] Now default cache is `Rails.cache` instead of nil
* [simple]   Added a Simple client, which only wraps RestClient
* [univeral] Added an Universal client, which could be used for anything
* [flurry]   Added a Flurry client, along with its `Flurry::RailsUtil`
* [mixi]     Added a Mixi client

* [bypass] Added a Bypass middleware which does nothing but passing env
* [oauth2_header] OAuth2Header is a middleware which would pass access_token
  in header instead of in query string.
* [common_logger] nil object would no longer be logged
* [json_decode] Do nothing if we are being asked for env (dry mode)
* [cache] Now default `:expires_in` is 600 down from 3600
* [middleware] Now not only query values would be escaped, but also keys.

* [rib-rest-core] Introduced an interactive shell. You'll need [rib][] to
  run this: `rib rest-core`. It is using an universal client to access
  arbitrary websites.

[rib]: https://github.com/godfat/rib

## rest-core 0.3.0 -- 2011-09-03

* [facebook] RestGraph is Facebook now.
* [facebook] Facebook::RailsUtil is imported from [rest-graph][]
* [facebook] Use json_decode instead of auto_decode as rest-graph
* [facebook] No longer calls URI.encode on Facebook broken URL
* [twitter] Fixed opts in Twitter#tweet
* [twitter] Introduced Twitter::Error instead of RuntimeError!
* [twitter] By default log nothing
* [rest-core] We no longer explicitly depends on Rack
* [rest-core] Added a shorthand RC to access RestCore
* [rest-core] Eliminated a lot of warnings
* [cache] All clients no longer have default hash cache
* [oauth2_query] Now we always use the term "access_token"
* [config] Now Config#load and Config#load_for_rails take namespace
  e.g. rest-core.yaml:

      development:
        facebook:
          app_id: 123
        twitter:
          consumer_key: abc

[rest-graph]: https://github.com/cardinalblue/rest-graph

## rest-core 0.2.3 -- 2011-08-27

* Adding rack as a runtime dependency for now.
  To reduce frustration for new comer...

## rest-core 0.2.2 -- 2011-08-26

* Adding rest-client as a runtime dependency for now.
  In the future, it should be taken out because of multiple
  selectable HTTP client backend (rest-core app).

## rest-core 0.2.1 -- 2011-08-25

* [twitter] Fixed default site
* [twitter] Now Twitter#tweet accepts a 2nd argument to upload an image
* [oauth1_header] Fixed a bug for multipart posting. Since Rails' uploaded
                  file is not an IO object, so we can't only test against
                  IO object, but also read method.

## rest-core 0.2.0 -- 2011-08-24

* First serious release!
