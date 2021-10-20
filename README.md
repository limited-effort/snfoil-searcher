# Snfoil::Searcher

![build](https://github.com/limited-effort/snfoil-searcher/actions/workflows/main.yml/badge.svg) [![maintainability](https://api.codeclimate.com/v1/badges/a05646d2c1e6e986de89/maintainability)](https://codeclimate.com/github/limited-effort/snfoil-searcher/maintainability)

SnFoil Searchers allow you to break complex searching functionality into small easily testable sections.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'snfoil-searcher'
```

## Usage

### Quickstart

Here is a quick example of how you would use a SnFoil Searcher with Active Record.

```ruby 
# lib/searchers/people_searcher
class PeopleSearcher
  include SnFoil::Searcher

  model Person

  filter do |scope, params|
    scope.where('first_name ilike ?', params[:query])
  end
end
```

and call it like so

```ruby
PeopleSearcher.new.search(query: 'alf')
```

### Getting a Searcher Configured

#### Include
This one is pretty simple - to add the functionality to your searcher class, you need to include it.  

Like so:

```ruby
class PeopleSearcher
  include SnFoil::Searcher

  ...
end
```

#### Scoping
You can provide an initial scope to the searcher by passing it to `new`.  If you don't pass in an initial scope, the searcher will try to use the model.

```ruby
PeopleSearcher.new(People.where(team_id: 2))
```

#### Model

Model is an optional parameter you can set on the searcher class.  If a model is defined - and there is no default scope provided when initializing the searcher - it will default to using `model.all`

```ruby 
class PeopleSearcher
  include SnFoil::Searcher

  model Person
end
```

#### Filter

A filter is a step in the search process that takes the current scope and parameters and returns an altered scope.  We recommend keeping each filter as simple as possible - it should only have one responsibility.  This way you can easily see every step the searcher takes to get to its outcome as well as defining behaviors that should be tested.

You can create as many filters as you would like, but it is important to remember that a filter should **always** return a scope.

```ruby 
class PeopleSearch
  ...

  # query by first_name
  filter do |scope, params|
    scope.where('first_name ilike ?', params[:query])
  end

  # filter to age demographic
  filter do |scope, _params|
    scope.where('age >= 18').where('age <= 34')
  end
end
```

##### Conditional Filters

You probably don't want a filter to always run.  You can set `if` and `unless` procs to check whether or not the filter should run.

```ruby 
class PeopleSearcher
  ...

  # query by first_name
  filter(if: ->(params) { params[:query].present? }) do |scope, params|
    scope.where('first_name ilike ?', params[:query])
  end
end
```

#### Setup
Setup is just a filter that runs first - before any other filters.  It does not allow for conditionals.  We recommend using this block to setup any requirements, tenant scoping, or stuff that just needs to happen first. 

```ruby 
class PeopleSearcher
  ...

  setup do |scope, params|
    scope.where(client_id: 1)
  end

  filter do |scope, params|
    ...
  end
end
```

#### Casting Booleans

To help with casting boolean params - especially those coming from http params - we've added explicit boolean casting for params.  There are parsed and cast in place before any filter.  Just pass in an array of the params you would like to have cast.

```ruby

PeopleSearcher.new.search(red: 'true', blue: 'true', green: nil)

class PeopleSearcher
  booleans :red, :green

  ...

  filter do |scope, params|
    # params => { red: true, blue: 'true', green: false }
    ...
  end
end
```

### PORO

Although our examples so far have used Active Record, you can use SnFoil Searchers with any dataset you need to filter.

```ruby
class FruitSearcher
  include SnFoil::Searcher

  # always filter out unavailable
  setup do |scope, _params|
    scope.select { |x| x[:available] }
  end

  filter(unless: ->(params) { params[:type].nil? || params[:type].empty? }) do |scope, params|
    scope.select { |x| x[:type] == params[:type] }
  end

  filter(unless: ->(params) { params[:color].nil? || params[:color].empty? }) do |scope, params|
    scope.select { |x| x[:color] == params[:color] }
  end
end

fruits = [
  { name: 'Apple', color: 'red', type: 'pome', available: true },
  { name: 'Rowan', color: 'red', type: 'pome', available: false },
  { name: 'Pear', color: 'green', type: 'pome', available: true },
  { name: 'Grape', color: 'red', type: 'berry', available: true  }
]

FruitSearcher.new(fruits).search( type:'pome')
  #=> [{ name: 'Apple', color: 'red', type: 'pome', available: true }, { name: 'Pear', color: 'green', type: 'pome', available: true }]
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/limited-effort/snfoil-searcher. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/limited-effort/snfoil-searcher/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [Apache 2 License](https://opensource.org/licenses/Apache-2.0).

## Code of Conduct

Everyone interacting in the Snfoil::Policy project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [code of conduct](https://github.com/limited-effort/snfoil-searcher/blob/main/CODE_OF_CONDUCT.md).
