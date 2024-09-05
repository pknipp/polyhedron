class WelcomeController < ApplicationController

  # GET /
  def index

  end

  # GET /:shape
  def show
    shape = params[:shape]
    first_char = shape.shift
    second_char = shape.shift
    last_char = shape.chop
    second_to_last_char = shape.chop
    shape_arr = shape.split("),(")
    @triangle = shape[0]
    @tetrahedron = shape[1]
    render 'show'
  end

end
