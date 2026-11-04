# References for the first spec (shape-spec, gate, retrospective)

## Similar Implementations

All three live in the Loser League repository, read directly as the brief asked.

### Loser's shape-spec command

- **Location:** `~/Code/Sites/loser/.claude/commands/agent-os/shape-spec.md`
- **Relevance:** The customized command this repository's is modelled on.
- **Key patterns:** Step 5a "Core Architecture (always included)"; the "what you read here is a
  snapshot" paragraph; "Task N (FINAL — ALWAYS INCLUDED): Verification gate" with numbered steps
  and "if any step fails, fix the underlying issue (do not bypass)"; Step 8's "always include
  the final verification task ... a one-file fix is exactly the kind of spec that quietly
  invents a pattern"; Step 9's three-point text; the `shape.md` template's Standards
  Retrospective and Verification Gate sections; the two gate-related tips. Left behind: Steps 5c
  (Launch Obligations) and 5d (MCP Parity), the Redline unattended-mode section, and the PHP,
  Vue and module-specific wording.

### Loser's CLAUDE.md

- **Location:** `~/Code/Sites/loser/CLAUDE.md`
- **Relevance:** Source of the `## Git` rule, the `### No AI attribution — anywhere` section and
  the `## Specs & the standards retrospective` section.
- **Key patterns:** `## Git` copied minus its Redline sentence; the attribution section copied
  verbatim minus the Redline paragraph; the specs section rewritten for this gate with a new
  bullet for base ownership. Everything else there (Laravel Boost block, launch obligations, MCP
  parity, code review, triage, Pest, queues, Octane, local env) is Loser-specific and left out.

### Loser's standards retrospective

- **Location:** `~/Code/Sites/loser/agent-os/standards/process/standards-retrospective.md`
- **Relevance:** Ported to `base/process/standards-retrospective.md`.
- **Key patterns:** The four diff-checkable questions; "verify against the code, not against
  the spec" (its #405 story retold without the project specifics); "never edit this file from
  inside a retrospective", extended here to the gate scripts; "own change set" under Git; the
  two recording shapes. Added: "Who owns which standard" and the `(proposed, base)` shape.

### The stock shape-spec command

- **Location:** `.claude/commands/agent-os/shape-spec.md` as installed (git `19bf3de`, untracked
  at shaping time); `index-standards.md` and `inject-standards.md` beside it.
- **Relevance:** The flow to keep, and the index format the stock commands read: two levels,
  folder then file, `agent-os/standards/{folder}/{file}.md`. That is why the `base:` section's
  keys carry the rest of the path (`process/standards-retrospective`).
