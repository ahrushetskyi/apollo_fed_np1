#!/bin/ruby

require_relative './server.rb'

TEMPALTES = [
  {
    id: 1,
    name: "awsome template",
    body: "<% this %>"
  },
  {
    id: 2,
    name: "not so awsome template",
    body: "<% this is %>"
  },
  {
    id: 3,
    name: "wrong template",
    body: "<% this is a sample %>"
  },
  {
    id: 4,
    name: "right template",
    body: "<% this is a samle of something %>"
  },
]

class Template < BaseObject
  key fields: [:id]

  field :id, ID, null: false
  field :name, String, null: false
  field :body, String, null: false

  def self.resolve_reference(reference, _context)
    TEMPALTES.find{|t| t[:id].to_s == reference[:id] }
  end
end

class SchemaB < GraphQL::Schema
  include ApolloFederation::Schema
  federation version: '2.0'

  orphan_types Template
end

class App < SampleApp
  def self.schema
    SchemaB
  end
end

App.run(5004)


