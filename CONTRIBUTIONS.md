# Contributing to gui-v2

gui-v2 is the user interface for Victron Energy Venus OS. It runs on GX devices and as the remote console in a browser. Changes in this repository are shipped to customers. The `main` branch must always be releasable.

Contributions are welcome. A contribution is accepted only if it meets the requirements below.

## Copyright

You must be willing to give Victron Energy B.V. the copyright in your contribution.

By opening a pull request, you confirm that:

- you wrote the code, or you have permission from everyone who did
- you give Victron Energy B.V. the copyright in that contribution
- Victron may use, change, and ship it under the license in `LICENSE.txt`, including in commercial products

If you cannot agree to that, do not open a pull request. We cannot accept code that stays under someone else's copyright, or under a different license.

Every new source file (`.cpp`, `.h`, `.qml`) must start with the Victron copyright header. Use the year the file is added. Do not remove the header from a file you edit.

```
/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
```

Do not omit the header. Do not put a different license on a new file. Do not copy in code that you cannot put under this copyright and `LICENSE.txt`.

Code that is already in this repository under its own license, such as `src/qzxing`, keeps that license. Do not replace those headers.

## Design changes

A contribution that changes the design must be approved by Serj or Rein before it is merged.

A design change is a change to the look, layout, or interaction, a new screen, or a change to user-facing behaviour that is a product decision. A bugfix that restores the existing intended behaviour is not a design change, and does not need this approval.

For a large design change, get that approval on the issue before you open a pull request. Approval means an explicit yes from Serj or Rein. Silence is not approval.

## Code quality

The change must meet the code-quality standard used for this repository. Reviewers use [.github/code-review.md](.github/code-review.md). Read that guide before you open a pull request. Do not expect a reviewer to clean the change up for you.

In particular:

- Follow the existing structure. See [.github/architecture.md](.github/architecture.md).
- User-facing UI must work in landscape and portrait. See [.github/layout-modes.md](.github/layout-modes.md).
- Interactive UI must be usable with the buttons and keyboard. See [.github/key-navigation.md](.github/key-navigation.md).
- Use `Theme` colors, sizes, and fonts. Do not hardcode them.
- User-visible text uses `qsTrId()` and engineering English only. Do not add translations for other languages. See [.github/i18n-l10n.md](.github/i18n-l10n.md).
- Non-trivial logic needs tests. See [.github/unit-tests.md](.github/unit-tests.md). For a visible UI change, check the result. See [.github/visual-regression-tests.md](.github/visual-regression-tests.md).
- In QML, always use braces around an `if` body.
- Format C++ with `victron.astyle` (1TBS, tabs, 120 character lines).
- Commit messages use plain language. The subject says what was done, in the imperative. Wrap the subject and the body at 72 characters. The body briefly says what was done, how, and why.
- Do not add a dependency unless the maintainers have agreed to it.

## Issues and pull requests

Create an issue before you open a pull request.

For a large issue or feature, it is better to get approval on the issue before you open a pull request.

Name the branch `username/short-feature-description`, for example `chriadam/gui-plugins-api`.

Open the pull request against `main`. A pull request should contain a small, atomic unit of work. Do not mix it with unrelated edits. A large feature should be split into more than one pull request if each part is usable on its own. Smaller pull requests are easier to review.

End the pull request description with:

```
Contributes to issue #ABCD
```

Replace `#ABCD` with the issue number. This links the pull request to the issue.

## Review

Every contribution is reviewed thoroughly by more than one developer. At least two maintainers must review it. The author does not count as one of those reviewers.

No contribution is merged to `main` until it is release-ready. `main` must always be releasable. Release-ready means:

- the change is correct
- it does not leave a known bug
- it does not break existing behaviour
- the requirements in this document are met
- the review comments are addressed
- it is safe to ship to customers in the next Venus OS release without a follow-up fix

An unfinished change does not go on `main`. Maintainers merge. Opening a pull request does not mean it will be merged.

## Support

Do not use this repository for product support. The issue tracker is for development. For support, use the Venus OS section on [Victron Community](https://community.victronenergy.com/c/modifications/5).

## Building

Build instructions are on the wiki: [How to build venus-gui-v2](https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2).
