class WelcomeController < ApplicationController

  # GET /
  def index

  end

  # GET /:id
  def show
    shape = params[:shape]
    puts shape
    @shape = shape
    render 'show'
  end

end
