# Graphtown

Easily consume GraphQL APIs for your Bridgetown website using a tidy Builder DSL on top of the [Graphlient](http://github.com/ashkan18/graphlient) gem.

## Installation

Run this command to add this plugin to your site's Gemfile:

```shell
$ bundle add graphtown -g bridgetown_plugins
```

And then add the Graphtown mixin to your site builder superclass:

```ruby
# plugins/site_builder.rb

class SiteBuilder < Bridgetown::Builder
  include Graphtown::QueryBuilder
end
```

You'll need to add your desired GraphQL API endpoint to the site config YAML:

```yaml
# bridgetown.config.yml

graphql_endpoint: http://localhost:1337/graphql
```

Alternatively, you can override the `graphql_endpoint` method in your site builder or a specific builder plugin:

```ruby
def graphql_endpoint
  "https://some.other.domain/graphql"
end
```

---

# Documentation coming soon…

## Usage

The plugin will…

### Optional configuration options

The plugin will automatically use any of the following metadata variables if they are present in your site's `_data/site_metadata.yml` file.

…

## Testing

* Run `bundle exec rspec` to run the test suite
* Or run `script/cibuild` to validate with Rubocop and test with rspec together.

## Contributing

1. Fork it (https://github.com/whitefusionhq/graphtown/fork)
2. Clone the fork using `git clone` to your local development machine.
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request