# Contributing to gui-v2

gui-v2 is the user interface for Victron Energy Venus OS. It runs on GX devices. The WebAssembly build can be loaded in a web browser from the Cerbo GX via the local LAN, or from VRM via the Internet. The same build can be loaded inside VictronConnect, from the Cerbo GX directly or from VRM via the Internet. Changes in this repository are shipped to customers. The `main` branch must always be releasable.

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
- Use `Theme` colours, sizes, and fonts. Do not hardcode them.
- User-visible text uses `qsTrId()` and engineering English only. Do not add translations for other languages. See [.github/i18n-l10n.md](.github/i18n-l10n.md).
- Use UK spelling in all text. Keep the original spelling only where it cannot be changed, such as a Qt API name.
- Non-trivial logic needs tests. See [.github/unit-tests.md](.github/unit-tests.md). For a visible UI change, check the result. See [.github/visual-regression-tests.md](.github/visual-regression-tests.md).
- Check the change on each platform where its behaviour can differ from the other platforms: the desktop build, a GX device, and the WebAssembly build.
- In QML, always use braces around an `if` body.
- Format C++ with `victron.astyle` (1TBS, tabs, 120 character lines).
- Commit messages use plain language. The subject summarises what was done, in the imperative. Wrap the subject and the body at 72 characters. The body briefly describes what was done, and why it was done that way (if unclear).
- Do NOT add a dependency unless the maintainers have agreed to it.

## Code Comments and Documentation

All code comments and documentation must be: CONCISE, CLEAR, PLAIN-LANGUAGE, CORRECT, PRECISE, USEFUL.

- CONCISE: say only what is needed, with no extra words and no extra context information.
- CLEAR: it must not be complex to parse or understand.
- PLAIN-LANGUAGE: use ordinary words rather than invented terms or jargon, and do not use technical words unless it is reasonable to assume the reader should know them.
- CORRECT: every statement must be true, and grammatically correct.
- PRECISE: the scope of the description of a concept or behaviour must be neither narrower nor wider than the scope of the implementation; each sentence must have only one possible meaning; and the meaning must accurately reflect the implemented semantics being described or explained.
- USEFUL: the text must let the reader understand something they cannot understand from reading the code alone; restating what the code does is usually not useful. There is a possible exception to this rule for code comments, described below as "rarely WHAT".

Additionally, for code comments, the following rule should be followed: sometimes WHY, rarely WHAT, never HOW.

- sometimes WHY: a comment should be added to explain WHY some code does something in particular when the reasons behind that decision are not immediately obvious, and to describe any trade-offs involved which contributed to the decision.
- rarely WHAT: a comment should generally NOT be added to describe WHAT some code does. Code should be self-documenting via appropriately named variables, functions, and properties; self-documenting code does not require a WHAT comment. Prefer to change the code to be more self-documenting instead of adding a WHAT comment. There are TWO exceptions to this guidance (and in both cases the WHAT comment should be only one line):
  - Large code block: when the implementation details are spread over a large number of lines of code, it can be difficult to ascertain or understand what the entire code block does. In that case, it is permissible to add a one-line comment describing WHAT the code block does. It is often preferable to extract such code blocks into functions (which can then be named appropriately so that the calling code is self-documenting), but not always.
  - Cannot be rewritten: if some code is not appropriately self-documenting but cannot be modified in order to be appropriately self-documenting, it is permissible to add a one-line comment describing what the code does. This case is very rare; for example, the code depends on a third-party, external, or library function whose name is poor, and that name cannot be changed.
- never HOW: do NOT say HOW the code does what it does. The code already shows that.

Finally: re-read EVERY code comment or documentation paragraph again, after you have added or modified it.

- ensure that it is not broken English
- ensure that it uses correct grammar, with appropriate tense
- ensure that the subject of each sentence (and each sentence fragment) is clear ("it", "both", "that" etc must clearly and unambiguously refer to appropriate subjects which have previously been identified directly)
- ensure that it is not constructed of multiple individually-correct points which somehow contradict, or which somehow break the "subject clarity" requirement above
- ensure that it uses terms or identifiers consistently to avoid misunderstandings
- ensure that a plain-reading of the comment or documentation gives the reader the intended understanding.

Note: the same rules apply to commit messages.

## Issues and pull requests

Create an issue before you open a pull request.

For a large issue or feature, it is better to get approval on the issue before you open a pull request.

Name the branch `username/short-feature-description`, for example `chriadam/gui-plugins-api`.

Open the pull request against `main`. A pull request should contain a small, atomic unit of work. Do not mix it with unrelated edits. A large feature should be split into more than one pull request if each part is usable on its own. Smaller pull requests are easier to review.

The pull request description must be concise and use plain language. It must not be a generated write-up.

End every commit message body with one of the lines below (replace `#ABCD` with the issue number):
- Fixes issue #ABCD
- Contributes to issue #ABCD

When the pull request has only one commit, and that commit fixes the issue, end that commit message body with `Fixes issue #ABCD`.

When more than one commit contributes to the issue, end each of those commit message bodies with `Contributes to issue #ABCD`. When the pull request has only one commit, if that commit does not entirely fix the issue, end that commit message body with `Contributes to issue #ABCD`.

Each of those lines links the commit that contains it to the issue. Do not write only `Issue #ABCD`. A reader of the git log cannot tell, from a commit that says only that, whether that commit was meant to fix the issue by itself, or whether more commits are still coming.

## Review

Every contribution is reviewed thoroughly by more than one developer. At least two maintainers must review it. The author does not count as one of those reviewers.

Respond to each review comment in the pull request. Squash each fix into the relevant commit. Do not create a new commit for a review fix. Reviewers can use `git diff` and the reflog to determine the specific changes.

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

## Testing

You should always test your changes prior to opening a pull request. All changes must be tested on all required platforms i.e. CerboGX and WebAssembly (both local LAN connection, and VRM connection). If possible, you should also test the WebAssembly build within VictronConnect's web view, as well as an external web browser (e.g. on desktop and/or mobile).


