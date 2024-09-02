class WelcomeController < ApplicationController

  # GET /
  def index

  end

  # GET /:id
  def show
    shape = params[:shape]
    @shape = shape
    render 'show'
  end

end
