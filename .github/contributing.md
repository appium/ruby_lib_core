# Contributing

For features or bug fixes, please submit a pull request. Ideally there would be a test as well. The remainder of this doc details how to run the tests.

## Tests
### Unit Tests
- `rake test:unit` run on Travis automatically

### Functional Tests
- iOS
    - `rake test:func:ios`
- Android
    - `rake test:func:android`

## Merge
- Squash and merge when we merge PRs to the master

## Publishing on rubygems

0. Ensure you have `~/.gem/credentials` If not run [the following command](http://guides.rubygems.org/make-your-own-gem/) (replace username with your rubygems user)
> $ curl -u username https://rubygems.org/api/v1/api_key.yaml >
~/.gem/credentials; chmod 0600 ~/.gem/credentials

1. Bump the version number `thor bump`
2. Generate release note, build and publish gem with `thor release`
3. Update `changelog.md`
