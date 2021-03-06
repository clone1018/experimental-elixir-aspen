# Infuse

[![Build Status](https://travis-ci.org/LawfulGood/infuse.svg?branch=master)](https://travis-ci.org/LawfulGood/infuse) [![Coverage Status](https://coveralls.io/repos/github/LawfulGood/infuse/badge.svg?branch=master)](https://coveralls.io/github/LawfulGood/infuse?branch=master)

Simple filesystem web framework using [Simplates](https://github.com/LawfulGood/infuse/wiki/Simplates). Inspired by [Aspen](https://github.com/AspenWeb/aspen.py). Using [Plug](https://github.com/elixir-lang/plug)

It is currently **not ready for use in development or production**.


## Possible Installation

You can use [Hex](https://hex.pm/packages/infuse), to install the package:

  1. Add `infuse` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:infuse, "~> 0.2.0"}]
    end
    ```

  2. Ensure `infuse` is started before your application:

    ```elixir
    def application do
      [applications: [:infuse]]
    end
    ```

  3. Figure out what's next, because I have no idea!

## Application Config
```elixir
config :infuse,
    web_root: "example-www",
    default_content_type: "text/html",
    start_server: true,
    start_observer: false

config :infuse, Infuse.HTTP.RequestHandler,
    default_indicies: ['index.html', 'index.json', 'index',
                        'index.html.spt', 'index.json.spt', 'index.spt']
```

## Docker for Development
Since I develop on Windows I find it sometimes helpful to test on linux, so I use:

```
docker build -t infuse .
docker run -p 8101:8101 infuse
```


## Credits & License
[LICENSE](LICENSE.md)

Entire inspiration and design is from [https://github.com/AspenWeb/aspen.py](https://github.com/AspenWeb/aspen.py) 

Logo was made from [https://pixabay.com/p-146337/?no_redirect](https://pixabay.com/p-146337/?no_redirect). I cut out the jar top and the other jar to form the logo.