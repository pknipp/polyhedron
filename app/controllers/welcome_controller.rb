class WelcomeController < ApplicationController

  # GET /
  def index

  end

  # GET /:shape
  def show
    shape = URI.decode(params[:shape])
    puts shape
    @shape = shape
    render 'show'
  end

end
