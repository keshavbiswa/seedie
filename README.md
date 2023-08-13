# Seedie

Seedie is a Ruby gem designed to streamline the seeding of your database.
Utilizing the Faker library, Seedie generates realistic data for ActiveRecord models.
Currently supports only PostrgreSQL and SQLite3 databases.
The gem includes a Rake task for seeding models and a Rails generator for easy setup.

[![Gem Version](https://badge.fury.io/rb/seedie.svg)](https://badge.fury.io/rb/seedie)
![Build Status](https://github.com/keshavbiswa/seedie/workflows/CI/badge.svg?branch=main)

## Installation

Add the following line to your application's Gemfile:

```bash
gem 'seedie'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install seedie
```
Next, run the install generator:

```bash
$ rails generate seedie:install
```
This will create a seedie.yml file in your config directory, which will include configurations for your models.

## Usage

To seed your models, run the following Rake task:

```bash
$ rake seedie:seed
```

This will use the configurations specified in seedie.yml to seed your models.

The seedie.yml file has entries for each model in your application, and you can customize the configuration for each one. 

Here's an example of a more advanced configuration in seedie.yml:


```yaml
default_count: 5
models:
  user:
    attributes:
      name: "name {{index}}"
      email: "{{Faker::Internet.email}}"
      address: "{{Faker::Address.street_address}}"
    disabled_fields: [nickname password password_digest]
  post:
    count: 2
    attributes:
      title: "title {{index}}"
      category:
        values: [tech, sports, politics, entertainment]
        options: 
          pick_strategy: random # or sequential
    associations:
      has_many:
        comments: 4
      belongs_to:
        user: random # or new
      has_one:
        post_metadatum: 
          attributes:
            seo_text: "{{Faker::Lorem.paragraph}}"
    disabled_fields: []
  comment:
    attributes:
      title: "title {{index}}"
    associations:
      belongs_to:
        post:
          attributes:
            title: "Comment Post {{index}}"

```

In this file:

- `default_count` specifies the number of records to be generated for each model when no specific count is provided in the model's configuration.
- `models` is a hash that contains a configuration for each model that should be seeded.
- `attributes` is a hash that maps field names to the values that should be used. If attributes are not defined, Seedie will use Faker to generate a value for the field.
  - The special `{{index}}` placeholder will be replaced by the index of the current record being created, starting from 1. This allows you to have unique values for each record.
  - Additionally, we can use placeholders like `{{Faker::Internet.email}}` to generate dynamic and unique data for each record using Faker.
  - We can also specify an array of values that can be picked from randomly or sequentially using the `values` and `pick_strategy` options.
- `disabled_fields` is an array of fields that should not be automatically filled by Seedie.
- `associations` specify how associated models should be generated. Here, `has_many`, `belongs_to`, and `has_one` are supported.
- The specified number for `has_many` represents the number of associated records to create.
- For `belongs_to`, the value `random` means that a random existing record will be associated.
- If attributes are specified under an association, those attributes will be used when creating the associated record(s)
- When using associations, it's important to define the models in the correct order in the `seedie.yml` file. Associated models should be defined before the models that reference them.

## Development

After checking out the repo, run `bin/setup` to install dependencies. 
Then, run `bundle exec rspec` to run the tests.
By default, the tests will supress output of the seeds progress.
Use `DEBUG_OUTPUT=true bundle exec rspec` to see the output of the seeds.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/keshavbiswa/seedie.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
