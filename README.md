# GistKV

[![Gem Version](https://badge.fury.io/rb/gistkv.svg)](https://badge.fury.io/rb/gistkv)

Use GitHub gists as simple key/value databases

## Installation

```
gem install gistkv
```

## Create a database

Use `GistKV::Client.create_database` to create a new GistKV database. The method requires passing a valid GitHub token with access to the `gist` scope.

```rb
require 'gistkv'

GistKV::Client.create_database(ENV['GITHUB_TOKEN']) # returns id of created gist
# => f9ba626808266b93b7631aeb8321dbcf
```

Take note of the id returned from `create_database` when called, it should be saved for future use. This is the id of your database.

## Use a database

Use `GistKV::Client.new` to create a GistKV client. This method requires passing the id of a GistKV gist and a valid GitHub token with access to the `gist` scope.

```rb
require 'gistkv'

g = GistKV::Client.new(ENV['GIST_ID'], ENV['GITHUB_TOKEN'])

g.set("score", 10)
g.get("score")
# => 10

g["score"] # alias for .get
# => 10

g["days"] = ["Friday", "Saturday", "Sunday"] # alias for .set
g.get("days")
# => ["Friday", "Saturday", "Sunday"]

g.keys
# => ["score", "days"]

g.update(score: 11, days: ["Saturday"]) # update multiple keys at once
```

## Important Details

- Gists are not private, even when set to secret. ⚠️ **Don't use GistKV to store sensitive data.**
- Gists don't lock on reads or writes. Each get/set operation issues a request to the GitHub API. You may experience unexpected results if multiple client instances are reading/writing the same gist at once.
