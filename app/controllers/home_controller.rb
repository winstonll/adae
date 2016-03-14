class HomeController < ApplicationController
	respond_to :html, :json
	def signup_modal
	    respond_to do |format|
	      format.js
	    end
  	end
  	def signin_modal
    	respond_to do |format|
    	  format.js
    	end
    end
    def companion_modal
      respond_to do ||format
        format.js
      end
    end
end
