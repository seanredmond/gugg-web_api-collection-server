module Gugg
  module WebApi
    module Collection
      module Server 
        module Exceptions
          class ApiError < StandardError
          end

          class UnauthorizedError < ApiError
          end

          class NotAcceptableError < ApiError
          end
        end
      end
    end
  end
end
