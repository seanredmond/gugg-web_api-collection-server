module Gugg
  module WebApi
    module Collection
      module Server 
        module Exceptions
          class ApiException < Exception
          end

          class UnauthorizedError < ApiException
          end

          class NotAcceptableError < ApiException
          end
        end
      end
    end
  end
end
