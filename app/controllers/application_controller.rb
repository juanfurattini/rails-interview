class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from ActionController::UnknownFormat, with: :raise_not_found

  def raise_not_found
    raise ActionController::RoutingError.new('Not supported format')
  end
end
