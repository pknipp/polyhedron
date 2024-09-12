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
    shape = shape.gsub(/\s+/, "")
    # TODO: put something in instructions in re avoiding this
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
    # TODO: error message unless triangle has 6 elements
    svg_size = 900
    @size = svg_size
    vertex_names = triangle.first(3)
    edge_lengths = triangle.last(3)
    a = Vertex.new([0, 0, 0])
    zeroth_name = vertex_names[0]
    first_name = vertex_names[1]
    vertices = {}
    edges = {}
    vertices[zeroth_name] = a
    ab = edge_lengths[0].to_f
    if vertices.has_key?(first_name)
      # return error if this name is already in vertices hashmap
    else
      vertices[first_name] = Vertex.new([ab, 0, 0])
    end
    if first_name < zeroth_name
      swap = first_name
      first_name = zeroth_name
      zeroth_name = swap
    end
    edges[zeroth_name + "'" + first_name] = Edge.new([vertices[zeroth_name], vertices[first_name]])
    zeroth_name = vertex_names[1]
    first_name = vertex_names[2]
    if vertices.has_key?(first_name)
      # return error if this name is already in vertices hashmap
    end
    bc = edge_lengths[1].to_f
    ca = edge_lengths[2].to_f
    cx = (ca * ca + ab * ab - bc * bc) / 2 / ab
    cy = Math.sqrt(ca * ca - cx * cx)
    vertices[first_name] = Vertex.new([cx, cy, 0])
    if first_name < zeroth_name
      swap = first_name
      first_name = zeroth_name
      zeroth_name = swap
    end
    edges[zeroth_name + "'" + first_name] = Edge.new([vertices[zeroth_name], vertices[first_name]])
    zeroth_name = vertex_names[0]
    first_name = vertex_names[2]
    if first_name < zeroth_name
      swap = first_name
      first_name = zeroth_name
      zeroth_name = swap
    end
    edges[zeroth_name + "'" + first_name] = Edge.new([vertices[zeroth_name], vertices[first_name]])

    # parse the (first) tetrahedron
    tetrahedron = shape_arr[1].split(",")
    # TODO: error message unless tetrahedron has 7 elements

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
