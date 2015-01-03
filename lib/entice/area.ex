defmodule Entice.Area do

  defmodule Map do
    @moduledoc """
    This macro puts all common map functions inside the module that uses it
    """

    defmacro __using__(_) do
      quote do
        # Define the module content
        alias Entice.Area.Geom.Coord

        def name, do: __MODULE__
        def spawn, do: %Coord{}

        defoverridable [name: 0, spawn: 0]

        # Define a supervisor
        sup_name = Module.concat(__MODULE__, "Sup")
        sup_contents = quote do
          def start_link, do: Entice.Area.Entity.Sup.start_link(unquote(__MODULE__))
        end

        Module.create(sup_name, sup_contents, Macro.Env.location(__ENV__))
      end
    end
  end


  defmodule HeroesAscent, do: use Map
  defmodule RandomArenas, do: use Map
  defmodule TeamArenas,   do: use Map


  @doc """
  Simplistic map getter, tries to convert a map name to the module atom.
  The map should be a GW map name, without "Entice.Area.Worlds"
  """
  def get_map(name) do
    try do
      {:ok, ((__MODULE__ |> Atom.to_string) <> "." <> name) |> String.to_existing_atom}
    rescue
      ArgumentError -> {:error, :map_not_found}
    end
  end
end


defmodule Entice.Area.Sup do
  use Supervisor

  def start_link, do: Supervisor.start_link(__MODULE__, :ok)

  def init(:ok) do
    children = [
      supervisor(Entice.Area.HeroesAscent.Sup, []),
      supervisor(Entice.Area.RandomArenas.Sup, []),
      supervisor(Entice.Area.TeamArenas.Sup, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end