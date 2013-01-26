require "rubygems"
require "sequel"

require 'spec_helper'

require 'rack/test'

goodkey = 'ed3c63916af176b3af878f98156e07f4'

def make_request(uri, key)
  get uri, {}, {
    'HTTP_X_GUGGENHEIM_API_KEY' => key,
    'Accept' => 'application/vnd.guggenheim.collection+json'
  }
  Yajl::Parser.parse(last_response.body)
end

describe 'Regression Tests' do
  include Rack::Test::Methods

  def app
    Gugg::WebApi::Collection::Server::App
  end

  describe "X (loan) Record retrieved on the production server" do
    # After updating the database we weren't getting any of the new data. The
    # new records were all 'X' records or loans. Is that the problem or is it a
    # server issue?
    before :all do
      @data = make_request('/objects/30257', goodkey)
    end

    it "should return non-collection online record" do
      @data['id'].should eq 30257
    end

    it "should say it is not in the permanent collection" do
      @data['permanent_collection'].should be_false
    end
  end
end