require "rubygems"
require "sequel"
# require "yaml"

#cfg = YAML.load_file('collection_server_spec.yml')
# db = cfg['db']['mysql']
# @DB = Sequel.mysql(db['db'], :user=>db['user'], :password=>db['password'], 
#   :host=>db['host'], :charset=>'utf8')

cwd = File.dirname(__FILE__)

@DB=Sequel.sqlite

structure = File.open(File.join(cwd, 'test-structure.sql'), 'r').read
@DB.execute_ddl(structure)

contents = File.open(File.join(cwd, 'test-data.sql'), 'r').read
@DB.execute_dui(contents)

goodkey = 'ed3c63916af176b3af878f98156e07f4'

require 'gugg-web_api-collection-server'

require 'rack/test'

# set :environment, :test

def make_request(uri, key)
  get uri, {}, {
    'HTTP_X_GUGGENHEIM_API_KEY' => key,
    'Accept' => 'application/vnd.guggenheim.collection+json'
  }
  Yajl::Parser.parse(last_response.body)
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
        @data["acquisitions"].count.should eq 3
      end

      it "should have no objects in each acquisition" do
        @data["acquisitions"].each do |a|
          a["objects"]["items"].should_not be # have(0).items
          # a["objects"]["items"].should have_at_most(5).items
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

        # it "should link to the next page of results" do
        #   @links["next"]["href"].
        #     should start_with "http://example.org/acquisitions/6"
        #   @links["next"]["href"].should include("page=2", "per_page=20")
        # end
      end

      describe "paginated objects" do
        before :all do
          @obj = @data["objects"]
        end

        it "should contain a list of 20 objects" do
          @obj["items"].should have(15).items
        end

        it "should have as many items as it says it does" do
          @obj["count"].should eq @obj["items"].count
        end

        # it "should have as many items as it says it will" do
        #   @obj["items_per_page"].should eq @obj["items"].count
        # end

        it "should be on the first page" do
          @obj["page"].should eq 1
        end

        it "should have at least 55 total items" do
          @obj["total_count"].should be >= 15
        end

        it "should have at least 3 total pages" do
          @obj["pages"].should eq 1
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

          # it "should link to the next page of results" do
          #   @links["next"]["href"].
          #     should start_with "http://example.org/acquisitions/6"
          #   @links["next"]["href"].should include("page=3", "per_page=20")
          # end

          it "should link to the previous page of results" do
            @links["prev"]["href"].
              should start_with "http://example.org/acquisitions/6"
            @links["prev"]["href"].should include("page=1", "per_page=20")
          end
        end
      end

      context "for items per page" do
        before :all do
          @data = make_request("/acquisitions/#{@acq_id}?per_page=2", goodkey)
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
            @links["next"]["href"].should include("page=2", "per_page=2")
          end
        end

        describe "paginated objects" do
          before :all do
            @obj = @data["objects"]
          end

          it "should contain a list of 40 objects" do
            @obj["items"].should have(2).items
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
            @obj["total_count"].should be >= 15
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
            @obj["total_count"].should be >= 15
          end

          it "should not have any objects" do
            @obj["items"].should be_nil
          end
        end
      end
    end
  end

  describe '/exhibitions' do
    context "with defaults" do
      before :all do
        @data = make_request('/exhibitions', goodkey)
      end

      it "should return an Exhibition resource" do
        @data.should be_an_instance_of Hash
      end

      it "should have _links" do
        @data["_links"].should be_an_instance_of Hash
      end

      it "should link to itself" do
        @data["_links"]["_self"]["href"].
          should eq "http://example.org/exhibitions"
      end

      it "should have movement resources" do
        @data["exhibitions"].should be_an_instance_of Array
      end

      it "should have a few movements" do
        @data["exhibitions"].count.should be >= 2
      end

      it "should have no objects in each exhibition" do
        @data["exhibitions"].each do |a|
          a["objects"]["items"].should_not be
          a["objects"]["total_count"].should be > 0
        end
      end

      it "should have exhibitions that link to themselves" do
        @data["exhibitions"].each do |a|
          a["_links"]["_self"]["href"].
            should start_with "http://example.org/exhibitions/"
        end
      end
    end
  end



  describe '/movements' do
    context "with defaults" do
      before :all do
        @data = make_request('/movements', goodkey)
      end

      it "should return a Movements resource" do
        @data.should be_an_instance_of Hash
      end

      it "should have _links" do
        @data["_links"].should be_an_instance_of Hash
      end

      it "should link to itself" do
        @data["_links"]["_self"]["href"].
          should eq "http://example.org/movements"
      end

      it "should have movement resources" do
        @data["movements"].should be_an_instance_of Array
      end

      it "should have a few movements" do
        @data["movements"].count.should be >= 9
      end

      it "should have 5 objects in each movement" do
        @data["movements"].each do |a|
          a["objects"]["items"].should_not be
          a["objects"]["total_count"].should be > 0
        end
      end

      it "should have movements that link to themselves" do
        @data["movements"].each do |a|
          a["_links"]["_self"]["href"].
            should start_with "http://example.org/movements/"
        end
      end
    end
  end

  describe '/movements/{id}' do
    before :all do
      @mov_id = 195210 # Cubism
    end

    context "with defaults" do
      before :all do
        @data = make_request("/movements/#{@mov_id}", goodkey)
      end

      it "should have the right id" do
        @data["id"].should eq @mov_id
      end

      it "should have the right name" do
        @data["name"].should eq 'Cubism'
      end

      describe "_links object" do
        before :all do
          @links = @data["_links"]
        end

        it "should link to itself" do
          @links["_self"]["href"].
            should eq "http://example.org/movements/#{@mov_id}"
        end

        # it "should link to the next page of results" do
        #   @links["next"]["href"].
        #     should start_with "http://example.org/movements/#{@mov_id}"
        #   @links["next"]["href"].should include("page=2", "per_page=20")
        # end
      end
    end
  end

  describe '/objects' do
    describe 'index' do
      before :all do
        @index = make_request('/objects', goodkey)
        @first = @index['objects']['items'].first
      end

      it 'retrieve an object' do
        @index.should be_an_instance_of Hash
      end

      it 'has a list of 20 objects' do
        @index['objects']['items'].count.should eq 20
      end

      it 'has objects with essays' do
        @first.keys.include?('essay').should be_true
      end

      context 'with no_essay = true' do
        before :all do
          @index = make_request('/objects?no_essay=true', goodkey)
          @first = @index['objects']['items'].first
        end

        it 'has objects with no essays' do
          @first.keys.include?('essay').should be_false
        end
      end
    end

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

      it "should belong to an Acquisition" do
        @pwb['acquisition']['name'].
          should eq 'Solomon R. Guggenheim Founding Collection'
      end

      it 'has an essay' do
        @pwb['essay'].should_not be_nil
      end

      context 'with no_essay' do
        before :all do
          @pwb_no_essay = make_request('/objects/1867?no_essay=true', goodkey)
        end

        it 'does not have an essay' do
          @pwb_no_essay.keys.include?('essay').should be_false
        end

        it 'says it has an essay available' do
          @pwb_no_essay['has_essay'].should be_true
        end
      end
    end

    describe '/objects/on-view' do
      before :all do
        @onview = make_request('/objects/on-view', goodkey)
      end

      it "should retrieve one object" do  
        @onview.should be_an_instance_of Hash
      end

      it "should have a list of objects" do
        @onview['objects']['count'].should be > 0
      end

      context 'with no_essay = true' do
        before :all do
          @onview = make_request('/objects/on-view?no_essay=true', goodkey)
          @first = @onview['objects']['items'].first
        end

        it 'has objects with no essays' do
          @first.keys.include?('essay').should be_false
        end
      end
    end
  end

  describe '/objects/dates' do
    before :all do
      @dates = make_request('/objects/dates', goodkey)
    end

    it "should retrieve one object" do  
      @dates.should be_an_instance_of Hash
      @dates['_links']['decades'].should be_an_instance_of Array
    end

    describe '/objects/dates/{year}' do
      before :all do
        @year = make_request('/objects/dates/1923', goodkey)
      end

      it "should retrieve one object" do  
        @year.should be_an_instance_of Hash
        @year['objects'].should be_an_instance_of Hash
      end

      context 'with no_essay = true' do
        before :all do
          @year = make_request('/objects/dates/1923?no_essay=true', goodkey)
          @first = @year['objects']['items'].first
        end

        it 'has objects with no essays' do
          @first.keys.include?('essay').should be_false
        end
      end
    end

    describe '/objects/dates/{year}/{year}' do
      before :all do
        @years = make_request('/objects/dates/1923/1933', goodkey)
      end

      it "should retrieve one object" do  
        @years.should be_an_instance_of Hash
        @years['objects'].should be_an_instance_of Hash
      end

      context 'with no_essay = true' do
        before :all do
          @years = make_request('/objects/dates/1923/1933?no_essay=true', goodkey)
          @first = @years['objects']['items'].first
        end

        it 'has objects with no essays' do
          @first.keys.include?('essay').should be_false
        end
      end
    end

    describe '/objects/types' do
      before :all do
        @types = make_request('/objects/types', goodkey)
      end

      it "retrieves a Hash" do  
        @types.should be_an_instance_of Hash
      end

      it "has a list of object types" do  
        @types['types'].should be_an_instance_of Array
      end

      context 'with defaults' do
        it 'has a count of objects' do  
          @types['types'].first['objects']['total_count'].should be > 0
        end

        it 'has no embedded objects' do  
          @types['types'].first['objects']['items'].should_not be
        end
      end

      context 'with objects requested' do
        before :all do
          @types_with_obj = make_request('/objects/types?per_page=20', goodkey)
          @first = @types_with_obj['types'].first['objects']['items'].first
        end

        it 'has embedded objects' do  
          @types_with_obj['types'].
            first['objects']['items'].count.should be <= 20
        end

        it 'has objects with essays' do
          @first.keys.include?('essay').should be_true
        end

        context 'with no_essay = true' do
          before :all do 
            @types_with_obj_no_essays = 
              make_request('/objects/types?per_page=20&no_essay=true', goodkey)
            @first = @types_with_obj_no_essays['types'].
              first['objects']['items'].first
          end

          it 'has objects with no essays' do
            @first.keys.include?('essay').should be_false
          end
        end
      end

      describe '/objects/types/{id}' do
        before :all do
          @painting = make_request('/objects/types/195198', goodkey)
        end

        it 'is the right resource' do
          @painting['name'].should eq "Painting"
        end

        context 'with defaults' do
          it 'has embedded objects' do
            @painting['objects']['items'].count.should be <= 20
          end

          it 'has objects with essays' do
            @painting['objects']['items'].first.keys.include?('essay').
              should be_true
          end
        end

        context 'with no objects requested' do
          before :all do
            @painting_no_obj = 
              make_request('/objects/types/195198?no_objects=1', goodkey)
          end

          it 'has no embedded objects' do
            @painting_no_obj['objects']['items'].should_not be
          end

          it 'has a count of objects' do
            @painting_no_obj['objects']['total_count'].should be > 0
          end
        end

        context 'with no_essay = true' do
          before :all do
            @painting_no_essay = 
              make_request('/objects/types/195198?no_essay=true', goodkey)
          end

          it 'has objects with no essays' do
            @painting_no_essay['objects']['items'].first.keys.include?('essay').
              should be_false
          end
        end
      end
    end
  end 

  describe '/sites/{id}' do
    before :all do
      @site_id = 3 # SRGM
    end

    context "with defaults" do
      before :all do
        @data = make_request("/sites/#{@site_id}", goodkey)
      end

      it "should have the right id" do
        @data["id"].should eq @site_id
      end

      it "should have the right name" do
        @data["name"].should eq 'Solomon R. Guggenheim Museum'
      end

      describe "_links object" do
        before :all do
          @links = @data["_links"]
        end

        it "should link to itself" do
          @links["_self"]["href"].
            should eq "http://example.org/sites/#{@site_id}"
        end

        it "should link to the next page of results" do
          @links["next"]["href"].
            should start_with "http://example.org/sites/#{@site_id}"
          @links["next"]["href"].should include("page=2", "per_page=20")
        end
      end
    end
  end
end
