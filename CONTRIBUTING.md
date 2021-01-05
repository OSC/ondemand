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

1. [Fork this repo].
2. Branch off of the master branch.
3. Create a PR to merge into the master upstream branch.  Make sure at least
  unit tests continue to pass by executing `rake test`.
4. We will review it and either add comments for requested changes or merge.
  If changes are being requested, don't let this discourage you! This is a
  natural part of getting changes right and ensuring quality in what we're building.

### Tips

1. Contributions accompanied by unit tests are recommended.
2. For Ruby code we add [yarndoc] comments above all of our public interface methods as this is used to generate helpful documentation on http://www.rubydoc.info/. We do not yet have adopted a strong style guide for code in JavaScript and Python.
3. With the PR for the change, add to the CHANGELOG a line under the "Unreleased" section specifying https://keepachangelog.com/en/1.0.0/.
4. Follow best conventions with Ruby coding style. We haven't yet adopted a strict style guide, so unless you are using tabs or 4 spaces instead of 2 spaces you will probably not find an objection from us.


[Discourse]: https://discourse.osc.edu
[yardoc]: https://yardoc.org/
[Fork this repo]: https://help.github.com/articles/fork-a-repo/
[code of conduct]: CODE_OF_CONDUCT.md
[issue labels]: https://github.com/OSC/ondemand/labels
[good first issues]: https://github.com/OSC/ondemand/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22+