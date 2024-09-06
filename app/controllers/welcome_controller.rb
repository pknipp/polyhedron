class WelcomeController < ApplicationController

  # GET /
  def index

  end

  # GET /:shape
  def show
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
    svg_size = 900
    @size = svg_size
    @vertex_names = triangle.first(3)
    edge_lengths = triangle.last(3)
    vertices = [[0,0,0]]
    vertices.push([edge_lengths[0], 0, 0])
    mins = Array.new(3, Float::INFINITY)
    maxs = Array.new(3, -Float::INFINITY)
    vertices.each{|vertex|
      (0..3).each{|i|
        mins[i] = [mins[i], vertex[i]].min
        maxs[i] = [maxs[i], vertex[i]].max
      }
    }
    origin = []
    size = 0
    (0..3).each{|i|
      origin.push((maxs[i] + mins[i]) / 2)
      size = [size, maxs[i] - mins[i]].max
    }
    ratio = 0.8
    vertices.each{|vertex|
      (0..3).each{|i|
        vertex[i] = ratio * (vertex[i] - origin[i]) * svg_size / size
      }
    }
    @vertices = vertices
    render 'show'
  end

end
