require "sinatra"
require "sinatra/jsonp"
require "sequel"
require "gugg-web_api-collection-server/version"
require "gugg-web_api-collection-db"

module Gugg
  module WebApi
    module Collection
      module Server 
        class App < Sinatra::Base
          helpers Sinatra::Jsonp

          before do
            content_type 'application/vnd.guggenheim.collection+json'
          end

          get '/' do
            response = {
              '_links' => {
                'acquisitions' => {'href' => '/acquisitions'},
                'constituents' => {'href' => '/constituents'},
                'exhibitions' => {'href' => '/exhibitions'},
                'locations' => {'href' => '/locations'},
                'movements' => {'href' => '/movements'},
                'objects' => {'href' => '/objects'},
                'sites' => {'href' => '/sites'}
              }
            }

            jsonp response
          end

          get %r{/objects/(\d+)} do
            jsonp Db::CollectionObject[params[:captures].first].as_resource
          end
        end
      end
    end
  end
end
