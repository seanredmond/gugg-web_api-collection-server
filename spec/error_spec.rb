require "rubygems"
require "sequel"
# require "yaml"
require "json"

# cfg = YAML.load_file('collection_server_spec.yml')
# db = cfg['db']['mysql']
# @DB = Sequel.mysql(db['db'], :user=>db['user'], :password=>db['password'], 
#   :host=>db['host'], :charset=>'utf8')

cwd = File.dirname(__FILE__)

@DB=Sequel.sqlite

structure = File.open(File.join(cwd, 'test-structure.sql'), 'r').read
@DB.execute_ddl(structure)

contents = File.open(File.join(cwd, 'test-data.sql'), 'r').read
@DB.execute_dui(contents)

require 'gugg-web_api-collection-server'

require 'rack/test'

goodkey = 'ed3c63916af176b3af878f98156e07f4'
badkey = '00ea1ae3bd1fef315ba91d2ad8a125ad'

describe 'API Server' do
  include Rack::Test::Methods

  def app
    Gugg::WebApi::Collection::Server::App
  end

  context "for bad parameters" do
    before :all do
      get '/acquisitions', {:per_page => 'xyz'}, {
        'HTTP_X_GUGGENHEIM_API_KEY' => goodkey,
        'Accept' => 'application/vnd.guggenheim.collection+json'
      }
      @rsp = last_response
      @json = JSON.parse(last_response.body)
    end

    it "should return a 400" do
      @rsp.status.should eq 400
    end

    it "should return JSON error with the correct code" do
      @json["error"]["code"].should eq 400
    end
  end

  context "for authentication" do
    context "with no key" do
      before :all do 
        get '/'
        @rsp = last_response
        @json = JSON.parse(last_response.body)
      end

      it "should return a 401" do
        @rsp.status.should eq 401
      end

      it "should have a WWW-Authenticate header" do
        @rsp.header["WWW-Authenticate"].should_not be_nil
      end

      it "should return JSON error with the correct code" do
        @json["error"]["code"].should eq 401
      end
    end

    context "with a bad key" do
      before :all do 
        get '/', {}, {'HTTP_X_GUGGENHEIM_API_KEY' => badkey}
        @rsp = last_response
        @json = JSON.parse(last_response.body)
      end

      it "should return a 401" do
        @rsp.status.should eq 401
      end

      it "should have a WWW-Authenticate header" do
        @rsp.header["WWW-Authenticate"].should_not be_nil
      end

      it "should return JSON error with the correct code" do
        @json["error"]["code"].should eq 401
      end
    end
  end

  context "for content type" do
    context "with no Accept header" do
      before :all do
        get '/', {}, {
          'HTTP_X_GUGGENHEIM_API_KEY' => goodkey
        }
        @rsp = last_response
        @json = JSON.parse(last_response.body)
      end

      it "should return a 406" do
        @rsp.status.should eq 406
      end

      it "should return JSON error with the correct code" do
        @json["error"]["code"].should eq 406
      end
    end

    context "with wrong Accept header" do
      before :all do
        get '/', {}, {
          'HTTP_X_GUGGENHEIM_API_KEY' => goodkey,
          'ACCEPT' => 'txt/html'
        }
        @rsp = last_response
        @json = JSON.parse(last_response.body)
      end

      it "should return a 406" do
        @rsp.status.should eq 406
      end

      it "should return JSON error with the correct code" do
        @json["error"]["code"].should eq 406
      end
    end

    context "with non-existing ids" do
      context "with acquisitions" do
        before :all do
          get '/acquisitions/9876543210', {}, {
            'HTTP_X_GUGGENHEIM_API_KEY' => goodkey,
            'Accept' => 'application/vnd.guggenheim.collection+json'
          }
          @rsp = last_response
          @json = JSON.parse(last_response.body)
        end

        it "should return a 404" do
          @rsp.status.should eq 404
        end

        it "should return JSON error with the correct code" do
          @json["error"]["code"].should eq 404
        end
      end

      context "with constituents" do
        before :all do
          get '/constituents/9876543210', {}, {
            'HTTP_X_GUGGENHEIM_API_KEY' => goodkey,
            'Accept' => 'application/vnd.guggenheim.collection+json'
          }
          @rsp = last_response
          @json = JSON.parse(last_response.body)
        end

        it "should return a 404" do
          @rsp.status.should eq 404
        end

        it "should return JSON error with the correct code" do
          @json["error"]["code"].should eq 404
        end
      end

      context "with exhibitions" do
        before :all do
          get '/exhibitions/9876543210', {}, {
            'HTTP_X_GUGGENHEIM_API_KEY' => goodkey,
            'Accept' => 'application/vnd.guggenheim.collection+json'
          }
          @rsp = last_response
          @json = JSON.parse(last_response.body)
        end

        it "should return a 404" do
          @rsp.status.should eq 404
        end

        it "should return JSON error with the correct code" do
          @json["error"]["code"].should eq 404
        end
      end

      context "with movements" do
        before :all do
          get '/movements/9876543210', {}, {
            'HTTP_X_GUGGENHEIM_API_KEY' => goodkey,
            'Accept' => 'application/vnd.guggenheim.collection+json'
          }
          @rsp = last_response
          @json = JSON.parse(last_response.body)
        end

        it "should return a 404" do
          @rsp.status.should eq 404
        end

        it "should return JSON error with the correct code" do
          @json["error"]["code"].should eq 404
        end
      end

      context "with objects" do
        before :all do
          get '/objects/9876543210', {}, {
            'HTTP_X_GUGGENHEIM_API_KEY' => goodkey,
            'Accept' => 'application/vnd.guggenheim.collection+json'
          }
          @rsp = last_response
          @json = JSON.parse(last_response.body)
        end

        it "should return a 404" do
          @rsp.status.should eq 404
        end

        it "should return JSON error with the correct code" do
          @json["error"]["code"].should eq 404
        end
      end

      context "with sites" do
        before :all do
          get '/sites/9876543210', {}, {
            'HTTP_X_GUGGENHEIM_API_KEY' => goodkey,
            'Accept' => 'application/vnd.guggenheim.collection+json'
          }
          @rsp = last_response
          @json = JSON.parse(last_response.body)
        end

        it "should return a 404" do
          @rsp.status.should eq 404
        end

        it "should return JSON error with the correct code" do
          @json["error"]["code"].should eq 404
        end
      end
    end

  end
end