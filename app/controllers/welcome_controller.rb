class WelcomeController < ApplicationController

  # GET /
  def index
  end

  # ERROR
  def error
  end

  class Vertex
    attr_accessor :key
    attr_accessor :label
    attr_accessor :coords
    def initialize(key, label, coords)
      @key = key
      @label = label
      @coords = coords
    end
    def make_edge_with(other_vertex, edges, render)
      sorted_keys = [key, other_vertex.key].sort
      edges[sorted_keys] = Edge.new(self, other_vertex, render)
    end
  end

  class Edge
    attr_accessor :ends
    attr_accessor :render
    attr_accessor :length
    def initialize(end0, end1, render)
      zeroth_end = end0
      first_end = end1
      if zeroth_end.key > first_end.key
        swap = zeroth_end
        zeroth_end = end1
        first_end = swap
      end
      @ends = [zeroth_end, first_end]
      @render = render
      total_distance = 0
      for i in 0..2 do
        distance = end0.coords[i] - end1.coords[i]
        distance *= distance
        total_distance += distance
      end
      @length = Math.sqrt(total_distance)
    end
    def toggle_visilibility
      @render = !render
    end
  end

  class Tetrahedron
    attr_accessor :vertices
    def initialize(vertices)
      @vertices = vertices
    end
  end

  def dup(tetrahedron_vertices)
    cloned_vertices = tetrahedron_vertices.map {|vertex| vertex.coords.dup}
    if tetrahedron_vertices.length > 3
      cloned_vertices.push(tetrahedron_vertices[3].coords.dup)
    end
    cloned_vertices
  end

  def rescale(vertices, svg_size)
    # based on max/min values of cartesian components of vertices,
    # determine the svg's origin and size
    mins = Array.new(3, Float::INFINITY)
    maxs = Array.new(3, -Float::INFINITY)
    vertices.each_value do |vertex|
      (0..2).each do |i|
        mins[i] = [mins[i], vertex.coords[i]].min
        maxs[i] = [maxs[i], vertex.coords[i]].max
      end
    end
    origin = []
    size = 0
    (0..2).each do |i|
      origin.push((maxs[i] + mins[i]) / 2)
      size = [size, maxs[i] - mins[i]].max
    end
    # Following value attempts to prevent object from rotating out of svg cube.
    ratio = 0.6
    vertices.each_value do |vertex|
      (0..2).each do |i|
        vertex.coords[i] = ratio * (vertex.coords[i] - origin[i]) * svg_size / size
      end
    end
  end

  # GET /points/:vertices/:edges
  def points
    svg_size = 900
    @size = svg_size
    vertices = {}
    edges = {}
    @vertices = vertices
    @edges = edges

    # parse the vertices
    vertices_string = params[:vertices].gsub(/\s+/, "")
    first_char = vertices_string[0]
    if first_char != "("
      @error = "The first path-fragments's first character should be '(' not '" + first_char + "'."
      return render :error
    end
    last_char = vertices_string[-1]
    if last_char != ")"
      @error = "The first path-fragment's last character should be ')' not '" + last_char + "'."
      return render :error
    end
    vertices_string = vertices_string[1..-2]
    vertex_string_array = vertices_string.split("),(")
    vertex_string_array.each do |vertex_string|
      vertex_tuple = vertex_string.split(",")
      has_label = vertex_tuple.length == 5
      if !(vertex_tuple.length == 4 || has_label)
        @error = "The tuple (" + vertex_string + ") should have 4 elements not " + vertex_tuple.length.to_s + "."
        return render :error
      end
      key = vertex_tuple.shift
      label = has_label ? vertex_tuple.shift : key
      coord_string_array = vertex_tuple
      coords = []
      coord_string_array.each do |coord_string|
        coord = Float(coord_string.sub('*', '.')) rescue nil
        if coord.nil?
          @error = "The path fragment " + coord_string + " cannot be parsed as a number."
          return render :error
        end
        coords.push(coord)
      end
      if vertices.has_key?(key)
        @error = "The key " + key + " is used to designate more than one vertex in this structure."
        return render :error
      else
        vertices[key] = Vertex.new(key, label, coords)
      end
    end
    rescale(vertices, svg_size)
    @vertices = vertices

    edges_string = params[:edges].gsub(/\s+/, "")
    if edges_string
      # parse the edges
      first_char = edges_string[0]
      if first_char != "("
        @error = "The second path-fragments's first character should be '(' not '" + first_char + "'."
        return render :error
      end
      edges_string = edges_string[1..-1]
      last_char = edges_string[-1]
      if last_char != ")"
        @error = "The second path-fragment's last character should be ')' not '" + last_char + "'."
        return render :error
      end
      edges_string = edges_string[0..-2]
      edge_string_array = edges_string.split("),(")
      edge_string_array.each do |edge_string|
        edge_tuple = edge_string.split(",")
        if edge_tuple.length != 2
          @error = "The tuple (" + edge_string + ") should have 2 elements not " + edge_tuple.length.to_s + "."
          return render :error
        end
        vertices[edge_tuple[0]].make_edge_with(vertices[edge_tuple[1]], edges, true)
      end
      @edges = edges
    end
    render 'show'
  end

  # GET /:triangle/:tetrahedra
  def edges
    svg_size = 900
    @size = svg_size
    vertices = {}
    @vertices = vertices
    edges = {}
    @edges = edges

    # parse the first triangle
    triangle_array = params[:triangle].gsub(/\s+/, "").split(",")
    if triangle_array.length != 6
      @error = "The first element of the path's array should have 6 elements, not " + triangle_array.length.to_s + "."
      return render :error
    end
    triangle_keys = triangle_array.first(3)
    edge_length_strings = triangle_array.last(3)
    zeroth_key, first_key = triangle_keys.first(2)
    a = Vertex.new(zeroth_key, zeroth_key, [0, 0, 0])
    vertices[zeroth_key] = a
    ab = Float(edge_length_strings[0].sub('*', '.')) rescue nil
    if ab.nil?
      @error = "The path fragment " + edge_length_strings[0] + " cannot be parsed as a number."
      return render :error
    end
    if vertices.has_key?(first_key)
      @error = "The label " + first_key + " is used to label more than one vertex in this polyhedron."
      return render :error
    else
      vertices[first_key] = Vertex.new(first_key, first_key, [ab, 0, 0])
    end
    vertices[zeroth_key].make_edge_with(vertices[first_key], edges, true)
    first_key = triangle_keys[2]
    if vertices.has_key?(first_key)
      @error = "The label " + first_key + " is used to label more than one vertex in this polyhedron."
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
    vertices[first_key] = Vertex.new(first_key, first_key, [cx, cy, 0])
    vertices[triangle_keys[1]].make_edge_with(vertices[first_key], edges, true)
    vertices[triangle_keys[0]].make_edge_with(vertices[first_key], edges, true)

    tetrahedra_string = params[:tetrahedra]
    if tetrahedra_string
      # parse the tetrahedra
      tetrahedra_string = tetrahedra_string.gsub(/\s+/, "")
      first_char = tetrahedra_string[0]
      if first_char != "("
        @error = "The second path fragment (" + tetrahedra_string + ") should start with an open paren, not with " + first_char
        return render :error
      end
      last_char = tetrahedra_string[-1]
      if last_char != ")"
        @error = "The second path fragment [" + tetrahedra_string + "] should end with a close paren, not with " + last_char + "."
        return render :error
      end
      tetrahedra_array = tetrahedra_string[1..-2].split("),(")
      tetrahedra_array.each_with_index do |tetrahedron_string, i|
        tetrahedron = Tetrahedron.new([])
        tetrahedron_array = tetrahedron_string.split(",")
        is_edge = tetrahedron_array.length == 2
        is_flat = tetrahedron_array.length == 6
        is_tetrahedron = tetrahedron_array.length == 7
        if !(is_edge || is_flat || is_tetrahedron)
          @error = "The " + i.to_s + "-th element of the path's array should have 2, 6, or 7 elements, not " + tetrahedron_array.length.to_s + "."
          return render :error
        end
        base_keys = tetrahedron_array.first(is_edge ? 2 : 4)
        new_key = is_edge ? nil : base_keys.pop
        base_keys.each {|key|
          if !vertices.has_key?(key)
            error = "A vertex ('" + key + "') named as part of a base or edge (" + base_keys.join("-") + ") of the " + i.to_s + "-th tetrahedron does not seem to match one of the existing vertices ([" + vertices.keys.join(", ") + "])."
            @error = error
            return render :error
          end
        }
        if is_edge
          edge = edges[[base_keys[0], base_keys[1]].sort]
          if edge.nil?
            edge = vertices[base_keys[0]].make_edge_with(vertices[base_keys[1]], edges, true)
          else
            edge.toggle_visilibility
          end
        else
          if vertices.has_key?(new_key)
            @error = "The label " + new_key + " is used to specify more than one vertex in this polyhedron."
            return render :error
          end
          edge_length_strings = tetrahedron_array.last(is_flat ? 2 : 3)
          tetrahedron_vertices = []
          edge_lengths = []
          base_keys.each_with_index {|key, j|
            tetrahedron_vertices.push(Vertex.new(key, key, vertices[key].coords))
            if !is_flat || j < 2
              length_string = edge_length_strings[j]
              length_attempt = Float(length_string.sub('*', '.')) rescue nil
              if !length_attempt.nil?
                edge_lengths.push(length_attempt)
              else
                error = "The path fragment " + length_string + " cannot be parsed as a number."
                @error = error
                return render :error
              end
            end
          }
          tetrahedron.vertices = tetrahedron_vertices

          # translation
          origin = tetrahedron.vertices[0].coords.dup
          tetrahedron.vertices.each {|vertex| (0..2).each {|k| vertex.coords[k] -= origin[k]}}

          # rotation about z-axis
          coords = dup(tetrahedron.vertices)
          theta_z = Math.atan2(coords[1][1] - coords[0][1], coords[1][0] - coords[0][0])
          cos_z = Math.cos(theta_z)
          sin_z = Math.sin(theta_z)
          for j in 0..2
            tetrahedron.vertices[j].coords = [
              cos_z * coords[j][0] + sin_z * coords[j][1],
              -sin_z* coords[j][0] + cos_z * coords[j][1],
              coords[j][2],
            ]
          end

          # rotation about y-axis
          coords = dup(tetrahedron.vertices)
          theta_y = Math.atan2(coords[1][2] - coords[0][2], coords[1][0] - coords[0][0])
          cos_y = Math.cos(theta_y)
          sin_y = Math.sin(theta_y)
          for j in 0..2
            tetrahedron.vertices[j].coords = [
              cos_y * coords[j][0] + sin_y * coords[j][2],
              coords[j][1],
              -sin_y * coords[j][0] + cos_y * coords[j][2],
            ]
          end

          # rotation about x-axis
          coords = dup(tetrahedron.vertices)
          theta_x = Math.atan2(coords[2][2] - coords[0][2], coords[2][1] - coords[0][1])
          cos_x = Math.cos(theta_x)
          sin_x = Math.sin(theta_x)
          for j in 0..2
            tetrahedron.vertices[j].coords = [
              coords[j][0],
              cos_x * coords[j][1] + sin_x * coords[j][2],
              -sin_x * coords[j][1] + cos_x * coords[j][2],
            ]
          end

          # Calculate location of apex of tetrahedron
          ad = edge_lengths[0]
          bd = edge_lengths[1]
          cd = is_flat ? nil : edge_lengths[2]

          key0 = tetrahedron.vertices[0].key
          key1 = tetrahedron.vertices[1].key
          edge = edges[[key0, key1].sort]
          ab = edge.length

          key0 = tetrahedron.vertices[0].key
          key2 = tetrahedron.vertices[2].key
          edge = edges[[key0, key2].sort]
          ac = edge.length
          # p [key0, key1, key2, new_key, theta_z, theta_y, theta_z]

          if !is_flat
            dx = nil
            dy = nil
            dx = (ab * ab + ad * ad - bd * bd) / 2 / ab
            s =  (ac * ac + ad * ad - cd * cd) / 2 / ac
            dy = (s * ac - dx * tetrahedron.vertices[2].coords[0]) / tetrahedron.vertices[2].coords[1]
            dz_sq = ad * ad - dx * dx - dy * dy
            if dz_sq < 0
              @error = "The three edge lengths are not long enough to form a tetrahedron with triangle " + key0 + "-" + key1 + "-" + key2 + " and vertex " + new_key + "."
              return render :error
            end
            # Determine whether tetrahedral base vertices are listed clockwise when viewed from above.
            coords = tetrahedron.vertices.map {|vertex| vertex.coords}
            cw = (coords[1][0] - coords[0][0]) * (coords[2][1] - coords[0][1]) > (coords[1][1] - coords[0][1]) * (coords[2][0] - coords[0][0])
            tetrahedron.vertices.push(Vertex.new(new_key, new_key, [dx, dy, Math.sqrt(dz_sq) * (cw ? 1 : -1)]))
          else
            dx = (ad * ad + ab * ab - bd * bd) / 2 / ab
            dy = -Math.sqrt(ad * ad - dx * dx)
            vertices[new_key] = Vertex.new(new_key, new_key, [dx, dy, 0])
            tetrahedron.vertices.push(vertices[new_key])
          end

          # back-rotation about x-axis
          coords = dup(tetrahedron.vertices)
          for j in 0..3
            tetrahedron.vertices[j].coords = [
              coords[j][0],
              cos_x * coords[j][1] - sin_x * coords[j][2],
              sin_x * coords[j][1] + cos_x * coords[j][2],
            ]
          end

          # back-rotation about y-axis
          coords = dup(tetrahedron.vertices)
          for j in 0..3
            tetrahedron.vertices[j].coords = [
              cos_y * coords[j][0] - sin_y * coords[j][2],
              coords[j][1],
              sin_y * coords[j][0] + cos_y * coords[j][2],
            ]
          end

          # back-rotation about z-axis
          coords = dup(tetrahedron.vertices)
          for j in 0..3
            tetrahedron.vertices[j].coords = [
              cos_z * coords[j][0] - sin_z * coords[j][1],
              sin_z * coords[j][0] + cos_z * coords[j][1],
              coords[j][2],
            ]
          end

          # back-translation
          (0..2).each {|k| tetrahedron.vertices.each {|vertex| vertex.coords[k] += origin[k]}}

          # Insert one entry to vertices hashmap and three to edges hashmap.
          vertices[new_key] = tetrahedron.vertices[3]
          base_keys.each_with_index {|base_key, j|
            vertices[base_key].make_edge_with(vertices[new_key], edges, true)
          }
          if is_flat
            edges[[base_keys[0], base_keys[1]].sort].toggle_visilibility
            edges[[base_keys[2], new_key].sort].toggle_visilibility
          end
          p [vertices["A"].coords, vertices["B"].coords, vertices["C"].coords, vertices["D"].coords]
        end
        p [vertices["A"].coords, vertices["B"].coords, vertices["C"].coords, vertices["D"].coords]
      end
      p [vertices["A"].coords, vertices["B"].coords, vertices["C"].coords, vertices["D"].coords]
    end
    p [vertices["A"].coords, vertices["B"].coords, vertices["C"].coords, vertices["D"].coords]
    rescale(vertices, svg_size)
    @vertices = vertices
    @edges = edges
    render 'show'
  end
end
