defmodule Exgameoflife.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.ViewPort

  import Scenic.Primitives

  #constants, frame_ms is the duration :timer waits to send in ms.
  @init_graph Graph.build(theme: :light, clear_color: :white)
  @frame_ms 60
  @nr_cells 300
  @cell_width 10
  @cell_height 10
  @cell_margin 1

  def init(_, opts) do
    viewport = opts[:viewport]

    graph = @init_graph

    # getting the width and height of window
    {:ok, %ViewPort.Status{size: {width, height}}} = ViewPort.info(viewport)

    {:ok, timer} = :timer.send_interval(@frame_ms, :frame)

    # state map
    state = %{
      viewport: viewport,
      width: width,
      height: height,
      cwidth: @cell_width,
      cheight: @cell_height,
      cmargin: @cell_margin,
      graph: graph,
      frame_timer: timer,
      cells: []
    }

    {:ok, state}
  end

  # this catches the :timer message
  def handle_info(:frame, state) do
    state = gen(state)

    draw_cells(state)
    |> push_graph

    {:noreply, state}
  end

  # This function spawns 4 async tasks that goes through each "pixel" and checks it's neighbours--- WIP
  #  defp pgen(state = %{width: w, height: h, cwidth: cw, cheight: ch}) do
  #  cells =
  #   [
  #     Task.async(Exgameoflife.Scene.Home, :step, [state, div(w, 2), div(h, 2), 0, 0]),
  #     Task.async(Exgameoflife.Scene.Home, :step, [state, w, div(h, 2), div(w, 2), 0]),
  #     Task.async(Exgameoflife.Scene.Home, :step, [state, div(w, 2), h, 0, div(h, 2)]),
  #     Task.async(Exgameoflife.Scene.Home, :step, [state, w, h, div(w, 2), div(h, 2)])
  #   ]
  #   |> Enum.flat_map(&Task.await/1)
  #
  # Map.put(state, :cells, cells)
  # end

  def gen(state = %{cells: cells, cwidth: cw, cheight: ch, width: w, height: h}) do
    ncells = Enum.map(step(0, h, ch), fn y ->
      Enum.reduce(step(0, w, ch), [], fn x, acc ->
        member? = Enum.member?(cells, {x, y})

        neighbours({x, y}, cells, {cw, ch})
        |> case do
          n when n == 2 and member? -> [{x, y} | acc]
          n when n == 3 -> [{x, y} | acc]
          _ -> [[] | acc]
        end
      end)
    end)
    |> List.flatten()

    Map.put(state, :cells,ncells)
  end

  #filters the list so that only the cells neighbours is in it. Then counts the neighbours
  def neighbours({x, y}, list, {w, h}) do
    Stream.filter(list, fn {x1, y1} ->
      x1 >= x - w and x1 <= x + w and y1 >= y - h and y1 <= y + h and {x, y} != {x1, y1}
    end)
    |> Enum.count()
  end

  defp add_cells(state = %{width: w, height: h, cwidth: cw, cheight: ch}, count) do
    list =
      Enum.map(0..count, fn x ->
        <<i1::unsigned-integer-32, i2::unsigned-integer-32, i3::unsigned-integer-32>> =
          :crypto.strong_rand_bytes(12)

        :rand.seed(:exsplus, {i1, i2, i3})
        {Enum.random(step(0, w, cw)), Enum.random(step(0, h, ch))}
      end)

    Map.put(state, :cells, list)
  end

  defp draw_cells(%{cells: cells, graph: graph, cmargin: cm, cwidth: cw, cheight: ch}) do
    Enum.reduce(cells, graph, fn {x, y}, graph ->
      draw_cell(graph, x, y, cw, ch, cm)
    end)
  end

  defp draw_cell(graph, x, y, w, h, cm) do
    graph |> rect({w - cm, h - cm}, fill: {:color, :black}, translate: {x, y})
  end

  # found when searching for a range step function sort of like in haskell
  def step(f, l, d) do
    f
    |> Stream.iterate(&(&1 + d))
    |> Stream.take_while(&(&1 <= l))
  end

  def handle_input({:key, {"enter", :press, _}}, _context, state) do
    {:noreply, add_cells(state, @nr_cells)}
  end

  def handle_input(_input, _context, state), do: {:noreply, state}
end
