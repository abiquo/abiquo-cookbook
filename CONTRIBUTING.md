Contributing to the Abiquo cookbook
===================================

Thank you for your interest in the Abiquo cookbook. Contributing is quite easy, 
just submit a pull request!

## Branches and commits

Make sure you submit your pull request from a topic branch. If the patch is submitted
against a branch for a specific version of the cookbook, make sure it works in the
last version of `master` too.

Please, take your time to write [proper commit messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html). This will help reviewers and other contributors understand the
purpose of changes to the code. Remember that not all users use Chef in the same way or
on the same operating systems as you, so it is helpful to be clear about your use case
and change so they can understand it even when it doesn't apply to them.

During the review process you may be asked to make some changes to your submission.
While working through feedback, it can be beneficial to create new commits so the
incremental change is obvious. This can also lead to a complex set of commits, and
having an atomic change per commit is preferred in the end. Use your best judgement
and work with your reviewer as to when you should revise a commit or create a new one.

## Add tests

Tests are important for several reasons:

* We know the code works as expected.
* Help us not breaking your code unintentionally in the future.
* Provide working examples for users.

Please, include tests that cover your changes.

We use [ChefSpec](http://sethvargo.github.io/chefspec/) for unit tests and 
[Test Kitchen](http://kitchen.ci/) for integration tests. Make sure all tests are
passing before submitting your patch. We also use [RuboCop](http://rubocop.readthedocs.io/en/latest/) 
for static code analysis and [Foodcritic](http://www.foodcritic.io/) to check for 
common problems. All checks should be passing too.

The easiest way to run all unit tests and checks is by using the default rake task:

```bash
bundle exec rake
```

For further details about testing, refer to the [TESTING.md](TESTING.md) file.
