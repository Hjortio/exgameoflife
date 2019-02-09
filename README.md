# ExGameOfLife

This is a very basic implementation of [conway's game of life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) in elixir using the "new" library Scenic.

## Usage

Make sure you have elixir and [scenic](https://github.com/boydm/scenic_new) installed.
To run the app clone this repository then cd into it and type:

```
mix deps.get
mix scenic.run
```
When you see an empty screen press enter to spawn cells. If everything is fine it should look something like this:

![gif demonstration](priv/img/scenic.gif "Game of life")

## TODO

This implementation is very slow, i am probably going to fix this in the future. Currently i'm looking at two things i think will speed it up:

1. Make proper use of elixirs concurrency.
2. Change the list of cells to a MapSet.


