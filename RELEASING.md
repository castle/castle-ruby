# Releasing

1. Create branch `X.Y.Z` from develop.
2. Update `VERSION` in `lib/castle/version.rb` to the new version
3. Run `bundle`
4. Update the `CHANGELOG.md` for the impending release
5. `git commit -am "release X.Y.Z."` (where X.Y.Z is the new version)
6. Push to Github, make PR to the develop branch, and when approved, merge.
7. Pull latest `develop`, merge it to `master`, and push it.
8. Make a release on Github from the `master` branch, specify tag as `vX.Y.Z` to create a tag.
9. `git checkout master && git pull`
10. `gem build castle-rb.gemspec`
11. `gem push castle-rb-X.Y.Z.gem`
