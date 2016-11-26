defmodule Simplate do
  require Logger

  @page_split_regex ~r/()\[---+\]()/

  defstruct file: nil, once: nil, every: nil, templates: {}, once_bindings: nil  
  
  @doc """
  Opens a simplate, sends to load
  """
  def load_file(file) do
    Logger.info("Simplate: Loading " <> file)
    {:ok, body} = File.read(file)

    load(body, file)
  end

  @doc """
  Takes contents, executes the first page and quotes the second page for later
  """
  def load(contents, file \\ nil) do
    {[once, every], templates} = parse_pages(contents) |> organize_pages()
    {_, once_bindings} = Code.eval_string(once.content)

    # Race condition

    %Simplate{
      file: file, 
      once: once,
      every: every,
      templates: organize_templates(templates), 
      once_bindings: once_bindings
    }
  end

@doc """
  Render a simplate, returning the output, will eventually be moved.
  """
  def render(simplate) do
    render(simplate, Application.get_env(:infuse, :default_content_type))
  end

  def render(simplate, content_type) do
    {_, bindings} = Code.eval_string(simplate.every.content, simplate.once_bindings)

    template = simplate.templates["#{content_type}"]

    ren = Module.concat(["Infuse","Simplates","Renderers", template.renderer <> "Renderer"])
    ren.render(template.content, bindings)
  end

  @doc """
  If there's one page, it's a template.
  If there's more than one page, the first page is always code and the last is always a template.
  If there's more than two pages, the second page is code *unless it has a specline*, which makes it a template
  """
  def parse_pages(raw) do 
    #[pages] = Regex.split(@page_split_regex, raw, on: [1]) |> Enum.map(fn(p) -> parse_page(p) end)

    split_pages(raw) |> fill_blank_pages
  end

  defp fill_blank_pages(pages) do
    blank = [ %Page{} ] 

    case length(pages) do
      1 -> blank ++ blank ++ pages
      2 -> blank ++ pages
      _ -> pages
    end
  end

  defp split_pages(raw) do
    Regex.split(@page_split_regex, raw, on: [1]) |> Enum.map(fn(p) -> 
      do_page(p)
    end)
  end

  defp do_page(raw) do
    raw = Regex.replace(@page_split_regex, raw, "")
    split = String.split(raw, "\n")
    first_line = String.trim(hd(split))
    {status, renderer, content_type} = parse_specline(first_line)

    page_content = 
      case status do
        :ok -> tl(split) |> Enum.join(" ") |> String.trim()
        :empty -> raw  
      end

    %Page{content: page_content, renderer: renderer, content_type: content_type}
  end

  defp organize_templates(pages) do
    Enum.reduce(pages, %{}, fn page, acc ->
      Map.put(acc, page.content_type, page) 
    end)
  end

  defp organize_pages(pages) do
    code = Enum.take(pages, 2)
    templates = tl(tl(pages))

    {code, templates}
  end

  @specline_full_regex ~r/^(?P<content_type>[a-zA-Z\/]+)\s*via\s*(?P<renderer>\w+)$/
  @specline_content_regex ~r/^[a-zA-Z\/]+$/
  @specline_renderer_regex ~r/via\s*(?P<renderer>\w+)/

  @doc """ 
  Parses a specline like `media/type via EEx` into a tuple {status, renderer, content_type}

  Status can be:
    `:ok` => Specline so we need to trim the first line
    `:empty` => No specline at all, don't trim line
  """
  def parse_specline(line) do 
    line = Regex.replace(@page_split_regex, line, "")
    cond do
      Regex.match?(@specline_full_regex, line) -> parse_full_specline(line)
      Regex.match?(@specline_content_regex, line) -> parse_content_specline(line)
      Regex.match?(@specline_renderer_regex, line) -> parse_renderer_specline(line) 
      true -> parse_empty_specline()
    end
  end

  defp parse_full_specline(line) do
    parsed = Regex.named_captures(@specline_full_regex, line)

    {:ok, Map.get(parsed, "renderer"), Map.get(parsed, "content_type")}
  end

  defp parse_content_specline(line) do
    {:ok, Application.get_env(:infuse, :default_renderer), line}
  end

  defp parse_renderer_specline(line) do
    parsed = Regex.named_captures(@specline_renderer_regex, line)
    {:ok, Map.get(parsed, "renderer"), Application.get_env(:infuse, :default_content_type)}
  end
  
  defp parse_empty_specline do
    {:empty, Application.get_env(:infuse, :default_renderer), Application.get_env(:infuse, :default_content_type)}
  end

end
