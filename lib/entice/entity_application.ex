defmodule Entice.Entity.Application do
  use Application

  def start(_type, _args) do
    Entice.Entity.Supervisor.start_link
  end
end