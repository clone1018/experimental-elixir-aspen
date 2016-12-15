defmodule Infuse.HTTP.Dispatch do

  def register(host, path, plug, opts) do
    true = :ets.insert(:simplate_routes, {host, path, plug, opts})
  end

  def unregister(host, path, plug) do
     true = :ets.match_delete(:simplate_routes, {host, path, plug, :_})
  end

  def init(tab), do: tab

  def call(conn, _wat) do
    case :ets.match_object(:simplate_routes, {conn.host, conn.request_path, :_, :_}) do
      [{host, path, plug, opts}] -> plug.call(conn, plug.init(opts))
      [] -> conn
    end
  end
  
end