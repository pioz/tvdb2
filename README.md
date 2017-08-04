# TVDB2 API for Ruby

Ruby wrapper for TVDB json api version 2.

The TVDB api version 2 documentation [can be found here](https://api.thetvdb.com/swagger).


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tvdb2'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tvdb2


## Usage

First of all you need to get your API key:

* Register an account on http://thetvdb.com/?tab=register
* When you are logged register an api key on http://thetvdb.com/?tab=apiregister
* View your api keys on http://thetvdb.com/?tab=userinfo

```
require 'tvdb2'

# Create a client object with your api key
client = TVDB.new(apikey: 'YOUR_API_KEY', language: 'en')

# Search series by name
results = client.search(name: 'Game of Thrones')
puts results.map(&:name).inspect
# Get best series result by name
got = best_result = client.best_search('Game of Thrones')
puts got.name

# Get list of actors
actors = got.actors
puts actors.first.name
puts actors.first.role
puts actors.first.image_url

# Print some info about all episodes
got.episodes.each do |episode|
  puts episode.x
  puts episode.absoluteNumber
  puts episode.seasonNumber
  puts episode.number
  puts episode.overview
end
# Get only episodes from 101 and 200
episodes = got.episodes(page: 2)
# Get all episodes of season 1
episodes = got.episodes(airedSeason: 1)
# Get episode by index
puts got[3].name
# Get episode by x syntax (SEASON_NUMBERxEPISODE_NUMBER)
ep = got['3x9']
puts ep.name
puts ep.x # print '3x9'

# Get banner
url = got.banner_url
# Get random banner
url = got.banner_url(random: true)
# Get poster
url = got.poster_url
# Get random poster
url = got.poster_url(random: true)
# Get all posters
posters = got.posters
puts posters.first.url
# or
posters = got.images(keyType: 'poster')
# Get all season images
images = got.season_images
puts images.first.url
# Get all season images of season 2
images = got.season_images(season: 2)
puts images.first.url

# Switch language
client.language = 'it'
ep = got['3x9'] # retrieve the episodes with the new language
puts ep.name
client.language = 'en'
# or you can swith language only in a block
client.with_language(:it) do
  ep = got['3x9']
  puts ep.name
end
```

The complete __documentation__ can be found [here](htttps://pioz.github.io/tvdb2).


## Missing REST endpoints

This wrapper do not coverage all 100% api REST endpoints.
Missing methods are:

* __Series__
    * filter: `GET /series/{id}/filter`
* __Updates__
    * updadad: `GET /updated/query`
* __Users__
    * user: `GET /user`
    * favorites: `GET /user/favorites`
    * delete favorites: `DELETE /user/favorites/{id}`
    * add favorites: `PUT /user/favorites/{id}`
    * ratings: `GET /user/ratings`
    * ratings with query: `GET /user/ratings/query`
    * delete rating: `DELETE /user/ratings/{itemType}/{itemId}`
    * add rating: `PUT /user/ratings/{itemType}/{itemId}/{itemRating}`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pioz/tvdb2.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
