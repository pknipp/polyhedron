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
    svg_size = 900
    @size = svg_size
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
    edges[zeroth_name + "," + first_name] = Edge.new([vertices[zeroth_name], vertices[first_name]])
    zeroth_name = vertex_names[1]
    first_name = vertex_names[2]
    if vertices.has_key?(first_name)
      # return error if this name is already in vertices hashmap
    end
    bc = edge_lengths[1].to_f
    ac = edge_lengths[2].to_f
    cx = (ac * ac + ab * ab - bc * bc) / 2 / ab
    cy = Math.sqrt(ac * ac - cx * cx)
    vertices[first_name] = Vertex.new([cx, cy, 0])
    if first_name < zeroth_name
      swap = first_name
      first_name = zeroth_name
      zeroth_name = swap
    end
    edges[zeroth_name + "," + first_name] = Edge.new([vertices[zeroth_name], vertices[first_name]])
    zeroth_name = vertex_names[0]
    first_name = vertex_names[2]
    if first_name < zeroth_name
      swap = first_name
      first_name = zeroth_name
      zeroth_name = swap
    end
    edges[zeroth_name + "," + first_name] = Edge.new([vertices[zeroth_name], vertices[first_name]])

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
    edge_lengths = triangle.last(3)
    ad = edge_lengths[0].to_f
    bd = edge_lengths[1].to_f
    cd = edge_lengths[2].to_f
    dx = (ab * ab + ad * ad - bd * bd) / 2 / ab
    s =  (ac * ac + ad * ad - cd * cd) / 2 / ac
    dy = (s * ac * ac - dx * cx) / ac / cy
    arg = ad * ad - dx * dx - dy * dy
    dz = Math.sqrt(arg)
    vertices[new_name] = Vertex.new([dx, dy, dz])
    zeroth_name = existing[0]
    first_name = new_name
    if first_name < zeroth_name
      swap = first_name
      first_name = zeroth_name
      zeroth_name = swap
    end
    edges[zeroth_name + "," + first_name] = Edge.new([vertices[zeroth_name], vertices[first_name]])
    zeroth_name = existing[1]
    first_name = new_name
    if first_name < zeroth_name
      swap = first_name
      first_name = zeroth_name
      zeroth_name = swap
    end
    edges[zeroth_name + "," + first_name] = Edge.new([vertices[zeroth_name], vertices[first_name]])
    zeroth_name = existing[2]
    first_name = new_name
    if first_name < zeroth_name
      swap = first_name
      first_name = zeroth_name
      zeroth_name = swap
    end
    edges[zeroth_name + "," + first_name] = Edge.new([vertices[zeroth_name], vertices[first_name]])
    # puts edges

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
