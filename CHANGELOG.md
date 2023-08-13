## Version 0.3.0

### New Features

#### Polymorphic Association
* [GitHub PR](https://github.com/keshavbiswa/seedie/pull/12)
  
  You can now add a polymorphic association to your seedie.yml file:
  
  ```yaml
  belongs_to:
    commentable:
      polymorphic: post # or [post, article] for multiple options
      strategy: random
  ```

#### Automatic Polymorphic Association Generator
* [GitHub PR](https://github.com/keshavbiswa/seedie/pull/13)

  When you run `rails g seedie:install`, it'll also generate the necessary polymorphic associations.

#### Custom Value Attributes with Validations
* [GitHub PR](https://github.com/keshavbiswa/seedie/pull/14)

  Replaced custom_attr_value with a simplified value key:

  Before:
  ```yaml
  some_attribute:
    custom_attr_value:
      values: [1,2,3]
      pick_strategy: random
  ```

  After:
  ```yaml
  some_attribute:
    values: [1,2,3] # or value (in which case pick_strategy is not required)
    options:
      pick_strategy: random
  ```

#### Custom Value Generator

* [GitHub PR](https://github.com/keshavbiswa/seedie/pull/17)
  
  Upon invoking `rails g seedie:install`, the generator will also add custom values.

#### Inclusion of Non-polymorphic _type Columns
* [Github PR](https://github.com/keshavbiswa/seedie/pull/18)

  Earlier, columns with `_type` were skipped during seedie.yml generation, causing some attributes to be overlooked.

  ```ruby
  class User < ApplicationRecord
    enum role_type: { admin: 0, user: 1 }
  end
  ```

  We've resolved this, now only columns related to polymorphic foreign_types are excluded.

#### Range Inclusions
* [Github PR](https://github.com/keshavbiswa/seedie/pull/19)

  Define ranges using the start and end keys:

  ```yaml
  score:
    values: 
      start: 0
      end: 100
    options: { pick_strategy: sequential }
  ```

  This configuration will generate sequential numbers between 0 and 100.
