class WelcomeController < ApplicationController

  # GET /
  def index
  end

  # ERROR
  def error
  end

  class Vertex
    attr_accessor :name
    attr_accessor :coords
    def initialize(name, coords)
      @name = name
      @coords = coords
    end
  end

  # Pythogorean theorem
  def distance(coords0, coords1)
    length = 0
    for i in 0..2
      del = coords1[i] - coords0[i]
      del *= del
      length += del
    end
    Math.sqrt(length)
  end

  class Edge
    attr_accessor :ends
    attr_accessor :length
    def initialize(ends)
      @ends = ends
      length = 0
      for i in 0..2
        del = ends[1].coords[i] - ends[0].coords[i]
        del *= del
        length += del
      end
      @length = Math.sqrt(length)
    end
  end

  # class VertexPlusEdgeLength
    # attr_accessor :name
    # attr_accessor :coords
    # attr_accessor :edge_length
    # def initialize(vertex, edge_length)
        # @name = vertex.name
        # @coords = vertex.coords
        # @edge_length = edge_length
    # end
  # end

  class Tetrahedron
    attr_accessor :vertices
    def initialize(vertices)
      @vertices = vertices
    end
  end

  def make_edge(zeroth_name, first_name, vertices, edges)
    # Ensure that two strings in tuple are sorted.
    if first_name < zeroth_name
      swap = first_name
      first_name = zeroth_name
      zeroth_name = swap
    end
    edges[[zeroth_name, first_name]] = Edge.new([vertices[zeroth_name], vertices[first_name]])
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
    edge_length_strings = triangle.last(3)
    zeroth_name, first_name = triangle_names.first(2)
    a = Vertex.new(zeroth_name, [0, 0, 0])
    vertices[zeroth_name] = a
    ab = Float(edge_length_strings[0].sub('*', '.')) rescue nil
    if ab.nil?
      @error = "The path fragment " + edge_length_strings[0] + " cannot be parsed as a number."
      return render :error
    end
    if vertices.has_key?(first_name)
      @error = "The label " + first_name + " is used to label more than one vertex in this polyhedron."
      return render :error
    else
      vertices[first_name] = Vertex.new(first_name, [ab, 0, 0])
    end
    make_edge(zeroth_name, first_name, vertices, edges)
    first_name = triangle_names[2]
    if vertices.has_key?(first_name)
      @error = "The label " + first_name + " is used to label more than one vertex in this polyhedron."
      return render :error
    end
    bc = Float(edge_length_strings[1].sub('*', '.')) rescue nil
    if bc.nil?
      @error = "The path fragment " + edge_length_strings[1] + " cannot be parsed as a number."
      return render :error
    end
    ac = Float(edge_length_strings[2].sub('*', '.')) rescue nil
    if ac.nil?
      @error = "The path fragment " + edge_length_strings[2] + " cannot be parsed as a number."
      return render :error
    end
    cx = (ac * ac + ab * ab - bc * bc) / 2 / ab
    cy = Math.sqrt(ac * ac - cx * cx)
    vertices[first_name] = Vertex.new(first_name, [cx, cy, 0])
    make_edge(triangle_names[1], first_name, vertices, edges)
    make_edge(triangle_names[0], first_name, vertices, edges)

    # parse the tetrahedra
    tetrahedra = shape_arr.drop(1)
    tetrahedra.each_with_index {|tetrahedron_string, i|
      tetrahedron = Tetrahedron.new([], nil)
      tetrahedron_array = tetrahedron_string.split(",")
      if tetrahedron_array.length != 7
        @error = "The " + i.to_s + "-th element of the path's array should have 7 elements, not " + tetrahedron_array.length.to_s + "."
        return render :error
      end
      base_names = tetrahedron_array.first(4)
      new_name = base_names.pop
      if vertices.has_key?(new_name)
        @error = "The label " + new_name + " is used to label more than one vertex in this polyhedron."
        return render :error
      end
      base = base_names.join("-")
      edge_length_strings = tetrahedron_array.last(3)
      tetrahedron_vertices = []
      edge_lengths = []
      for j in 0..2 do
        name = base_names[j]
        length_string = edge_length_strings[j]
        length_attempt = Float(length_string.sub('*', '.')) rescue nil
        error = nil
        if vertices.has_key?(name) && !length_attempt.nil?
          tetrahedron_vertices.push(Vertex.new(vertices[name]))
          edge_lengths.push(length_attempt)
        else
          if !vertices.has_key?(name)
            error = "A vertex ('" + name + "') named as part of the base (" + base + ") of the " + i.to_s + "-th tetrahedron does not seem to match one of the existing ones ([" + vertices.keys.join(", ") + "])."
          else
            error = "The path fragment " + length_string + " cannot be parsed as a number."
          end
        end
        if !error.nil?
          @error = error
          return render :error
        end
      end
      tetrahedron.vertices = tetrahedron_vertices
      coords = [
        tetrahedron.vertices[0].coords.dup,
        tetrahedron.vertices[1].coords.dup,
        tetrahedron.vertices[2].coords.dup,
      ]

      # translation
      origin = coords[0].dup
      for j in 0..2 do
        for k in 0..2 do
          tetrahedron.vertices[j].coords[k] -= origin[k]
        end
      end

      # rotation about z-axis
      coords = [
        tetrahedron.vertices[0].coords.dup,
        tetrahedron.vertices[1].coords.dup,
        tetrahedron.vertices[2].coords.dup,
      ]
      theta_z = Math.atan2(coords[1][1] - coords[0][1], coords[1][0] - coords[0][0])
      cos_z = Math.cos(theta_z)
      sin_z = Math.sin(theta_z)
      for j in 0..2 do
        tetrahedron.vertices[j].coords = [
          cos_z * coords[j][0] + sin_z * coords[j][1],
          -sin_z* coords[j][0] + cos_z * coords[j][1],
          coords[j][2],
        ]
      end

      # rotation about y-axis
      coords = [
        tetrahedron.vertices[0].coords.dup,
        tetrahedron.vertices[1].coords.dup,
        tetrahedron.vertices[2].coords.dup,
      ]
      theta_y = Math.atan2(coords[1][2] - coords[0][2], coords[1][0] - coords[0][0])
      cos_y = Math.cos(theta_y)
      sin_y = Math.sin(theta_y)
      for j in 0..2 do
        tetrahedron.vertices[j].coords = [
          cos_y * coords[j][0] + sin_y * coords[j][2],
          coords[j][1],
          -sin_y * coords[j][0] + cos_y * coords[j][2],
        ]
      end

      # rotation about x-axis
      coords = [
        tetrahedron.vertices[0].coords.dup,
        tetrahedron.vertices[1].coords.dup,
        tetrahedron.vertices[2].coords.dup,
      ]
      theta_x = Math.atan2(coords[1][2] - coords[0][2], coords[1][1] - coords[0][1])
      cos_x = Math.cos(theta_x)
      sin_x = Math.sin(theta_x)
      for j in 0..2 do
        tetrahedron.vertices[j].coords = [
          coords[j][0],
          cos_x * coords[j][1] + sin_x * coords[j][2],
          -sin_x * coords[j][1] + cos_x * coords[j][2],
        ]
      end

      ad = edge_lengths[0]
      bd = edge_lengths[1]
      cd = edge_lengths[2]

      name0 = tetrahedron.vertices[0].name
      name1 = tetrahedron.vertices[1].name
      edge = edges[[name0, name1]] || edges[[name1, name0]]
      ab = edge.length

      name0 = tetrahedron.vertices[0].name
      name2 = tetrahedron.vertices[2].name
      edge = edges[[name0, name2]] || edges[[name2, name0]]
      ac = edge.length

      dx = (ab * ab + ad * ad - bd * bd) / 2 / ab
      s =  (ac * ac + ad * ad - cd * cd) / 2 / ac
      dy = (s * ac - dx * cx) / cy
      dz_sq = ad * ad - dx * dx - dy * dy
      if dz_sq < 0
        @error = "The three edge lengths are not long enough to form a tetrahedron with this triangle."
        return render :error
      end
      vertices[new_name] = Vertex.new(new_name, [dx, dy, Math.sqrt(dz_sq)])

      # back-rotation about x-axis
      coords = [
        tetrahedron.vertices[0].coords.dup,
        tetrahedron.vertices[1].coords.dup,
        tetrahedron.vertices[2].coords.dup,
      ]
      cos_x = Math.cos(theta_x)
      sin_x = Math.sin(theta_x)
      for j in 0..2 do
        tetrahedron.vertices[j].coords = [
          coords[j][0],
          cos_x * coords[j][1] - sin_x * coords[j][2],
          sin_x * coords[j][1] + cos_x * coords[j][2],
        ]
      end

      # back-rotation about y-axis
      coords = [
        tetrahedron.vertices[0].coords.dup,
        tetrahedron.vertices[1].coords.dup,
        tetrahedron.vertices[2].coords.dup,
      ]
      for j in 0..2 do
        tetrahedron.vertices[j].coords = [
          cos_y * coords[j][0] - sin_y * coords[j][2],
          coords[j][1],
          sin_y * coords[j][0] + cos_y * coords[j][2],
        ]
      end

      # back-rotation about z-axis
      coords = [
        tetrahedron.vertices[0].coords.dup,
        tetrahedron.vertices[1].coords.dup,
        tetrahedron.vertices[2].coords.dup,
      ]
      for j in 0..3 do
        tetrahedron.vertices[j].coords = [
          cos_z * coords[j][0] - sin_z * coords[j][1],
          sin_z * coords[j][0] + cos_z * coords[j][1],
          coords[j][2],
        ]
      end

      # back-translation
      for k in 0..2 do
        for j in 0..3 do
          tetrahedron.vertices[j].coords[k] += origin[k]
        end
      end

      make_edge(base_names[0], new_name, vertices, edges)
      make_edge(base_names[1], new_name, vertices, edges)
      make_edge(base_names[2], new_name, vertices, edges)
    }

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
