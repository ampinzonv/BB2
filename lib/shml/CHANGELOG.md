## [1.0.4] - 2015-11-16 (Sewed Up)

#### Added
- Better Source Detect (PR #15)
- `package.json` for NPM
- Broke tests out in to their own files (PR #19)
 - `112` new tests, `137` in total (PR #26)
- `VERSION` (PR #27 & #28)

#### Updated
- `Makefile`
 - `bump` (version bumper)
 - `publish` (NPM Publish)
 - `install` (shml binary)
 - `remove` (shml binary)
- Documentation
 - `index.md`
 - `install.md`

#### Removed
- Entity mentions (PR #20)


## [1.0.3] - 2015-11-07 (Almost Famous)

#### Added
- `docs/`
- `.travis.yml` (PR #18) & badge to `README.md`
- New Makefile commands: `docs-serve`, `docs-build` & `docs-deploy`

#### Removed
- 2 invalid tests: `$(indent 2)`, `$(i 2)`

#### Updated
- Documentation (minor config issues, bug fixes, mixed content errors)

## [1.0.2] - 2015-10-11

#### Fixed
- `.gitignore`
- Version Bump on Documentation/Chagelog/Readme

## [1.0.1] - 2015-10-09

#### Removed
- Bullet Entity reference ([Reported on Reddit](https://www.reddit.com/r/bash/comments/3nps8x/shml_shell_markup_language/cvr3gm2))

## [1.0.0] - 2015-10-05

#### Added
- Emojis
- New method shortcuts (`fgc`, `bgc`, `e`, `color`, `background`)
- [Changlelog.md](http://keepachangelog.com/)
- CONTRIBUTING.md

#### Changed
- Foreground method name to `fgcolor`
- Background method name to `bgcolor`
- README.md

#### Fixed
- Fix typos in recent README changes.

#### Removed
- Function prefixes
- Entity Support (for now)
- Obsolete files
- EXAMPLES.md

## [beta] - 2013-11-01
- Merge pull request #14 from jimaek/master
- Merge pull request #13 from trumbitta/patch-1
- Merge pull request #12 from odb/develop
- Merge pull request #11 from odb/jdorfman
- Fixed the icons
- Fixing declare
- typo: add a missing e in Enhancement
- Fixing help misspelling.
- bash style updates
- Tweaking attributes, including changing italic to underline.
- Removing -e from the examples, as it's not required.
- Fixing br and tab so that echo -e isn't required.
- Adding entity support.
- Fixing x vs. <3 and refactoring icons a bit.
- Update year to match in every README example.
- Writes dates in a strange way.
- Replaced icons with unicode
