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
      return render :error
    end
    shape = shape[1..-1]
    second_char = shape[0]
    if second_char != "("
      @error = "The path's second character should be '(' not '" + second_char + "'."
      return render :error
    end
    shape = shape[1..-1]
    last_char = shape[-1]
    if last_char != "]"
      @error = "The path's last character should be ']' not '" + last_char + "'."
      return render :error
    end
    shape = shape[0..-2]
    second_to_last_char = shape[-1]
    if second_to_last_char != ")"
      @error = "The path's second to last character should be ')' not '" + second_to_last_char + "'."
      return render :error
    end
    shape = shape[0..-2]
    shape_arr = shape.split("),(")

    # parse the first triangle
    triangle = shape_arr[0].split(",")
    if triangle.length != 6
      @error = "The first element of the path's array should have 6 elements, not " + triangle.length.to_s + "."
      return render :error
    end
    triangle_names = triangle.first(3)
    edge_lengths = triangle.last(3)
    a = Vertex.new([0, 0, 0])
    zeroth_name, first_name = triangle_names.first(2)
    vertices[zeroth_name] = a
    ab = Float(edge_lengths[0].sub('*', '.')) rescue nil
    if ab.nil?
      @error = "The path fragment " + edge_lengths[0] + " cannot be parsed as a number."
      return render :error
    end
    if vertices.has_key?(first_name)
      @error = "The label " + first_name + " is used to label more than one vertex in this polyhedron."
      return render :error
    else
      vertices[first_name] = Vertex.new([ab, 0, 0])
    end
    make_edge(zeroth_name, first_name, vertices, edges)
    first_name = triangle_names[2]
    if vertices.has_key?(first_name)
      @error = "The label " + first_name + " is used to label more than one vertex in this polyhedron."
      return render :error
    end
    bc = Float(edge_lengths[1].sub('*', '.')) rescue nil
    if bc.nil?
      @error = "The path fragment " + edge_lengths[1] + " cannot be parsed as a number."
      return render :error
    end
    ac = Float(edge_lengths[2].sub('*', '.')) rescue nil
    if ac.nil?
      @error = "The path fragment " + edge_lengths[2] + " cannot be parsed as a number."
      return render :error
    end
    cx = (ac * ac + ab * ab - bc * bc) / 2 / ab
    cy = Math.sqrt(ac * ac - cx * cx)
    vertices[first_name] = Vertex.new([cx, cy, 0])
    make_edge(triangle_names[1], first_name, vertices, edges)
    make_edge(triangle_names[0], first_name, vertices, edges)

    # parse the (first) tetrahedron
    tetrahedron = shape_arr[1].split(",")
    if tetrahedron.length != 7
      @error = "The second element of the path's array should have 7 elements, not " + tetrahedron.length.to_s + "."
      return render :error
    end
    tetrahedron_names = tetrahedron.first(4)
    base_names = tetrahedron_names.first(3)
    base = base_names.join("-")
    base_names.each do |base_name|
      if !vertices.has_key?(base_name)
        @error = "A vertex (" + base_name + ") named in the base (" + base + ") of a tetrahedron does not seem to match one of the existing ones ([" + vertices.keys.join(", ") + "])."
        return render :error
      end
    end
    new_name = tetrahedron_names.last(1)[0]
    if vertices.has_key?(new_name)
      @error = "The label " + new_name + " is used to label more than one vertex in this polyhedron."
      return render :error
    end
    edge_lengths = tetrahedron.last(3)
    ad = Float(edge_lengths[0].sub('*', '.')) rescue nil
    if ad.nil?
      @error = "The path fragment " + edge_lengths[0] + " cannot be parsed as a number."
      return render :error
    end
    bd = Float(edge_lengths[1].sub('*', '.')) rescue nil
    if bd.nil?
      @error = "The path fragment " + edge_lengths[1] + " cannot be parsed as a number."
      return render :error
    end
    cd = Float(edge_lengths[2].sub('*', '.')) rescue nil
    if cd.nil?
      @error = "The path fragment " + edge_lengths[2] + " cannot be parsed as a number."
      return render :error
    end
    dx = (ab * ab + ad * ad - bd * bd) / 2 / ab
    puts dx
    s =  (ac * ac + ad * ad - cd * cd) / 2 / ac
    dy = (s * ac - dx * cx) / cy
    puts dy
    dz_sq = ad * ad - dx * dx - dy * dy
    if dz_sq < 0
      @error = "The three edge lengths are not long enough form a tetrahedron with this triangle."
      return render :error
    end
    vertices[new_name] = Vertex.new([dx, dy, Math.sqrt(dz_sq)])
    make_edge(base_names[0], new_name, vertices, edges)
    make_edge(base_names[1], new_name, vertices, edges)
    make_edge(base_names[2], new_name, vertices, edges)

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
