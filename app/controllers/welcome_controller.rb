class WelcomeController < ApplicationController

  # GET /
  def index

  end

  class Vertex
    attr_accessor :coords
    def initialize(coords)
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
    # parse the entire url
    shape = params[:shape]
    # TODO: remove any whitespace, and put something in instructions in re avoiding this
    first_char = shape[0]
    shape = shape[1..-1]
    second_char = shape[0]
    shape = shape[1..-1]
    last_char = shape[-1]
    shape = shape[0..-2]
    second_to_last_char = shape[-1]
    shape = shape[0..-2]
    shape_arr = shape.split("),(")

    # parse the first triangle
    triangle = shape_arr[0].split(",")
    svg_size = 900
    @size = svg_size
    vertex_names = triangle.first(3)
    edge_lengths = triangle.last(3)
    a = Vertex.new([0, 0, 0])
    [first_name, second_name] = vertex_names.first(2)
    vertices = {}
    edges = {}
    vertices[first_name] = a
    if vertices.has_key?[second_name]
      # return error if second_name is already in vertices hashmap
    else
      vertices[second_name] = Vertex.new([ab, 0, 0])
    end
    ab = edge_lengths[0].to_f
    if second_name < first_name
      swap = first_name
      second_name = first_name
      first_name = swap
    end
    edges[first_name + "'" + second_name] = Edge.new([vertices[first_name], vertices[second_name]])
    [first_name, second_name] = vertex_names.last(2)
    if vertices.has_key?[second_name]
      # return error if second_name is already in vertices hashmap
    end
    bc = edge_lengths[1].to_f
    ca = edge_lengths[2].to_f
    cx = (ca * ca + ab * ab - bc * bc) / 2 / ab
    cy = Math.sqrt(ca * ca - cx * cx)
    vertices[second_name] = Vertex.new([cx, cy, 0])
    if second_name < first_name
      swap = first_name
      second_name = first_name
      first_name = swap
    end
    edges[first_name + "'" + second_name] = Edge.new([vertices[first_name], vertices[second_name]])
    [first_name, second_name] = [vertex_names[0], vertex_names[2]]
    if second_name < first_name
      swap = first_name
      second_name = first_name
      first_name = swap
    end
    edges[first_name + "'" + second_name] = Edge.new([vertices[first_name], vertices[second_name]])

    # parse the (first) tetrahedron
    tetrahedron = shape_arr[1].split(",")

    # based on max/min values of cartesian components of vertices,
    # determine the svg's origin and size
    mins = Array.new(3, Float::INFINITY)
    maxs = Array.new(3, -Float::INFINITY)
    vertices.each_value {|vertex|
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
    vertices.each_value {|vertex|
      (0..2).each{|i|
        vertex.coords[i] = ratio * (vertex.coords[i] - origin[i]) * svg_size / size
      }
    }
    @vertices = vertices
    @edges = edges
    render 'show'
  end

end
