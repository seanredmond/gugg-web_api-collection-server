require "rubygems"
require "sequel"
require "yaml"
require "json"

cfg = YAML.load_file('collection_db_spec.yml')
db = cfg['db']['mysql']
@DB = Sequel.mysql(db['db'], :user=>db['user'], :password=>db['password'], 
  :host=>db['host'], :charset=>'utf8')

require 'gugg-web_api-collection-server'

require 'rack/test'

# set :environment, :test

describe 'API Server' do
  include Rack::Test::Methods

  def app
    Gugg::WebApi::Collection::Server::App
  end

  describe "/" do
    before :all do
      get '/'
      @data = JSON.parse(last_response.body)
    end

    it "says hello" do
      @data.should be_an_instance_of Hash
    end

    it "should be a list of links" do
      @data["_links"].should be_an_instance_of Hash
      @data["_links"].each do |l,v|
        v["href"].should be_an_instance_of String
      end
    end
  end
end
