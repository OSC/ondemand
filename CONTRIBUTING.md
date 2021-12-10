# Contributing

First off - Thank you for your interest in contributing to the Open OnDemand project!

There is no pull request too small! Everything from simple misspellings to very
large feature requests are welcome.  If you're not quite sure where to get started
you can search our list of [good first issues].

Please note we have a [code of conduct], please follow it in all your
interactions with the project.

## Issues

Issues, bug reports, questions and feature requests are always welcome.  Feel
free to open an issue and use any [issue labels] as appropriate.

We mostly use [Discourse] for general questions or help.  If you're unsure
of where to route your question, Discourse may be the best forum for it.

## Other Repositories

There are other repositories to Open OnDemand that are important as well.  You may want to check
these out too.

* [repository for the Open OnDemand website](https://github.com/OSC/openondemand.org)
* [repository for the Open OnDemand documentation](https://github.com/OSC/ood-documentation)
* [repository for the Open OnDemand core library](https://github.com/OSC/ood_core)

## Pull Request Process

If you have a large feature it may be preferential to open an issue and discuss
it first before putting a lot of work into coding something that may not be accepted. Don't
let this discourage you though! Feel free to open tickets and engage with the development
team on proposed changes.

1.  [Fork this repo].
2.  Branch off of the master branch.
3.  Now create a pull request to this repository!  At this point a maintainer will be notified
    and will start reviwing it.
4.  If changes are being requested, don't let this discourage you! This is a
    natural part of getting changes right and ensuring quality in what we're building.

## Project StyleGuide

### Linters

For any Ruby librares/apps there is a `.rubocop.yml` at the top of this project. If you
work in IDEs where you want to only open a part of this project, executing `rake lint:setup`
and it will copy copy lint config files to various locations. Watch out though, `rake clean`
will remove them!

### Ruby Style

In addition to the [RuboCop] styles configured described above, we follow common Ruby style
and idioms. For example `snake_case` methods and variable names and favoring functional style
methods.

### JavaScript Style

Beyond the [ESLint] configuration files, we follow these styles:

* File names use underscores, `_`, for word seperators.
* Variables are `camelCase` named and are `const` or `let`. Using `var` is discouraged.
* Function names are `camelCase`.

### Html Style

In general, when making html elements (or Ruby/Js/Etc models of)
we'll follow this style.

* IDs use underscores `_` for word seperation. This follows the Rails `form_for` convention.

[Discourse]: https://discourse.osc.edu
[yardoc]: https://yardoc.org/
[Fork this repo]: https://help.github.com/articles/fork-a-repo/
[code of conduct]: CODE_OF_CONDUCT.md
[issue labels]: https://github.com/OSC/ondemand/labels
[good first issues]: https://github.com/OSC/ondemand/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22+
[RuboCop]: https://docs.rubocop.org/
[ESLint]: https://eslint.org/
