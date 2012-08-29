require "rubygems"
require "sequel"
require "yaml"
require "json"

cfg = YAML.load_file('collection_server_spec.yml')
db = cfg['db']['mysql']
@DB = Sequel.mysql(db['db'], :user=>db['user'], :password=>db['password'], 
  :host=>db['host'], :charset=>'utf8')
goodkey = cfg['keys']['good']

require 'gugg-web_api-collection-server'

require 'rack/test'

# set :environment, :test

def make_request(uri, key)
  get uri, {}, {
    'HTTP_X_GUGGENHEIM_API_KEY' => key,
    'Accept' => 'application/vnd.guggenheim.collection+json'
  }
  JSON.parse(last_response.body)
end

describe 'API Server' do
  include Rack::Test::Methods

  def app
    Gugg::WebApi::Collection::Server::App
  end

  describe "/" do
    before :all do
      @data = make_request('/', goodkey)
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

  describe "/acquisitions" do
    context "with defaults" do
      before :all do
        @data = make_request('/acquisitions', goodkey)
      end

      it "should have acquisitions and _links" do
        @data["acquisitions"].should be_an_instance_of Array
        @data["_links"].should be_an_instance_of Hash
      end

      it "should link to itself" do
        @data["_links"]["_self"]["href"].
          should eq "http://example.org/acquisitions"
      end

      it "should have a few acquisitions" do
        @data["acquisitions"].count.should be >= 10
      end

      it "should have 5 objects in each acquisition" do
        @data["acquisitions"].each do |a|
          a["objects"]["items"].should have_at_least(1).items
          a["objects"]["items"].should have_at_most(5).items
        end
      end

      it "should have acquisitions that link to themselves" do
        @data["acquisitions"].each do |a|
          a["_links"]["_self"]["href"].
            should start_with "http://example.org/acquisitions/"
        end
      end
    end

    context "with options" do
      context "for items per page" do
        before :all do
          @data = make_request('/acquisitions?per_page=10', goodkey)
        end

        it "should have acquisitions at least on acquisition with 10 items" do
          o = @data["acquisitions"].map{|a| a["objects"]["items"].count}
          o.max.should eq 10
        end
      end 

      context "with no_objects" do
        before :all do
          @data = make_request('/acquisitions?no_objects=1', goodkey)
        end

        it "should have acquisitions with no objects" do
          @data["acquisitions"].each do |a|
            a["objects"]["items"].should be_nil
          end
        end

        it "should have acquisitions with object counts" do
          @data["acquisitions"].each do |a|
            a["objects"]["total_count"].should >= 1
          end
        end
      end
    end
  end

  describe '/acquisitions/{id}' do
    before :all do
      @acq_id = 6 # Solomon R. Guggenheim Founding Collection
    end

    context "with defaults" do
      before :all do
        @data = make_request("/acquisitions/#{@acq_id}", goodkey)
      end

      it "should have the right id" do
        @data["id"].should eq @acq_id
      end

      it "should have the right name" do
        @data["name"].should eq 'Solomon R. Guggenheim Founding Collection'
      end

      describe "_links object" do
        before :all do
          @links = @data["_links"]
        end

        it "should link to itself" do
          @links["_self"]["href"].should eq "http://example.org/acquisitions/6"
        end

        it "should link to the next page of results" do
          @links["next"]["href"].
            should start_with "http://example.org/acquisitions/6"
          @links["next"]["href"].should include("page=2", "per_page=20")
        end
      end

      describe "paginated objects" do
        before :all do
          @obj = @data["objects"]
        end

        it "should contain a list of 20 objects" do
          @obj["items"].should have(20).items
        end

        it "should have as many items as it says it does" do
          @obj["count"].should eq @obj["items"].count
        end

        it "should have as many items as it says it will" do
          @obj["items_per_page"].should eq @obj["items"].count
        end

        it "should be on the first page" do
          @obj["page"].should eq 1
        end

        it "should have at least 55 total items" do
          @obj["total_count"].should be >= 55
        end

        it "should have at least 3 total pages" do
          @obj["pages"].should be >= 3
        end
      end
    end

    context "with options" do
      context "for page" do
        before :all do
          @data = make_request("/acquisitions/#{@acq_id}?page=2", goodkey)
        end

        describe "_links object" do
          before :all do
            @links = @data["_links"]
          end

          it "should link to itself" do
            @links["_self"]["href"].
              should eq "http://example.org/acquisitions/6"
          end

          it "should not include the page in its link to itself" do
            @links["_self"]["href"].should_not include("page")
          end

          it "should link to the next page of results" do
            @links["next"]["href"].
              should start_with "http://example.org/acquisitions/6"
            @links["next"]["href"].should include("page=3", "per_page=20")
          end

          it "should link to the previous page of results" do
            @links["prev"]["href"].
              should start_with "http://example.org/acquisitions/6"
            @links["prev"]["href"].should include("page=1", "per_page=20")
          end
        end
      end

      context "for items per page" do
        before :all do
          @data = make_request("/acquisitions/#{@acq_id}?per_page=40", goodkey)
        end

        describe "_links object" do
          before :all do
            @links = @data["_links"]
          end

          it "should link to itself" do
            @links["_self"]["href"].
              should eq "http://example.org/acquisitions/6"
          end

          it "should not include the page in its link to itself" do
            @links["_self"]["href"].should_not include("page")
          end

          it "should link to the next page of results" do
            @links["next"]["href"].
              should start_with "http://example.org/acquisitions/6"
            @links["next"]["href"].should include("page=2", "per_page=40")
          end
        end

        describe "paginated objects" do
          before :all do
            @obj = @data["objects"]
          end

          it "should contain a list of 40 objects" do
            @obj["items"].should have(40).items
          end

          it "should have as many items as it says it does" do
            @obj["count"].should eq @obj["items"].count
          end

          it "should have as many items as it says it will" do
            @obj["items_per_page"].should eq @obj["items"].count
          end

          it "should be on the first page" do
            @obj["page"].should eq 1
          end

          it "should have at least 55 total items" do
            @obj["total_count"].should be >= 55
          end

          it "should have at least 2 total pages" do
            @obj["pages"].should be >= 2
          end
        end
      end

      context "with no_objects" do
        before :all do
          @data = make_request("/acquisitions/#{@acq_id}?no_objects=1", goodkey)
        end

        describe "_links object" do
          before :all do
            @links = @data["_links"]
          end

          it "should link to itself" do
            @links["_self"]["href"].
              should eq "http://example.org/acquisitions/6"
          end

          it "should not link to its next page" do
            @links["next"].should be_nil
          end
        end

        describe "paginated objects" do
          before :all do
            @obj = @data["objects"]
          end

          it "should have a total count" do
            @obj["total_count"].should be >= 55
          end

          it "should not have any objects" do
            @obj["items"].should be_nil
          end
        end
      end
    end
  end

  describe '/objects' do
    describe '/objects/{id}' do
      before :all do
        @pwb = make_request('/objects/1867', goodkey)
      end

      it "should retrieve one object" do  
        @pwb.should be_an_instance_of Hash
      end

      it "should have a list of Movements" do
        @pwb['movements'].should be_an_instance_of Array
      end

      it "should have one Movement" do
        @pwb['movements'].count.should eq 1
      end

      it "should belong to Expressionism" do
        @pwb['movements'][0]['name'].should eq 'Expressionism'
      end
    end
  end
end
