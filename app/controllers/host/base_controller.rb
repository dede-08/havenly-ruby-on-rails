module Host
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_host!

    private

    def require_host!
      unless current_user.host?
        redirect_to root_path, alert: "No tienes permisos de host."
      end
    end
  end
end