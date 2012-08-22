require "sinatra"
require "sinatra/jsonp"
require "sequel"
require "gugg-web_api-collection-server/version"
require "gugg-web_api-collection-db"
require "gugg-web_api-access"

module Gugg
  module WebApi
    module Collection
      module Server 
        class App < Sinatra::Base
          helpers Sinatra::Jsonp
          set :raise_errors, false
          set :show_exceptions, false

          before do
            content_type 'application/vnd.guggenheim.collection+json'
            key = request.env['HTTP_X_GUGGENHEIM_API_KEY'] || params['key']
            @access = Gugg::WebApi::Access::get(key)
            if @access == nil
              raise "No access!"
            end

            @root = "#{request.scheme}://#{request.host}"
            if (request.scheme == 'http' && request.port != 80) ||
                (request.scheme == 'https' && request.port != 443)
              @root += ":#{request.port}"
            end

            if request.env['SCRIPT_NAME'] != ""
              @root = @root + '/' + request.env['SCRIPT_NAME']
            end
            Gugg::WebApi::Collection::Linkable::root = @root

            Gugg::WebApi::Collection::Linkable::map_path(
              Gugg::WebApi::Collection::Db::Acquisition, 'acquisitions'
            )
            Gugg::WebApi::Collection::Linkable::map_path(
              Gugg::WebApi::Collection::Db::CollectionObject, 'objects'
            )
            Gugg::WebApi::Collection::Linkable::map_path(
              Gugg::WebApi::Collection::Db::Constituent, 'constituents'
            )

          end

          get '/' do
            response = {
              '_links' => {
                'acquisitions' => {'href' => '#{@root}/acquisitions'},
                'constituents' => {'href' => '#{@root}/constituents'},
                'exhibitions' => {'href' => '#{@root}/exhibitions'},
                'locations' => {'href' => '#{@root}/locations'},
                'movements' => {'href' => '#{@root}/movements'},
                'objects' => {'href' => '#{@root}/objects'},
                'sites' => {'href' => '#{@root}/sites'}
              }
            }

            jsonp response
          end

          get '/acquisitions' do
            allowable = ['per_page', 'no_objects']
            pass_params = params.reject{|k, v| !allowable.include?(k)}
            jsonp Db::Acquisition.list(pass_params).merge({
              :_links => {
                :_self => {
                  :href => "#{@root}/acquisitions"
                },
                :item => {
                  :href=> "#{@root}/acquisitions/{id}"
                }
              }
            })
          end

          get %r{/acquisitions/(\d+)} do
            id = params[:captures].first
            allowable = ['page', 'per_page', 'no_objects']
            pass_params = params.reject{|k, v| !allowable.include?(k)}
            jsonp Db::Acquisition[id].as_resource(pass_params)
          end

          get %r{/objects/(\d+)} do
            jsonp Db::CollectionObject[params[:captures].first].as_resource
          end

          error do
            err = {
              :error => env['sinatra.error'].message
            }
            jsonp err
          end
        end
      end
    end
  end
end
