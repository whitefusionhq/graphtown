require "rack/test"

class TestQueries < SiteBuilder
  include Rack::Test::Methods
  include Graphtown::QueryBuilder

  graphql :somethings do
    query {
      somethings {
        id
        title
        age
        createdAt
      }
    }
  end

  graphql :somethings_string, <<-GRAPHQL
    query {
      somethings {
        identifier: id
        title
        age
        createdAt
      }
    }
  GRAPHQL

  def build
    queries.somethings.each do |something|
      slug = Bridgetown::Utils.slugify(something.title)
      doc "#{slug}.md" do
        layout "post"
        date something.created_at
        front_matter something.to_h
        content "My **age** is #{something.age}"
      end
    end

    queries.somethings_string.somethings.each do |something|
      slug = Bridgetown::Utils.slugify(something.title)
      doc "#{slug}-string.md" do
        layout "post"
        date something.created_at
        front_matter something.to_h.merge(title: something.title + "-string")
        content "My string **age** is #{something.age}"
      end
    end
  end

  def test_app
    json_response = {
      data: {
        somethings: [
          {
            id: 1,
            title: "I'm a title!",
            age: 123,
            createdAt: "2020-08-14T15:58:29+00:00"
          }
        ]
      },
    }

    lambda do |env|
      query_input = env["rack.input"].read
      raise "Invalid GraphQL query input" unless query_input =~ /{\\n  somethings {\\n    (identifier: )?id\\n    title\\n    age\\n    createdAt\\n  }/

      if query_input.include?('identifier')
        json_response[:data][:somethings].first[:identifier] = 1
        json_response[:data][:somethings].first.delete(:id)
      end
      [200, {'Content-Type' => 'application/json'}, [json_response.to_json]]
    end
  end

  def configure_graphql_client(client)
    client.options[:schema_path] = __dir__ + "/introspectionSchema.json"
    client.http do |h|
      h.connection do |c|
        c.adapter Faraday::Adapter::Rack, test_app
      end
    end
  end
end
