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

## Branches and Tags

All development work happens in the `master` branch.

Once the software reaches a state the maintainers feel is good enough to release,
they tag the `v<version>` tag from the `master` branch. At this time, on the same
commit as the tag, a `release_<version>` branch is made.

Once the release branch is made maintainers will need to backport any bugfixes
to the release branch for that version. They will also make tag off of the release
branch for patch releases of that version.

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

## Branch Naming and Issue Tagging

### Adding a feature

```git
git checkout -b feature/<short-name>-<issue#>
```

### Fixing a bug

```git
git checkout -b bug-fix/<short-name>-<issue#>
```

## Tagging your issue

A best guess is encouraged.

All new issues are reviewed weekly by the OOD team to categorize correctly regardless.

## Pull Request Comments

Ensure to include what issue this fixes in the **PR comment** to help with automated issue closing:

* "fixes #1234"

## Project StyleGuide

* **Any new code *must* also include testing.**
* If you need help with writing tests please include the `test help` tag.

### Project Conventions

* Prefer **read-only** objects.  You'll find mostly read only objects spread throughout this code base.
  This means that `attr_writer` or `attr_accessor` are to be avoided and only `attr_reader` should be used.
  It follows then, that most objects should accept a large number of parameters in their initializers
  and set the attributes accordingly.

### Linters

For any Ruby librares/apps there is a `.rubocop.yml` at the top of this project. If you
work in IDEs where you want to only open a part of this project, executing `rake lint:setup`
and it will copy copy lint config files to various locations. Watch out though, `rake clean`
will remove them!

### Ruby Style

In addition to the [RuboCop] styles configured described above, we follow common Ruby style
and idioms. For example `snake_case` methods and variable names and favoring functional style
methods.

## Syntax and Layout

* Avoid more than 3 levels of nesting.

* `!` instead of `not`
* use `&&` or `||`
* use `unless` over `!if`
* `{...}` for single line block
* `do..end` for multiline block
* omit `return` for values at end of method
* Use `||=` to init variables *only if* they're not already initialized
* Use `_` for unused block variables
* Prefer
  * `map` over `collect`
  * `find` over `detect`
  * `select` over `find_all`
  * `size` over `length`
* `utf-8` encoding of source file
* 2 spaces indent
* No tabs
* avoid using semi-colons `;`
* Spaces:
  * around operators `=`, `+`, `-`, `*`, `%`
  * around curly bracies `{` `}`
  * after commas , colons, and semicolons

    ```ruby
    my_hash = { one: 'el1', two: 'el2' }
    ```

* No spaces:
  * After shebang `!`
  * Around square brackets `[ ]` or parentheses `( )`

    ```ruby
    my_arr = [a, b, c]
    def my_func(arg: nil)
      if arg != something
        ...
      end
    end
    ```

* Empty line between method defintions.

    ```ruby
    def method1(arg1)
      ...
    end

    def method2(arg1)
      ...
    end
    ```

* Align successive method chains with `.method` on subsequent lines:

  ```ruby
  obj
    .compact
    .map { |elmt| ... }
  ```

* End each file with a newline.
* No trailing commas (`,`) for last element in `hash` or `array`:
* Place closing brackets for multiline statements on their own line:

  ```ruby
  # fail
    arr = [
    this = 1,
    that = 2, ]

  # pass
  arr = [
    this = 1,
    that = 2
  ]
  ```

* Empty line around `attr_` block:

  ```ruby
  class MyClass
    attr_reader   :name, :email
    attr_accessor :phone
    
    def initialize(name, email)
      @name   = name
      @email  = email
      @phone  = phone
    end
  end
  ```

### Classes and Modules

* Set `attrs` first
* Set `class << self` after `attrs`
* Set  `initialize` after `class << self`

  ```ruby
  class MyClass
    attr_reader :something, :another

    class << self
      def singleton_method
        ...
      end
    end

    def initialize
      ...
    end
  end
  ```

* Indent `private` and keep `defs` aligned with the block

  ```ruby
  class MyClass
    # public methods
    def public_method
      ...
    end
    
      private

      def my_private_method
        ...
      end
  end
  ```

### Collections

* Prefer literal array syntax over `%w` or `%i`

  ```ruby
  # fail
  arr_1 = %w(one two three)

  # pass
  arr_1 = ["one", "two", "three"]
  ```

* Instantiate with literals for all collections if possible.

  ```ruby
  # fail
  arr = Array.new()
  hsh = Hash.new()

  # pass
  arr = []
  hsh = {}
  ```

### Comments

* We require comments in the code.
* Use proper grammar and punctuation.
* Focus on *why* the code is the way it is if it is not obvious.
* Focus less on *how* the code works, that should be evident from the code.
* At the top of each class and method please add a description of the intent of the Class or Method
```javascript
/**
 * Format passed string to snake_case. All characters become lowercase. Existing
 * underscores are unchanged and dashes become underscores. Underscores are added 
 * before locations where an uppercase character is followed by a lowercase character.
 */
function snakeCaseWords(str) { 
```

### Exceptions

* Use implicit `begin` in method

  ```ruby
  # fail
  def some_method
    begin
      ...
    rescue Psych::SyntaxError => e
      ...
      raise e
  end

  # pass
  def some_method
    ...
  rescue Psych::SyntaxError => e
    ...
    raise e
  end

## Naming

### Variables

* Use meaningful names:
  * Ruby is not a statically typed language so we need good naming for maintainability.
  * Consider using an objects type for the dummy variable if possible.
  * Otherwise, try to convey what the object being passed to the block is through the name:

    ```ruby
    arr_1 = ['one', 'two', 'three']
    arr_2 = [1, 2, 3]

    # fail
    arr_1.each { |e| puts e }
    arr_2.each { |e| puts e }

    # pass
    arr_1.each { |str| puts str }
    arr_2.each { |int| puts int }
    ```

### Methods

* Avoid `is_` in method names.
* Use `?` suffix for methods that return a `bool`.
* Use `save` for boolean return and `save!` with exception returns.
* Favor functional methods
  * break up long logic or data transformations into their own methods
* DRY out code as best you can
  
    ```ruby
    # fail
    def some_method
      if var1 && bool2 && x > y || big % small > 1
        ...
      end
    end

    def some_other_method
      if var1 && bool2 && x > y || big % small > 1
        ...
      end
    end

    # pass
    def some_method
      if conditions_true?
        ...
      end
    end

    def some_other_method
      if conditions_true?
        ...
      end
    end

    def conditions_true?
      if var1 && bool2 && x > y || big % small > 1
    end
    ```

### Classe and Modules

* Mountain/Pascal case for Class and Module names.

  ```ruby
  class SomeCustomClass
    # code
    ...
  end
  ```

### JavaScript Style

Beyond the [ESLint] configuration files, we follow these styles:

* File names use underscores, `_`, for word seperators.
* Variables are `camelCase` named and are `const` or `let`. Using `var` is discouraged.
* Function names are `camelCase`.

### Html Style

In general, when making html elements (or Ruby/Js/Etc models of)
we'll follow this style.

* IDs use underscores `_` for word seperation. This follows the Rails `form_for` convention.


### CSS Style

* Applicable SCSS conventions like hyphenated variables and those variables are in the `_variables.scss` file.
* class names use hyphens, `-` for word seperators. If for no other reason than to follow bootstrap
  which we use quite extensively.
* classes should mostly use relative sizes (`em` and `rem`), rarely pixel values (`px`).

[Discourse]: https://discourse.osc.edu
[yardoc]: https://yardoc.org/
[Fork this repo]: https://help.github.com/articles/fork-a-repo/
[code of conduct]: CODE_OF_CONDUCT.md
[issue labels]: https://github.com/OSC/ondemand/labels
[good first issues]: https://github.com/OSC/ondemand/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22+
[RuboCop]: https://docs.rubocop.org/
[ESLint]: https://eslint.org/
