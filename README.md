# N+1 in union types

## Setup

### prerequisites

install `router` binary in current directory, or symlink or copy existing

ruby >= 3.0 is required for this to work, but samples can be replicated in other language

```bash
# install gems
bundle install
# install foreman
gem install foremal
# start all processes
foreman start
```

## Commands used to run and generate files

|file|command|description|
|----|-------|-|
|schemaa_federation_sdl.graphql|`bundle exec ruby ./schema_a.rb -f`|Schema of the subgraph A|
|schemab_federation_sdl.graphql|`bundle exec ruby ./schema_b.rb -f`| Schema of the subgraph B|
|supergraph.graphql|`rover supergraph compose --config ./supergraph-config.yml > supergraph.graphql`| supergraph schema|

## List of processes in Procfile

|name|command|desc|
|-|-|-|
|router| `./router --dev --supergraph supergraph.graphql --log info -c config.yml` | router binary
|schemaA| `bundle exec ruby ./schema_a.rb` | subgraph A
|schemaA| `bundle exec ruby ./schema_b.rb` | subgraph B

### query used

```graphql
query ExampleQuery {
  actions {
    config {
      ... on ConfigOne {
        id
        otherTemplate {
          name
          body
          id
        }
        someTemplate {
          name
          body
          id
        }
      }
      ... on ConfigThree {
        id
        wrongTemplate {
          name
          body
          id
        }
      }
      ... on ConfigTwo {
        id
        leftTemplate {
          name
          body
          id
        }
        rightTemplate {
          name
          body
          id
        }
      }
    }
  }
}

```

```graphql
QueryPlan {
  Sequence {
    Fetch(service: "schemaA") {
      {
        actions {
          config {
            __typename
            ... on ConfigOne {
              id
              otherTemplate {
                __typename
                id
              }
              someTemplate {
                __typename
                id
              }
            }
            ... on ConfigThree {
              id
              wrongTemplate {
                __typename
                id
              }
            }
            ... on ConfigTwo {
              id
              leftTemplate {
                __typename
                id
              }
              rightTemplate {
                __typename
                id
              }
            }
          }
        }
      }
    },
    Parallel {
      Flatten(path: "actions.@.config.otherTemplate") {
        Fetch(service: "schemaB") {
          {
            ... on Template {
              __typename
              id
            }
          } =>
          {
            ... on Template {
              name
              body
            }
          }
        },
      },
      Flatten(path: "actions.@.config.someTemplate") {
        Fetch(service: "schemaB") {
          {
            ... on Template {
              __typename
              id
            }
          } =>
          {
            ... on Template {
              name
              body
            }
          }
        },
      },
      Flatten(path: "actions.@.config.wrongTemplate") {
        Fetch(service: "schemaB") {
          {
            ... on Template {
              __typename
              id
            }
          } =>
          {
            ... on Template {
              name
              body
            }
          }
        },
      },
      Flatten(path: "actions.@.config.leftTemplate") {
        Fetch(service: "schemaB") {
          {
            ... on Template {
              __typename
              id
            }
          } =>
          {
            ... on Template {
              name
              body
            }
          }
        },
      },
      Flatten(path: "actions.@.config.rightTemplate") {
        Fetch(service: "schemaB") {
          {
            ... on Template {
              __typename
              id
            }
          } =>
          {
            ... on Template {
              name
              body
            }
          }
        },
      },
    },
  },
}
```