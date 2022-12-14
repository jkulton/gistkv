<img src="gistkv.png" width=100 height=100 />

# GistKV

[![Gem Version](https://badge.fury.io/rb/gistkv.svg)](https://badge.fury.io/rb/gistkv)

Use GitHub gists as simple key-value databases

## What is this for?

- Simple **non-sensitive**[^1] datastore for scripts, crons, or CLI tools
- MVP database for prototyping

## Installation

```
gem install gistkv
```

## Create a database

Use `GistKV::Client.create_database` to create a new GistKV database. The method requires passing a valid GitHub token with access to the `gist` scope.

```rb
require 'gistkv'

# returns id of created gist
GistKV::Client.create_database(ENV['GITHUB_TOKEN'])
# => f9ba626808266b93b7631aeb8321dbcf
```

Take note of the id returned from `create_database` when called, it should be saved for future use. This is the id of your database.

## Use a database

Use `GistKV::Client.new` to create a GistKV client. This method requires passing the id of a GistKV gist and a valid GitHub token with access to the `gist` scope.

```rb
require 'gistkv'

g = GistKV::Client.new(ENV['GIST_ID'], ENV['GITHUB_TOKEN'])

# set a value
g.set("score", 10)

# get a value
g.get("score")
# => 10

# alias for .get
g["score"]
# => 10

# alias for .set
g["days"] = ["Friday", "Saturday", "Sunday"]

g.get("days")
# => ["Friday", "Saturday", "Sunday"]

# get list of keys
g.keys
# => ["score", "days"]

# update multiple keys at once
g.update(score: 11, days: ["Saturday"])
```
The above example code resulted in [this gist](https://gist.github.com/jkulton/67df2395daa634c6f4c3a783847324be).

It's also possible to create a read-only `GistKV::Client` by omitting the GitHub access token on creation. Please note this client will be subject to the GitHub API's public rate limits. [See docs for more info](https://docs.github.com/en/rest).

## How it works

- GistKV creates a single `__gistkv.json` file in a gist.
- On each `.get` or `.set` the gist's JSON is retrieved from the GitHub API, manipulated, and then written back to the gist.
  - As a result, you may experience unexpected results if multiple client instances are reading/writing the same gist at once.

## Footnotes

[^1]: ?????? **Don't use GistKV to store sensitive data. Gists, even when set to secret, are not private.** ??????
