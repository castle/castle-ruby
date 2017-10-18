Releasing
=========

1. Update `VERSION` in `lib/castle/version.rb` to the new version
2. Update the `HISTORY.md` for the impending release
3. `git commit -am "Prepare for release X.Y.Z."` (where X.Y.Z is the new version)
4. `git tag -a X.Y.Z -m "Version X.Y.Z"` (where X.Y.Z is the new version)
5. `gem build castle-rb.gemspec`
