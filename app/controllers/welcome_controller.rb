class WelcomeController < ApplicationController

  # GET /
  def index
  end

  # ERROR
  def error
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

  def number(string)
    string = string.sub('*', '.').to_f
  end

  def make_edge(zeroth_name, first_name, vertices, edges)
    if first_name < zeroth_name
      swap = first_name
      first_name = zeroth_name
      zeroth_name = swap
    end
    edges[zeroth_name + "," + first_name] = Edge.new([vertices[zeroth_name], vertices[first_name]])
  end

  # GET /:shape
  def show
    svg_size = 900
    @size = svg_size
    vertices = {}
    @vertices = vertices
    edges = {}
    @edges = edges
    # parse the entire url
    shape = params[:shape].gsub(/\s+/, "")
    first_char = shape[0]
    if first_char != "["
      @error = "The path's first character should be '[' not '" + first_char + "'."
      render :error
      return
    end
    shape = shape[1..-1]
    second_char = shape[0]
    if second_char != "("
      @error = "The path's second character should be '(' not '" + second_char + "'."
      render :error
      return
    end
    shape = shape[1..-1]
    last_char = shape[-1]
    if last_char != "]"
      @error = "The path's last character should be ']' not '" + last_char + "'."
      render :error
      return
    end
    shape = shape[0..-2]
    second_to_last_char = shape[-1]
    if second_to_last_char != ")"
      @error = "The path's second to last character should be ')' not '" + second_to_last_char + "'."
      render :error
      return
    end
    shape = shape[0..-2]
    shape_arr = shape.split("),(")

    # parse the first triangle
    triangle = shape_arr[0].split(",")
    if triangle.length != 6
      @error = "The first element of the path's array should have 6 elements, not " + triangle.length.to_s + "."
      render :error
      return
    end
    vertex_names = triangle.first(3)
    edge_lengths = triangle.last(3)
    a = Vertex.new([0, 0, 0])
    zeroth_name, first_name = vertex_names.first(2)
    vertices[zeroth_name] = a
    ab = number(edge_lengths[0])
    if vertices.has_key?(first_name)
      @error = "The label " + first_name + " is used to label more than one vertex in this polyhedron."
      render :error
      return
    else
      vertices[first_name] = Vertex.new([ab, 0, 0])
    end
    make_edge(zeroth_name, first_name, vertices, edges)
    first_name = vertex_names[2]
    if vertices.has_key?(first_name)
      # return error if this name is already in vertices hashmap
    end
    bc = number(edge_lengths[1])
    ac = number(edge_lengths[2])
    cx = (ac * ac + ab * ab - bc * bc) / 2 / ab
    cy = Math.sqrt(ac * ac - cx * cx)
    vertices[first_name] = Vertex.new([cx, cy, 0])
    make_edge(vertex_names[1], first_name, vertices, edges)
    make_edge(vertex_names[0], first_name, vertices, edges)

    # parse the (first) tetrahedron
    tetrahedron = shape_arr[1].split(",")
    # TODO: error message unless tetrahedron has 7 elements
    vertex_names = tetrahedron.first(4)
    existing = vertex_names.first(3)
    if !vertices.has_key?(existing[0]) || !vertices.has_key?(existing[1]) || !vertices.has_key?(existing[2])
      # return error if any of these names are not already in vertices hashmap
    end
    new_name = vertex_names.last(1)[0]
    if vertices.has_key?(new_name)
      # return error if this name is already in vertices hashmap
    end
    edge_lengths = tetrahedron.last(3)
    ad = number(edge_lengths[0])
    bd = number(edge_lengths[1])
    cd = number(edge_lengths[2])
    dx = (ab * ab + ad * ad - bd * bd) / 2 / ab
    s =  (ac * ac + ad * ad - cd * cd) / 2 / ac
    dy = (s * ac - dx * cx) / cy
    arg = ad * ad - dx * dx - dy * dy
    dz = Math.sqrt(arg)
    vertices[new_name] = Vertex.new([dx, dy, dz])
    make_edge(existing[0], new_name, vertices, edges)
    make_edge(existing[1], new_name, vertices, edges)
    make_edge(existing[2], new_name, vertices, edges)

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
    # Following value attempts to prevent object from rotating out of svg cube.
    ratio = 0.7
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
