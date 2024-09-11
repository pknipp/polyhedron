class WelcomeController < ApplicationController

  # GET /
  def index

  end

  class Vertex
    attr_accessor :name, :coords
    def initialize(name, coords)
      @name = name
      @coords = coords
    end
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
    vertex_names = triangle.first(3)
    edge_lengths = triangle.last(3)
    vertices = [Vertex.new(vertex_names[0], [0, 0, 0])]
    a = edge_lengths[0].to_f
    vertices.push(Vertex.new(vertex_names[1], [a, 0, 0]))
    b = edge_lengths[1].to_f
    c = edge_lengths[2].to_f
    ax = (a * a + c * c - b * b) / 2 / a
    ay = Math.sqrt(c * c - ax * ax)
    vertices.push(Vertex.new(vertex_names[2], [ax, ay, 0]))
    mins = Array.new(3, Float::INFINITY)
    maxs = Array.new(3, -Float::INFINITY)
    vertices.each{|vertex|
      (0..2).each{|i|
        mins[i] = [mins[i], vertex.coords[i]].min
        maxs[i] = [maxs[i], vertex.coords[i]].max
      }
    }
    origin = []
    size = 0
    (0..2).each{|i|
      origin.push((maxs[i] + mins[i]) / 2)
      size = [size, maxs[i] - mins[i]].max
    }
    puts origin
    puts size
    ratio = 0.8
    vertices.each{|vertex|
      (0..2).each{|i|
        vertex.coords[i] = ratio * (vertex.coords[i] - origin[i]) * svg_size / size
      }
    }
    puts vertices
    @vertices = vertices
    render 'show'
  end

end
