class WelcomeController < ApplicationController

  # GET /
  def index

  end

  # GET /:shape
  def show
    shape = params[:shape]
    puts shape
    first_char = shape[0]
    shape = shape[1..-1]
    puts shape
    second_char = shape[0]
    shape = shape[1..-1]
    puts shape
    last_char = shape[-1]
    shape = shape[0..-2]
    puts shape
    second_to_last_char = shape[-1]
    shape = shape[0..-2]
    puts shape
    shape_arr = shape.split("),(")
    puts shape_arr
    @triangle = shape_arr[0]
    @tetrahedron = shape_arr[1]
    render 'show'
  end

end
