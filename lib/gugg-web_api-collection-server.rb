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

            # remove trailing slash
            @root.sub!(/\/$/, '');

            if request.env['SCRIPT_NAME'] != ""
              @root = @root + '/' + request.env['SCRIPT_NAME']
            end
            Gugg::WebApi::Collection::Linkable::root = @root

            Gugg::WebApi::Collection::Linkable::map_path(
              Gugg::WebApi::Collection::Db::Acquisition, 'acquisitions'
            )
            Gugg::WebApi::Collection::Linkable::map_path(
              Gugg::WebApi::Collection::Db::Exhibition, 'exhibitions'
            )
            Gugg::WebApi::Collection::Linkable::map_path(
              Gugg::WebApi::Collection::Db::Movement, 'movements'
            )
            Gugg::WebApi::Collection::Linkable::map_path(
              Gugg::WebApi::Collection::Db::CollectionObject, 'objects'
            )
            Gugg::WebApi::Collection::Linkable::map_path(
              Gugg::WebApi::Collection::Db::Constituent, 'constituents'
            )
            Gugg::WebApi::Collection::Linkable::map_path(
              Gugg::WebApi::Collection::Db::Site, 'sites'
            )

            Gugg::WebApi::Collection::Db::Media::media_root = 
              "http://emuseum2.guggenheim.org/media"
            Gugg::WebApi::Collection::Db::Media::media_paths = {
              :full => 'full',
              :large => 'large',
              :medium => 'previews',
              :small => 'thumbnails',
              :tiny => 'postagestamps'
            }
            Gugg::WebApi::Collection::Db::Media::media_dimensions = {
              :large => 490,
              :medium => 300,
              :small => 160,
              :tiny => 62
            }


          end

          get '/' do
            response = {
              '_links' => {
                'acquisitions' => {'href' => "#{@root}/acquisitions"},
                'constituents' => {'href' => "#{@root}/constituents"},
                'exhibitions'  => {'href' => "#{@root}/exhibitions"},
                'locations'    => {'href' => "#{@root}/locations"},
                'movements'    => {'href' => "#{@root}/movements"},
                'objects'      => {'href' => "#{@root}/objects"},
                'sites'        => {'href' => "#{@root}/sites"}
              }
            }

            jsonp response
          end

          #-------------------------------------------------------------
          # Acquisitions
          #-------------------------------------------------------------
          get '/acquisitions' do
            allowable = ['per_page']
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
            acq = Db::Acquisition[id]
            if acq == nil
              raise Exceptions::NoSuchID, "No available acquisition with ID #{id}"
            end
            allowable = ['page', 'per_page', 'no_objects']
            pass_params = params.reject{|k, v| !allowable.include?(k)}
            jsonp acq.as_resource(pass_params)
          end

          #-------------------------------------------------------------
          # Constituents
          #-------------------------------------------------------------
          get '/constituents' do
            response = {
              :_links => {
                :_self => {
                  :href => "#{@root}/constituents"
                },
                :item => {
                  :href => "#{@root}/constituents/{id}"
                },
                :alpha => {
                  :href => "#{@root}/constituents/{a-z}"
                }
              }
            }

            jsonp response
          end

          get %r{/constituents/(\d+)} do
            id = params[:captures].first
            allowable = ['page', 'per_page', 'no_objects']
            pass_params = params.reject{|k, v| !allowable.include?(k)}
            jsonp Db::Constituent[id].as_resource(pass_params)
          end

          get %r{/constituents/([a-zA-Z])} do
            init = params[:captures].first
            jsonp Db::Constituent.list({'initial' => init})
          end

          #-------------------------------------------------------------
          # Exhibitions
          #-------------------------------------------------------------
          get '/exhibitions' do
            allowable = ['per_page', 'no_objects']
            pass_params = params.reject{|k, v| !allowable.include?(k)}
            jsonp Db::Exhibition.list(pass_params).merge({
              :_links => {
                :_self => {
                  :href => "#{@root}/exhibitions"
                },
                :item => {
                  :href=> "#{@root}/exhibitions/{id}"
                }
              }
            })
          end

          get %r{/exhibitions/(\d+)} do
            id = params[:captures].first
            allowable = ['page', 'per_page', 'no_objects']
            pass_params = params.reject{|k, v| !allowable.include?(k)}
            jsonp Db::Exhibition[id].as_resource(pass_params)
          end

          #-------------------------------------------------------------
          # Movements
          #-------------------------------------------------------------
          get '/movements' do
            allowable = ['per_page', 'no_objects']
            pass_params = params.reject{|k, v| !allowable.include?(k)}
            jsonp Db::Movement.list(pass_params).merge({
              :_links => {
                :_self => {
                  :href => "#{@root}/movements"
                },
                :item => {
                  :href=> "#{@root}/movements/{id}"
                }
              }
            })
          end

          get %r{/movements/(\d+)} do
            id = params[:captures].first
            allowable = ['page', 'per_page', 'no_objects']
            pass_params = params.reject{|k, v| !allowable.include?(k)}
            jsonp Db::Movement[id].as_resource(pass_params)
          end

          #-------------------------------------------------------------
          # Objects
          #-------------------------------------------------------------
          get '/objects' do
            allowable = ['per_page', 'page', 'no_objects']
            pass_params = params.reject{|k, v| !allowable.include?(k)}
            response = Db::CollectionObject::list(pass_params)

            response[:_links].merge!({
                'item'    => {'href' => "#{@root}/objects/{id}"},
                'on view' => {'href' => "#{@root}/objects/on-view"},
                'by date' => {'href' => "#{@root}/objects/dates"}
            })

            jsonp response
          end

          get %r{/objects/(\d+)} do
            id = params[:captures].first
            obj = Db::CollectionObject[id]
            if obj == nil
              raise Exceptions::NoSuchID, "No available object with ID #{id}"
            end
            jsonp obj.as_resource
          end

          get '/objects/on-view' do
            jsonp Db::CollectionObject::on_view({:add_to_path => 'on-view'})
          end

          get '/objects/dates' do
            jsonp Db::CollectionObject::decades({:add_to_path => 'dates'})
          end

          get %r{/objects/dates/(\d+)$} do
            year = params[:captures].first
            allowable = ['page', 'per_page', 'no_objects']
            pass_params = params.reject{|k, v| !allowable.include?(k)}
            jsonp Db::CollectionObject::by_year(
              year, {:add_to_path => 'dates'}.merge!(pass_params))
          end

          get %r{/objects/dates/(\d+)/(\d+)} do
            start_year = params[:captures][0]
            end_year = params[:captures][1]
            allowable = ['page', 'per_page', 'no_objects']
            pass_params = params.reject{|k, v| !allowable.include?(k)}
            jsonp Db::CollectionObject::by_year_range(
              start_year, end_year, {:add_to_path => 'dates'}.merge!(pass_params))
          end

          #-------------------------------------------------------------
          # Sites
          #-------------------------------------------------------------
          get '/sites' do
            allowable = ['per_page', 'no_objects']
            pass_params = params.reject{|k, v| !allowable.include?(k)}
            jsonp Db::Site.list(pass_params).merge({
              :_links => {
                :_self => {
                  :href => "#{@root}/sites"
                },
                :item => {
                  :href=> "#{@root}/sites/{id}"
                }
              }
            })
          end

          get %r{/sites/(\d+)} do
            id = params[:captures].first
            allowable = ['page', 'per_page', 'no_objects']
            pass_params = params.reject{|k, v| !allowable.include?(k)}
            jsonp Db::Site[id].as_resource(pass_params)
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

          error Exceptions::NoSuchID do
            err = {
              :error => {
                :code => 404,
                :message =>  env['sinatra.error'].message             
              }
            }
            status 404
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
                :code => 500, # env['sinatra.error'].code,
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
