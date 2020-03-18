Releasing
=========

1. Create branch `X.Y.Z`.
2. Update `VERSION` in `lib/castle/version.rb` to the new version
3. Run `bundle`
4. Update the `CHANGELOG.md` for the impending release
5. `git commit -am "release X.Y.Z."` (where X.Y.Z is the new version)
6. Push to Github, make PR, and when ok, merge.
7. Make a release on Github, specify tag as `vX.Y.Z` to create a tag.
8. `git checkout master && git pull`
9. `gem build castle-rb.gemspec`
10. `gem push castle-rb-X.Y.Z.gem`
