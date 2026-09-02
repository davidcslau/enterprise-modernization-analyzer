# Design — v4.0.0 Target Refresh

## 1. What kind of change this is

Not a version-string sweep. Three of the four workstreams change *reasoning*, not numbers:

| Workstream | Nature |
|---|---|
| .NET 10 only | **Deletion** of a choice. The trade-off table goes; a single target replaces it |
| Spring Boot 4.1 | **Re-sequencing.** A two-stage upgrade becomes three, and the middle stage is mandatory |
| Blocking vs reactive | **Reversal of a default**, plus four file renames |
| Front-end generalised | **Widening** an enumeration, which turns out to *reduce* content |

Only the fourth is mostly mechanical. The 120 stale version strings are the easy part.

## 2. .NET: why the trade-off table is deleted rather than edited

The existing table has a "Support window vs a long programme" row that reads as a genuine
consideration between .NET 8 and .NET 10. With .NET 8 expiring 10 Nov 2026 there is no
consideration — one option is simply wrong. Editing the table would preserve the *shape* of a
decision that no longer exists, which is worse than removing it: a reader skims a two-column
table and infers two viable answers.

Replacement shape:

```
## Target Runtime: .NET 10
  - one target, stated flatly, with .NET 10's own support window (to ~Nov 2028) and the
    next LTS (.NET 12, ~Nov 2027) given so a long programme can reason about its own tail
  - .NET 8 appears only twice: as a detected state that itself needs upgrading, and as a
    tooling trap (AWS Transform still offers it — do not pick it)
```

**Detected .NET 8/9 is a finding, not a source family.** Per R1.2 no new row is added to the
paths table. The reasoning: a .NET 8 → 10 upgrade is an in-place version bump, not a
modernization path — it shares none of the Windows lock-in, Web Forms or WCF analysis that
justifies a dedicated steering file. It belongs in the findings matrix.

**The 3.x pre-step gets weaker language, not removal.** AWS Transform documents .NET Framework
3.5+ as a supported source, which contradicts the customer workbook's assumption that 3.x needs
a 3→4 pre-step. Both could be true — the workbook may reflect an older tool version or a 3.0
codebase. Design decision: state what AWS documents, state what the workbook assumes, and
instruct the analyzer to **verify against the tool version in use** rather than asserting either.
This is the honest treatment when two sources disagree, and it matches the
derivable-vs-customer-input discipline already in `evaluation-framework.md`.

## 3. Spring: the three-stage sequence is the core insight

Current guidance reasons in two stages: Java 8 → 17, then Boot 2.7 → 3.x. The new sequence:

```
Stage 1   Java 8 → 21 or 25            (JDK upgrade, javax intact)
Stage 2   Boot 2.7 → 3.5               (jakarta namespace + deprecation cleanup)
Stage 3   Boot 3.5 → 4.1               (EE 11, starters, Jackson 3, Security 7)
```

**Stage 2 cannot be skipped**, and that is the non-obvious part. Boot 4 removes every API
deprecated in Boot 3.x with no grace period, so a 2.7 codebase jumping straight to 4.1 hits a
wall of compile errors with no map. The cleanup has to happen *on* 3.5 with
deprecation-as-error enabled, where the warnings are still warnings. So Boot 3.5 is a mandatory
staging post despite being out of OSS support — it is a *transit* version, not a destination.
The steering must say exactly that, because "3.5 is EOL" would otherwise imply skipping it.

**Why pin 4.1.x rather than say "Boot 4".** Boot 4.0's OSS window closes 31 Dec 2026. A
programme landing on 4.0 upgrades again within months. Stating the ~13-month minor cadence lets
a reader work out that a programme finishing in 2027 should plan for 4.2 or 4.3, which is more
useful than any fixed recommendation.

**Jakarta EE 11 adds a second axis to the namespace story.** The existing model is binary —
`javax` bad, `jakarta` good. Now there are three positions: `javax` (EE 8), `jakarta` at EE 9/10,
and `jakarta` at EE 11. An application arriving on EE 10 has done the hard rename but still has
a step. The Tomcat table becomes the clearest expression of this and gains a third row.

## 4. Blocking vs reactive: how to present neutrally without being useless

Decision C is "present both, rank neither". The failure mode is a wishy-washy section that
helps nobody. The design guards against that in three ways:

1. **A stated starting assumption is not a recommendation.** The file says: absent evidence to
   the contrary, assume blocking + virtual threads, because it is the smaller change from the
   source material. That is a *default to depart from*, not a verdict — the same device already
   used for "backend-only is a first-class answer".
2. **Decision criteria are concrete, not vibes.** Reactive earns its place on: streaming or SSE
   endpoints, very high concurrent connection counts, an existing reactive codebase or skilled
   team, or a fully non-blocking driver stack already in place. Otherwise the migration inherits
   Reactor's debugging cost for no throughput gain.
3. **The migration-specific asymmetry is stated once, plainly.** Porting EJB/Servlet blocking
   logic into operator chains is a paradigm change layered on a platform change. Virtual threads
   let the ported code stay shaped like the original, which is precisely what a
   behavioural-equivalence acceptance criterion wants.

**File renames.** Dropping "Reactive" from four titles is the visible half; the invisible half is
67 R2DBC references, many of which are *default* guidance ("all data access migrated to R2DBC" in
validation criteria). Those become JPA-default with R2DBC as the documented alternative. Validation
criteria that currently *require* R2DBC would otherwise contradict the new neutrality.

New findings that only exist once virtual threads are on the table: pinning from `synchronized`
on I/O paths, and ThreadLocal / SecurityContext propagation. These are real, silent, and
load-bearing enough to belong in the findings matrix rather than a footnote.

## 5. Front-end: generalising reduces content

Counter-intuitive but true. The current file is already ~90% target-agnostic because the
expensive analysis is all source-side. Hardcoding React|Vue therefore buys nothing and excludes
Angular (19.8% of professional usage, and the framework most associated with large structured
enterprises — exactly this power's audience).

```
Prompt becomes:  React | Vue | Angular | Svelte | other (name it) | undecided | backend-only
Analysis:        unchanged, framework-agnostic
New section:     "Target-Specific Considerations" — only the three things that genuinely differ
```

The three genuinely-differing items, and why each is in scope:

- **Hybrid-embedding friction.** Our hybrid option *is* "components embedded in server-rendered pages", so a documented Vue edge there interacts directly with a strategy we present. Stated as a consequence of the customer's own combination, not as advice to pick Vue.
- **Meta-framework coupling.** Next.js/Nuxt/SvelteKit bring SSR, their own routing and their own deployment model — materially different from a plain SPA served from Spring Boot static resources or S3+CloudFront, which is a decision we already cover.
- **Component-library continuity.** Asymmetric on the *source* side: PrimeFaces has same-vendor ports for both React and Vue; RichFaces, IceFaces and Vaadin have none anywhere. So it is a source-side finding that happens to have target-side relief in one case.

"Undecided" is first-class because our own ground rules forbid choosing for the customer. Sizing
does not depend on the answer, so there is no reason to force one.

**Security 7 CSRF belongs here.** The file already explains that server-rendered synchroniser
tokens do not carry over. Security 7 turning CSRF on for API endpoints by default means a SPA
hitting a fresh Boot 4.1 back end gets 403s until configured — a concrete, new, high-priority
finding at exactly the seam this file owns.

## 6. Sequencing rationale

| Phase | Why here |
|---|---|
| 1 Targets and prompts | Establishes the contract every later phase writes into. Cheapest place to catch a wrong decision, hence the checkpoint |
| 2 .NET depth | Independent of the Spring and reactive work |
| 3 Java/J2EE depth | Must precede phase 4, which edits the same files |
| 4 Reactive stance | Includes renames, so it lands after the content in those files has settled |
| 5 Cross-cutting | Touches files the earlier phases do not own |
| 6 Verify, version, deploy | Verification is only meaningful once everything exists |

## 7. Risks

| Risk | Handling |
|---|---|
| A version sweep silently changes a *quoted* legacy fact (e.g. "Tomcat 9 is javax") | Only target-side versions change. Source-side facts about legacy platforms are left alone; each edit is reviewed for which side it describes |
| Renaming four files breaks the dispatch table | Phase 6 verification re-checks 13-of-13 reachability; renames and dispatch edits land in the same commit |
| Neutral reactive section becomes useless | Concrete decision criteria plus a stated starting assumption, per §4 |
| Boot 3.5 "EOL" read as "skip it" | Explicitly labelled a mandatory transit version with the reason attached |
| These facts go stale again | Requirements records every fact with a date and source, and instructs re-verification |
