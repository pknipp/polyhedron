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

  class Edge
    attr_accessor :ends
    def initialize(ends)
      @ends = ends
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
    b = Vertex.new(vertex_names[0], [0, 0, 0])
    vertices = [b]
    edges = []
    a_len = edge_lengths[0].to_f
    c = Vertex.new(vertex_names[1], [A, 0, 0])
    vertices.push(c)
    edges.push(Edge.new([b, c]))
    b_len = edge_lengths[1].to_f
    c_len = edge_lengths[2].to_f
    ax = (a_len * a_len + c_len * c_len - b_len * b_len) / 2 / a_len
    ay = Math.sqrt(c_len * c_len - ax * ax)
    a = Vertex.new(vertex_names[2], [ax, ay, 0])
    vertices.push(a)
    edges.push(Edge.new([c, a]))
    edges.push(Edge.new([a, b]))
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
    ratio = 0.8
    (0..2).each{|i|
      vertices.each{|vertex|
        vertex.coords[i] = ratio * (vertex.coords[i] - origin[i]) * svg_size / size
      }
      edges.each{|edge|
        edge.each{|endpt|
          endpt.coords[i] = ratio * (endpt.coords[i] - origin[i]) * svg_size / size
        }
      }
    }
    @vertices = vertices
    @edges = edges
    render 'show'
  end

end
