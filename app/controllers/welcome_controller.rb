class WelcomeController < ApplicationController

  # GET /
  def index

  end

  # GET /:shape
  def show
    shape_uri = URI.parse(params[:shape])
    shape = shape_uri.decode_www_form_component
    puts shape
    @shape = shape
    render 'show'
  end

end
