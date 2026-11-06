# AGENTS.md

Guidance for AI coding agents working in **specifications-LANG**.

## What this repo is

`specifications-LANG` is the **document + model source** for the openEHR **LANG** (Generic Languages) component. It is a *specification* repo, not software: the deliverables are the HTML specs at https://specifications.openehr.org/releases/LANG/. Sources are **AsciiDoc** prose plus the **BMM** schema `computable/BMM/openehr_lang_1.1.0.bmm.json`; the committed `docs/*.html` files are build artefacts.

`manifest.json` is the source of truth for which documents exist, their `spec_status`, releases, and the `SPECLANG` Jira roadmap. Published documents: `odin`, `bmm`, `bmm3`, `bmm_persistence`, `BEL`, `EL`.

LANG holds the generic, domain-independent languages the other components are written in: ODIN (the data notation used in ADL and BMM files), BMM and its persistence form P_BMM (the schema language every `computable/BMM/*.bmm.json` file in the other repos is written in), the Basic Expression Language (BEL) used by archetype rules, and the Expression Language (EL) that is still in development. BMM v3 is a parallel line of development with its own document and the `openehr_lang_1.1.0-bmm3` schema, which deliberately reuses the schema id of `openehr_lang_1.1.0`. LANG builds only on BASE; AM and the tooling (`bmm-publisher`, Archie) depend on it.

## Layout

- `docs/<document>/master.adoc` plus `masterNN-*.adoc` chapters (`master00` = amendment record); `manifest_vars.adoc` is generated from `manifest.json` on publish.
- `computable/BMM/openehr_lang_1.1.0.bmm.json` — the BMM; source of truth for all classes.
- `docs/UML/classes/` — **generated** class tables, named `org.openehr.<component>.<package>.<class>.adoc` (hence `{pkg}` in chapter includes, and `-q` when publishing).
- `.asciidoctorconfig` — attributes for editor previews (`:component:`, `:imagesdir:`).

<!-- openehr-scaffold:begin plugin -->
## Use the `openehr-specs@openehr` plugin

The plugin carries the spec-authoring know-how — **prefer its skills/agents over ad-hoc edits.** Don't re-derive their workflows here. `.claude/settings.json` registers the `openehr` marketplace and enables the plugin; Claude Code asks you to trust the folder first. To install it by hand: `/plugin marketplace add openEHR/ai-plugins`, then `/plugin install openehr-specs@openehr`.

| Task | Use |
|------|-----|
| Create/edit a spec, chapter, `master.adoc`, or `manifest.json` | skill `openehr-specs:authoring` |
| Spec prose style — overviews, semantics, design rationale | skill `openehr-specs:content-patterns` |
| Add or change classes, attributes, functions or invariants in the BMM | skill `openehr-specs:bmm-authoring` |
| Regenerate class tables/diagrams from BMM (`bmm-publisher`) | skill `openehr-specs:class-generation` |
| Amendment record (`master00-amendment_record.adoc`) | skill `openehr-specs:amendment-record` |
| Releases, CR/PR, lifecycle status, Jira workflow | skill `openehr-specs:governance` |
| Quality / convention review of a document | skill `openehr-specs:review` |
| Whole-document convention review (all chapters) | agent `openehr-specs:spec-reviewer` |
| Fact-check class/attribute/function names in prose | agent `openehr-specs:identifier-grounding` |
| Audit `{openehr_*}` attributes + `<<anchor>>` cross-refs | agent `openehr-specs:xref-auditor` |
| Local HTML preview of this component (you run it) | `/openehr-specs:publish LANG` |
| Check this repo against the standard file set | `/openehr-specs:scaffold` |
<!-- openehr-scaffold:end plugin -->

<!-- openehr-scaffold:begin build -->
## Build tool invocation

Docker is all you need to render the documents and regenerate the class tables. All `specifications-XX` repos, including `specifications-AA_GLOBAL` (boilerplate, references), are cloned as siblings under one parent directory. Render from that parent directory:

```bash
# render HTML. The image is published from specifications-AA_GLOBAL; its entrypoint passes -q
# (package-qualified class files). Use `Release-X.Y.Z` instead of `development` for a release build.
docker run --rm -u $(id -u):$(id -g) -v "$PWD:/documents/" ghcr.io/openehr/asciidoctor development LANG
```

The build prints `generated <file>` and exits 0 even when includes are missing, so read the log: any `ERROR` or `include file not found` line means incomplete output. It also rewrites the tracked `docs/*.html` artefacts.

```bash
# regenerate class tables (NEVER hand-edit docs/UML/classes/*.adoc) — run from this repo's root.
# Pass the repo BMM by PATH: a bare schema id (openehr_lang_1.1.0) uses the image's bundled copy, which lags this repo.
# LANG classes refer to types of other schemas: load each from its sibling clone with -d, or their links come out as /classes/<Type>.
OUT=$(mktemp -d)
docker run --rm --user $(id -u):$(id -g) \
  -v "$PWD/computable/BMM/openehr_lang_1.1.0.bmm.json":/in/openehr_lang_1.1.0.bmm.json:ro \
  -v "$PWD/../specifications-BASE/computable/BMM/openehr_base_1.3.0.bmm.json":/in/openehr_base_1.3.0.bmm.json:ro \
  -v "$OUT":/out \
  ghcr.io/openehr/bmm-publisher legacy-adoc \
  -d /in/openehr_base_1.3.0.bmm.json \
  /in/openehr_lang_1.1.0.bmm.json -o /out
# then diff "$OUT" against docs/UML/classes and copy over the tables you changed
```

To change a class/attribute/function/invariant, edit the BMM schema (skill `openehr-specs:bmm-authoring`, which also checks it) and regenerate (skill `openehr-specs:class-generation`) — never touch the generated tables.
<!-- openehr-scaffold:end build -->

## Gotchas

- BMM `documentation` strings pass through bmm-publisher's `formatText()`: `{attr}` is escaped, so write literal values (e.g. `latest`, not `{base_release}`); same-document `<<_x_class,X>>` xrefs work; use `×`, not `*`.

<!-- openehr-scaffold:begin conventions -->
## Conventions

### Commit messages

- **Format:** `Changes for <KEY> - <what changed>`, one line, for example `Changes for SPECLANG-42 - fix typos in the overview chapter`. Say what changed in the specification, not which file.
- **Several tickets:** join the numbers, `Changes for SPECLANG-49/50 - <what changed>`.
- **Every commit that has a Jira ticket carries its key.** Take it from, in order: the user, the branch name (`feat/SPECLANG-42-<slug>`), or the Jira issue the task links to (the `atlassian-openehr` MCP server can look an issue up). Never invent or guess a key.
- **Which key:** `SPECLANG` for this component (change requests), `SPECPR` for problem reports, `SPECPUB` for publishing and tooling issues, or the owning component's key (`SPECAM`, `SPECRM`, ...) when the change belongs there. See skill `openehr-specs:governance`.
- **No ticket:** write a plain summary without a key and say so in the pull request; do not use a placeholder key.
- Some history, mostly in other components, puts the key last, `<what changed> (SPECLANG-42)`. It is understood, but use the leading form here.
- A change to published specification text also needs an amendment-record entry with the same ticket (skill `openehr-specs:amendment-record`).
- Do not stage regenerated `docs/*.html` or generated class tables together with source changes unless the task is to refresh them.

### Branches

- Branch from `master` as `feat/<KEY>-<slug>` or `fix/<KEY>-<slug>`, for example `feat/SPECLANG-42-template-id`, and merge to `master` by pull request.
<!-- openehr-scaffold:end conventions -->
