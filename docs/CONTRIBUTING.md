# Contributing

When contributing to this project, please first discuss the change you wish
to make via issue, email, or any other method with the owners of this
repository before making a change.

Please note we have a [code of conduct](CODE_OF_CONDUCT.md), please follow it in all your
interactions with the project.

## Pull Request Process

1. [Fork the repo](https://help.github.com/articles/fork-a-repo/) of the component or library you want to modify.
2. Branch off of the master branch (see exceptions below) and apply fix.
3. Create a PR to merge into the master upstream branch.
4. We will review it and either add comments for requested changes or merge.

### Exceptions

1. When making proposed changes to the [Open OnDemand website](https://osc.github.io/Open-OnDemand/), please branch off of the [gh-pages branch](https://github.com/OSC/Open-OnDemand/tree/gh-pages).
2. When making proposed changes to the [Open OnDemand documentation](https://github.com/OSC/ood-documentation), please branch off of the develop branch (this is the default branch on the repo).

### Tips

1. Contributions accompanied by unit tests are recommended.
2. For Ruby code we add [yardoc](https://yardoc.org/) comments above all of our public interface methods as this is used to generate helpful documentation on http://www.rubydoc.info/. We do not yet have adopted a strong style guide for code in JavaScript and Python.
3. With the PR for the change, add to the CHANGELOG a line under the "Unreleased" section specifying https://keepachangelog.com/en/1.0.0/.
4. Follow best conventions with Ruby coding style. We haven't yet adopted a strict style guide, so unless you are using tabs or 4 spaces instead of 2 spaces you will probably not find an objection from us.