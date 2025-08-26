# Constrictor

There are two approaches to finding unused code. In the first approach, calls to all classes/modules are logged in runtime, thus collecting usage statistics. This allows you to collect the most reliable dependency map. However, this approach has drawbacks: additional workload due to runtime tracking and the inability to find calls to non-existent constants before code is deployed to production. 

The second approach involves parsing the ruby-files of the project. In this case, the quality of dependency search is reduced (when using dynamic generation of constant names). But at the same time, it becomes possible to fix errors in the code even before the application is deployed. The `Constrictor` implements constant checking by parsing the project code using [prism](https://github.com/ruby/prism)

## Installation

Install the gem and add to the application's Gemfile by executing:
```bash
bundle add constrictor --group "development"
```

If bundler is not being used to manage dependencies, install the gem by executing:
```bash
gem install constrictor
```

## Usage

Run rake task from the root folder of your application:
```bash
rake constrictor:lint
```

As a result, you'll see something like following:
```
Dynamic constants                                                            
LegalEntities::SupplierSubmit::Form { Values()::USER_ID }
Markets::Products::Controller { connection.module::Services::UpdatePrices }

Missed constants                                                             
StaticPages::Forms::Component { FormComponent }
ProductShape { Product::USER_AVAILABILITY::PREORDER }
```

The section with `Dynamic constants` shows strings that can only be calculated in runtime.

The pseudo-code in `Missed constants` means that the constant `FormComponent` is missing (can't be evaluated) in context of `StaticPages::Forms::Component`.

You can specify which files need to be checked by setting the `glob` parameter in the rake task (`{app,lib}/**/*.rb` by default):
```bash
rake constrictor:lint[lib/*.rb]
```

## Limitations

The `Constrictor` can't find constants whose names are set using meta-programming. Examples [in tests](spec/constrictor/dynamic_spec.rb)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/constrictor. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/constrictor/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Constrictor project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/constrictor/blob/master/CODE_OF_CONDUCT.md).
