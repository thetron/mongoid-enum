# Mongoid::Enum

Heavily inspired by DHH's ActiveRecord::Enum, this little library is
just there to help you cut down the cruft in your models and make the
world a happier place at the same time.

A single line will get you fields, accessors, validations and scopes,
and a few other bits-and-bobs.


# Installation

Add this to your Gemfile:

    gem "mongoid-enum"

And then run `bundle install`.


# Usage

````
class Payment
  include Mongoid::Document
  include Mongoid::Enum

  enum :status, [:pending, :approved, :declined], 
end
````


# Options

## Default value

If not specified, the default will be the first in your list of values
(`:pending` in the example above). You can override this with the
`:default` option:

    enum :roles, [:manager, :administrator], :default => ""


## Multiple values

Sometimes you'll need to store multiple values from your list, this
couldn't be easier:

    enum, :roles => [:basic, :manager, :administrator], :multiple => true

    user = User.create
    user.roles << :basic
    user.roles << :manager
    user.save!

    user.manager? # => true
    user.administrator? # => false
    user.roles # => [:basic, :manager]


## Validations

Validations are baked in by default, and ensure that the value(s) set in
your field are always from your list of options. If you need more
complex validations, or you just want to throw caution to the wind, you
can turn them off:

    enum :status => [:up, :down], :validation => false
