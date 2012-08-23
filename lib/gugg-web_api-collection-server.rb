require "sinatra"
require "sinatra/jsonp"
require "sequel"
require "gugg-web_api-collection-server/version"
require "gugg-web_api-collection-db"
require "gugg-web_api-access"
require "gugg-web_api-collection-server/exceptions"

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

            # Check authentication
            key = request.env['HTTP_X_GUGGENHEIM_API_KEY'] || params['key']
            @access = Gugg::WebApi::Access::get(key)
            if @access == nil
              raise Exceptions::UnauthorizedError, "Unauthorized"
            end

            # Check that client accepts content type
            if !acceptsCorrectContentType?(request.env['HTTP_ACCEPT'] || request.env['Accept'])
              raise Exceptions::NotAcceptableError, "Not Acceptable"
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

          #-------------------------------------------------------------
          # Errors
          #-------------------------------------------------------------

          error Gugg::WebApi::Collection::Db::BadParameterError do
            err = {
              :error => {
                :code => 400,
                :message =>  'Bad Request: ' + env['sinatra.error'].message             
              }
            }
            status 400
            body jsonp err
          end

          error Exceptions::UnauthorizedError do
            err = {
              :error => {
                :code => 401,
                :message =>  env['sinatra.error'].message             
              }
            }
            status 401
            headers "WWW-Authenticate" => "Basic realm=\"API\""
            body jsonp err
          end

          error Exceptions::NotAcceptableError do
            err = {
              :error => {
                :code => 406,
                :message =>  env['sinatra.error'].message             
              }
            }
            status 406
            body jsonp err
          end

          error 404 do
            err = {
              :error => {
                :code => 404,
                :message =>  'Not Found'             
              }
            }
            jsonp err
          end

          error do
            status 500
            err = {
              :error => {
                :code => env['sinatra.error'].code,
                :message => env['sinatra.error'].message
              }
            }
            jsonp err
          end

          def acceptsCorrectContentType?(accept)
            return accept != nil && accept.split(/\s*,\s*/).include?(
              'application/vnd.guggenheim.collection+json'
            )
          end
        end
      end
    end
  end
end
