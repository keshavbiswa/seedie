# Seedie

Seedie is a Ruby gem designed to make it easy to seed your database with realistic data.
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

Alternatively, you can also create a blank seedie.yml file by running:

```bash
$ rails generate seedie:install --blank
```

This will generate a blank seedie.yml config file for you that you can now customize according to your needs.

## Usage

### Generating blank seedie.yml
If you want to create a blank seedie.yml file, use the `--blank` option:

```bash
$ rails generate seedie:install --blank
```

This will generate a blank seedie.yml config file for you that you can now customize according to your needs.

### Excluding Models
If you want to exclude certain models while generating the `seedie.yml`, use the `--exclude_models` option:

```bash
$ rails generate seedie:install --exclude_models User Admin Post
```

NOTE: Some models may not be excluded because of their dependencies. For example, if you have a model `Post` that belongs to a model `User`, then the `User` model will not be excluded even if you specify it in the `--exclude_models` option.

You'll get a warning in your console if any models are not excluded:

```bash
WARNING: User has dependencies with other models and cannot be excluded.
```

### Including only few Models
If you want to include only few particular models while generating the `seedie.yml`, use the `--include_only_models` option:

```bash
$ rails generate seedie:install --include_only_models Post Comment
```

NOTE: Some models may be a dependency for the required models and will need to be included for successful seeding. For example, if you have a model `Post` that belongs to a model `User`, then the `User` model will need to be included even if you didn't specify it in the `--include_only_models` option.

You'll get a warning in your console if any other models are included:

```bash
WARNING: User is a dependency of included models and needs to be included.
```

### Add Custom Attributes inside seedie.rb initializer

While generating the seedie.yml file, there are default values.
For example, for every `string` field, the default value is `{{Faker::Lorem.word}}`.
This works fine for most attributes, but for some there are validations which breaks the seeding.
Take `email` as an example, the default value `{{Faker::Lorem.word}}` will not be a valid email.
By default, when we generate the seedie.yml file, we add a `seedie.rb` initializer file in the `config/initializers` directory.

```ruby
Seedie.configure do |config|
  # config.default_count = 10

  config.custom_attributes[:email] = "{{Faker::Internet.unique.email}}"
  # Add more custom attributes here
end
```

This ensures that the `email` field is seeded with a valid email address.
You can add more custom attributes in the `seedie.rb` initializer file.

### Seeding Models

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
      has_and_belongs_to_many:
        tags:
          count: 3
          attributes:
            name: "{{Faker::Lorem.word}}"
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
- `associations` specify how associated models should be generated. Here, `has_many`, `belongs_to`, `has_one` and `has_and_belongs_to_many` are supported.
- The specified number for `has_many` represents the number of associated records to create.
- For `belongs_to`, the value `random` means that a random existing record will be associated. If there is a unique index associated, then `unique` will be set or else `random` is the default.
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
