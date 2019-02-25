# An Elixir Development Environment POC

## Why?
I write a good amount of Elixir.
I want to leverage its speed and tool suite to optimize my ability to work on elixir systems.

## Requirements

1. A text editor. I like `vim`
2. A shell, I like `zsh`
3. Elixir

I also prefer to use `syntastic` - which works with Vim to ensure your code is valid.
This is not a hard-requirement, but I find it nice.

This works on OSX and Linux.

We have two core dependencies, `mix_test_watch` and `observer_cli`.
We leverage its file system monitor and `mix test.watch` task for the core of our flow.

## Running Things
We will have 4 shells running.
I split with iTerm2 currently, I should use tmux.

In one shell: your editor

In another: `iex -S mix` - this will be live-reloading your new code upon any changes with our new additions

In another: `mix test.watch` - tests run on any change, can be configured to be per file or module not whole suite

In another: `:observer_cli.start()` - A CLI observer interface to view the system

Now we have a guarantee that all code is always loaded, the system runs tests whenever it changes, and we can inspect the state of things with our observer.

Any change we make is live and shoved in.

![screen](https://i.imgur.com/JLURq2T.jpg)
