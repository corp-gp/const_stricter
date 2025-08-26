# const_stricter

The `const_stricter` is a Ruby library designed to identify unused code by analyzing constant dependencies in your project. There are two approaches to achieve this:

- **Runtime Tracking**: This method logs calls to classes and modules during runtime. While this approach provides reliable dependency map, it introduces runtime overhead and cannot detect references to undefined constants until the code is deployed to production.
- **Static Code Parsing**: This approach parses source files to identify constant usage. Although less precise in cases involving dynamically generated constant names, it allows you to detect errors and unused code before deployment, improving code quality early in the development cycle.

Gem `const_stricter` uses **Static Code Parsing** via [prism](https://github.com/ruby/prism) to help developers maintain cleaner codebases by identifying and removing unused constants efficiently.

## Installation

Install the gem and add to the application's Gemfile by executing:
```bash
bundle add const_stricter --group "development"
```

If bundler is not being used to manage dependencies, install the gem by executing:
```bash
gem install const_stricter
```

## Usage

Run rake task from the root folder of your application:
```bash
rake const_stricter:lint
```

As a result, you'll see something like following:
```ruby
# Dynamic constants                                                            
LegalEntities::SupplierSubmit::Form { Values()::USER_ID }
Markets::Products::Controller { connection.module::Services::UpdatePrices }

# Missed constants                                                             
StaticPages::Forms::Component { FormComponent }
ProductShape { Product::USER_AVAILABILITY::PREORDER }
```

The section with `Dynamic constants` shows strings that can only be calculated in runtime.

The pseudo-code in `Missed constants` means that the constant `FormComponent` is missing (can't be evaluated) in context of `StaticPages::Forms::Component`.

You can specify which files need to be checked by setting the `glob` parameter in the rake task (`{app,lib}/**/*.rb` by default):
```bash
rake const_stricter:lint[lib/*.rb]
```

## Limitations

The `const_stricter` can't find constants whose names are set using meta-programming. Examples [in tests](spec/const_stricter/dynamic_spec.rb)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/corp-gp/const_stricter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/corp-gp/const_stricter/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the `const_stricter` project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/corp-gp/const_stricter/blob/master/CODE_OF_CONDUCT.md).
