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

## Usage

You'll start by creating a builder plugin which defines a GraphQL query using the DSL provided by the Graphlient gem. Then, in the `build` method of the plugin, you can execute the query and use that data to add content to your site.

Here's an example of using the GraphQL API provided by [Strapi](https://strapi.io) (a headless CMS) to turn blog posts authored in the CMS into Bridgetown posts:

```ruby
# plugins/builders/strapi_posts.rb

class StrapiPosts < SiteBuilder
  graphql :posts do
    query {
      posts {
        id
        title
        description
        body
        createdAt
      }
    }
  end

  def build
    queries.posts.each do |post|
      slug = Bridgetown::Utils.slugify(post.title)
      doc "#{slug}.md" do
        layout "post"
        date post.created_at
        front_matter post.to_h
        content post.body
      end
    end
  end
end
```

The `queries` object will contain the same graph names as what you define using the `graphql` class method. If the "data root" of the query is the same as the graph name, you don't have to access the root specifically. In other words, you don't have to write `queries.posts.posts.each do |post|`. However, if your data root is different, you'll need to access it specifically (see below where it's written as `queries.github.viewer…`).

Here's an example of using an authenticated GitHub API to access a list of repositories owned by the user associated with the API key. It includes configuring the Graphlient client to provide the API key in the request header, as well as utilizing query variables which get resolved at runtime.

```ruby
# plugins/builders/github_graphql.rb

class GitHubGraphql < SiteBuilder
  graphql :github do
    query(number_of_repos: :int) do
      viewer do
        repositories(first: :number_of_repos) do
          edges do
            node do
              name
              description
              createdAt
            end
          end
        end
      end
    end
  end

  def variables_for_github
    {
      # pull this out of the bridgetown.config.yaml, if present:
      number_of_repos: config[:github_repo_limit] || 10
    }
  end

  def build
    queries.github.viewer.repositories.edges.each do |item|
      repo = item.node
      slug = Bridgetown::Utils.slugify(repo.name)

      doc "#{slug}.md" do
        layout "repository"
        date repo.created_at
        title repo.name
        content repo.description
      end
    end
  end

  def graphql_endpoint
    "https://api.github.com/graphql"
  end

  def configure_graphql_client(client)
    client.options[:headers] = {
      "Authorization" => "bearer #{ENV["GITHUB_API_TOKEN"]}"
    }
  end
end
```

Note that these examples show just one GraphQL query defined in the plugin, but you can call the `graphql` class method multiple times with different graph names/queries, and access any or all of them in the `build` method.

If you run into any issues or need further assistance using GraphQL in your Bridgetown project, [please reach out to the Bridgetown community](https://www.bridgetownrb.com/docs/community) via chat or other means. If you think you've encountered a bug, please file an issue here in the GitHub repo. 

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

## Releasing

To release a new version of the plugin, simply bump up the version number in
`version.rb` and then run `script/release`.