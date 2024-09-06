class WelcomeController < ApplicationController

  # GET /
  def index

  end

  # GET /:shape
  def show
    @size = 900
    shape = params[:shape]
    first_char = shape[0]
    shape = shape[1..-1]
    second_char = shape[0]
    shape = shape[1..-1]
    last_char = shape[-1]
    shape = shape[0..-2]
    second_to_last_char = shape[-1]
    shape = shape[0..-2]
    shape_arr = shape.split("),(")
    triangle = shape_arr[0].split(",")
    @triangle_names = triangle.first(3)
    # @tetrahedron = shape_arr[1]
    render 'show'
  end

end
