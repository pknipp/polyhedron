class WelcomeController < ApplicationController

  # GET /
  def index

  end

  # GET /:id
  def show
    id = params[:id]
    @id = id
    render 'show'
  end

end
