
require 'bundler/setup'
require 'sinatra'
require 'sinatra/json'
require 'graphql'
require 'apollo-federation'
require 'optparse'
require 'rack/contrib'
require 'byebug'

class BaseField < GraphQL::Schema::Field
  include ApolloFederation::Field
end

class BaseObject < GraphQL::Schema::Object
  include ApolloFederation::Object

  field_class BaseField
end

class BaseUnion < GraphQL::Schema::Union
end

class Product < BaseObject
  extend_type
  key fields: :upc
end

class SampleApp < Sinatra::Base
  use Rack::JSONBodyParser

  post '/' do
    result = self.class.schema.execute(
      params[:query],
      variables: params[:variables],
      context: { current_user: nil },
    )
    json result
  end

  def self.parse_options
    options = {}
    parser = OptionParser.new do |opts|
      opts.on_tail('-s', 'Standard schema') do |_test|
        options[:schema] = true
      end

      opts.on_tail('-f', 'Federarted schema') do |_test|
        options[:sdl] = true
      end

      opts.on('-p', 'Port') do |port|
        options[:Port] = port
      end
    end

    parser.parse!
    options
  end

  def self.run(port)
    options = parse_options
    puts "ARGV: #{ARGV.inspect}"
    puts "options: #{options.inspect}"

    if options[:schema]
      name = schema.name.downcase

      File.write("./#{name}_sdl.graphql", schema.to_definition)
      return
    end

    if options[:sdl]
      name = schema.name.downcase

      File.write("./#{name}_federation_sdl.graphql", schema.federation_sdl)
      return
    end

    Rack::Handler::WEBrick.run(self, **{Port: port}.merge(options))

  end
end



