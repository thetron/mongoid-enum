# Mongoid::Enum

Heavily inspired by DHH's ActiveRecord::Enum, this little library is
really just a good tablespoon of syntactik sugar.


# Usage

class Payment

  enum :status, [:pending, :approved, :declined], 

end

* Stores as `_status`, accessible from `status` and `status=`.
* Automatically validates against `:options`
* Stored as a string, but always expressed as a symbol. Access is
indifferent (or masks said behaviour

# Options

:multiple

Changes storage to `_status_array`, and allows for the storage of
multiple options.

Should also include some finders!

Payment.declined, etc..
