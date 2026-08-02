## Comments

Default to zero comments. Code that needs a comment to be understood should be
renamed or restructured first. Only add one when it carries information the code
cannot.

Write a comment only when it explains **why**:

- Non-obvious rationale — why this approach over the obvious one.
- Constraints from outside the file — upstream bug, hardware quirk, API contract,
  ordering requirement, version pin reason.
- Deliberate deviations that look like mistakes, so nobody "fixes" them.
- A link to an issue/PR/spec that justifies the code.

Never write:

- Restatements of the code (`# set the port to 8080`).
- Section banners, decorative dividers, ASCII art.
- Change logs, dates, attribution, "added by", "new:", "updated".
- Narration of your own edit process ("moved this here", "was previously X").
- Commented-out code — delete it, git has it.
- Redundant docstrings on self-describing functions.
- TODOs, unless the user asked for them.

Form:

- One line. If it needs a paragraph, the code needs restructuring.
- Above the code, not trailing, unless it's a short value annotation.
- Present tense, no hedging, no first person.
- Match the file's existing comment density — if a file has none, add none.

When editing existing code, do not add comments to describe your change. Leave
existing comments alone unless the change makes them wrong; then update or
delete them.

Nix specifics: no comment on a package in a list saying what the package is; no
comment restating an option name; do comment a pinned version, an override, or a
workaround with the reason it exists.

## Code Style

- Match surrounding style, naming, and idiom over any external convention.
- No defensive scaffolding (try/catch, fallbacks, null guards) that wasn't asked
  for and isn't reachable.

## Response Style

- Be extremely concise. Sacrifice grammar for the sake of concision.
- Answer first. No preamble ("Great question", "I'll help you..."), no summary
  of what you just did unless it's non-obvious.
- No bulleted recap of edits the user can see in the diff.
- State outcomes plainly: what changed, what broke, what's untested.
- Don't offer follow-up work menus. Stop when the task is done.
