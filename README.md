# codemap

A [Claude Code](https://docs.claude.com/en/docs/claude-code) skill that generates **`CODEMAP.md`** — a navigation companion to `CLAUDE.md` that helps Claude (and developers) quickly locate code by task and understand how data flows through a codebase.

It **supplements** `CLAUDE.md` rather than replacing it: `CLAUDE.md` holds the project overview, commands, and conventions; `CODEMAP.md` answers *"to do task X, edit these files"*, *"here's how data flows through the system"*, and *"these are the core business modules and what they do"*.

## What it generates

- **Task Index** — "to do X, edit these files", with line numbers, preconditions, and pitfalls
- **Call-chain diagrams** — Mermaid graphs for both *control flow* (who calls whom) and *data flow* (how data is transformed), including parallel/async branches, each tagged with a confidence level
- **Core business modules** — a concise table of responsibility / key files / entry functions
- **Module dependency graph** and a maintained change log

For larger codebases (> 50 source files) it switches to a **two-layer layout**: a top-level `.claude/CODEMAP.md` plus per-module `.claude/CODEMAP-<module>.md` files.

## Usage

In Claude Code, run:

```
/codemap
```

The skill reads any existing `CLAUDE.md` first and skips what it already covers, traces **only explicit calls** (it never guesses), labels each diagram's confidence (and where to verify it), and finally wires a reference into `CLAUDE.md` so future sessions load the map automatically.

## Install

Clone into your Claude Code skills directory:

```bash
git clone https://github.com/Edward-Jackie/codemap.git ~/.claude/skills/codemap
```

You can also drop it into a project's `.claude/skills/`. Once installed it's available as the `/codemap` command.

## License

See [LICENSE](LICENSE).
