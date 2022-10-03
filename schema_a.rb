#!/bin/ruby

require_relative './server.rb'

id_seq = 0

ACTIONS = [
  {
    id: id_seq+=1,
    delay: 1,
    default_template: {
      id: 1
    },
    config: {
      id: id_seq+=1,
      type: :one,
      some_template: {
        id: 2
      },
      other_template: {
        id: 3
      },
    }
  },
  {
    id: id_seq+=1,
    delay: 1,
    default_template: {
      id: 1
    },
    config: {
      id: id_seq+=1,
      type: :two,
      left_template: {
        id: 4
      },
      right_template: {
        id: 3
      },
    }
  },
  {
    id: id_seq+=1,
    delay: 1,
    default_template: {
      id: 1
    },
    config: {
      id: id_seq+=1,
      type: :two,
      left_template: {
        id: 3
      },
      right_template: {
        id: 1
      },
    }
  },
  {
    id: id_seq+=1,
    delay: 1,
    default_template: {
      id: 1
    },
    config: {
      id: id_seq+=1,
      type: :three,
      wrong_template: {
        id: 4
      },
    }
  },
]

class Template < BaseObject
  extend_type
  key fields: [:id]

  field :id, ID, null: false
end

class ConfigOne < BaseObject
  field :id, ID, null: false
  field :some_template, Template, null: false
  field :other_template, Template, null: false
end
class ConfigTwo < BaseObject
  field :id, ID, null: false
  field :left_template, Template, null: false
  field :right_template, Template, null: false
end
class ConfigThree < BaseObject
  field :id, ID, null: false
  field :wrong_template, Template, null: false
end

class ActionConfig < BaseUnion
  possible_types ConfigOne, ConfigTwo, ConfigThree

  def self.resolve_type(object, _context)
    case object[:type]
    when :one
      ConfigOne
    when :two
      ConfigTwo
    when :three
      ConfigThree
    else
      raise GraphQL::ExecutionError, "Unknown type"
    end
  end
end

class Action < BaseObject
  key fields: [:id]

  field :id, ID, null: false
  field :delay, Integer, null: false
  field :default_template, Template, null: false
  field :config, ActionConfig, null: false
end

class Query < BaseObject
  field :actions, [Action], null: false

  def actions
    ACTIONS
  end
end

class SchemaA < GraphQL::Schema
  include ApolloFederation::Schema
  federation version: '2.0'

  query Query
end

class App < SampleApp
  def self.schema
    SchemaA
  end
end

App.run(5003)


