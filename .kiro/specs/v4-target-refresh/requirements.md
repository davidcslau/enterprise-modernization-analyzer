# Requirements — v4.0.0 Target Refresh

## Why

Both of the power's modernization targets are past their support dates. The analyzer
would currently recommend that a customer modernize *onto* an unsupported platform.

| Target we currently recommend | Reality |
|---|---|
| .NET 8 | **End of support 10 November 2026** — weeks away |
| Spring Boot 3.x | **Spring Boot 3.5 OSS EOL 30 June 2026.** Every 3.x branch is already out of OSS support |

## Researched facts — established 2 September 2026

Recorded with dates and sources because every requirement below depends on them, and
because they will themselves go stale. Re-verify before the next refresh.

### .NET

| Fact | Source |
|---|---|
| .NET 8 (LTS, Nov 2023) end of support **10 Nov 2026**; .NET 9 the same date | [devblogs](https://devblogs.microsoft.com/dotnet/dotnet-8-9-end-of-support) |
| .NET 10 is LTS, released Nov 2025, supported ~3 years to **Nov 2028**. Next LTS is .NET 12 (~Nov 2027) | [releases and support](https://learn.microsoft.com/en-us/dotnet/core/releases-and-support) |
| LTS = 3 years of patches, STS = 2 years | [support policy](https://dotnet.microsoft.com/en-us/platform/support/policy/dotnet-core) |
| **AWS Transform sources**: .NET Framework **3.5+**, .NET Core 3.1, .NET 5.x+, .NET 8 | [AWS Transform .NET](https://docs.aws.amazon.com/transform/latest/userguide/dotnet.html) |
| **AWS Transform targets**: .NET 8 **or** .NET 10 → direct Framework → .NET 10 is supported, no intermediate hop | same |
| Supported project types (C# only): class libraries, console, ASP.NET MVC incl. Razor views, SPA back-ends, Web API, **Web Forms**, unit tests (NUnit/xUnit/MSTest), **WCF services** | same |
| **Preview** (may not transform completely): WinForms, WPF, Xamarin, **VB.NET** | same |
| **Not transformed**: Blazor UI components, Win32 DLLs without core-compatible libraries, repos with no solutions | same |
| Porting Assistant for .NET closed to new customers from 7 Nov 2025 | [docs](https://docs.aws.amazon.com/portingassistant/latest/userguide/what-is-porting-assistant.html) |

### Spring / Java

| Fact | Source |
|---|---|
| Spring Boot 3.5 OSS EOL **30 Jun 2026**; 3.5 was the last 3.x branch, so all of 3.x is out of OSS support | [endoflife.date](https://endoflife.date/spring-boot), [danvega](https://www.danvega.dev/blog/spring-boot-end-of-life) |
| Boot 4.0 GA **20 Nov 2025**, OSS support ends **31 Dec 2026** | [migration analysis](https://ankurm.com/spring-boot-3-to-4-migration-guide/) |
| Boot **4.1** GA **10 Jun 2026** on Framework 7.0.8; latest patch 4.1.1 (**20 Aug 2026**); supported to **31 Jul 2027** | same, [InfoQ](https://www.infoq.com/news/2026/06/spring-boot-4-1/) |
| Each Boot minor gets roughly **13 months** of OSS patches | same |
| Framework 7: **JDK 17 floor, JDK 25 recommended**, **Jakarta EE 11**, Kotlin 2.2, GraalVM 25 | [Framework 7 release notes](https://github.com/spring-projects/spring-framework/wiki/Spring-Framework-7.0-Release-Notes) |
| Jakarta EE 11 = **Servlet 6.1, JPA 3.2, Bean Validation 3.1** | [Framework 7 notes](https://github.com/spring-projects/spring-framework/wiki/Spring-Framework-7.0-Release-Notes) |
| Servlet 6.1 floor → **Tomcat 11 / Jetty 12.1**. **Undertow support removed entirely** — no Servlet 6.1 release exists and there is no workaround | [migration analysis](https://ankurm.com/spring-boot-3-to-4-migration-guide/) |
| **All APIs deprecated in Boot 3.x are removed in Boot 4** — no grace period | same |
| Spring Security 7: lambda DSL only (`.and()` removed); **CSRF applied to API endpoints by default**, so stateless REST APIs return 403 until configured | same |
| Starter modularisation: autoconfigure jar split (1,470 → 258 classes); starters renamed (`spring-boot-starter-webmvc`, `-restclient`, `-webclient`, `-kafka`; observability split); `-test` companions; `*Properties` classes moved package | same, [official migration guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-4.0-Migration-Guide) |
| Jackson 3 is default: `com.fasterxml.jackson` → `tools.jackson`, unchecked exceptions, annotation renames, property moves | same |
| Tests: `@MockBean`/`@SpyBean` removed → `@MockitoBean`/`@MockitoSpyBean`; `@SpringBootTest` no longer auto-configures MockMvc or TestRestTemplate | same |
| Spring Batch runs **in-memory by default**; persistence needs `spring-boot-starter-batch-jdbc` | same |
| Virtual threads remain **opt-in** (`spring.threads.virtual.enabled=true`) | same |
| Hibernate **7.4** and Spring Data JPA **4** under Boot 4.1; Spring Data 4.x changes lazy-loading behaviour | [Hibernate 7.4](https://www.marmo.dev/hibernate-7-4/) |
| OpenRewrite recipe exists for the Boot 4 upgrade | [migration analysis](https://ankurm.com/spring-boot-3-to-4-migration-guide/) |
| Amazon Corretto 25 GA (Sep 2025); AWS Lambda supports Java 25 (Nov 2025) | [Corretto 25](https://aws.amazon.com/about-aws/whats-new/2025/09/amazon-corretto-25-generally-available/), [Lambda Java 25](https://aws.amazon.com/blogs/compute/aws-lambda-now-supports-java-25) |
| R2DBC remains supported (Spring Data Relational 4.x, Framework 7 R2DBC) | [Spring Data Relational](https://docs.spring.io/spring-data/relational/reference/r2dbc/repositories.html) |

### Front-end

| Fact | Source |
|---|---|
| Professional usage: React 46.9%, **Angular 19.8%**, Vue 18.4%, Svelte 6.9% | [survey summary](https://www.refontelearning.com/blog/top-javascript-frameworks-for-web-development-2026) |
| Angular is repeatedly characterised as the enterprise choice for large, structured organisations | [FullScale](https://fullscale.io/blog/react-vs-angular-vs-vue/), [ImaginaryCloud](https://imaginarycloud.com/blog/best-frontend-frameworks) |
| Vue has an edge for integrating into **existing server-rendered** applications | [RaftLabs](https://www.raftlabs.com/blog/react-vs-vue), [Cubix](https://www.cubix.co/blog/next-js-vs-react-vs-vue/) |
| Framework choice increasingly implies a meta-framework: ~78% of new React apps use Next.js (React→Next.js, Vue→Nuxt, Svelte→SvelteKit) | [Intuz](https://www.intuz.com/best-frontend-frameworks/) |
| Virtual threads vs WebFlux: virtual threads on Netty won ~50% of head-to-head contests, WebFlux ~26%, ~25% no clear winner | [loom-webflux-benchmarks](https://github.com/chrisgleissner/loom-webflux-benchmarks) |

*Content from external sources was rephrased for compliance with licensing restrictions.*

## Current state, audited

| Claim in the power | Occurrences | Files |
|---|---|---|
| `Spring Boot 3` | 70 | 9 |
| `.NET 8` | 50 | 6 |
| `Java 17` / `Java 17/21` | 47 / 8 | 10 |
| `R2DBC` | 67 | 6 |
| `Undertow` | 10 | 2 |
| Spring Boot 4, Java 25, Tomcat 11, Jakarta EE 11, Jackson 3, Spring Security 7, Hibernate 7 | **0 each** | — |
| `virtual thread` | 1 | 1 |

Four steering files carry "Spring Boot **Reactive**" in their titles.

## Requirements

### R1 — .NET target
- **R1.1** .NET 10 is the only .NET target offered. .NET 8 is removed as a *target option*.
- **R1.2** .NET 8 / 9 remain *detectable states* and, when found, are reported as themselves requiring an upgrade before Nov 2026. No new source-family row is added for them.
- **R1.3** Direct .NET Framework 4.x → .NET 10 is stated as supported. **No 4.x → 8 → 10 two-step is introduced**, because AWS Transform supports the direct target.
- **R1.4** The .NET 8 vs .NET 10 trade-off table is **deleted**, not updated. There is no trade-off left to present.
- **R1.5** Where tooling still offers .NET 8 as a target, the analyzer explicitly instructs selecting .NET 10 and states why.
- **R1.6** The 3.x → 4.x pre-step claim is softened to *verify, do not assume*: AWS Transform lists .NET Framework 3.5+ as a supported source, so the pre-step may be unnecessary; 3.0 is below the floor.
- **R1.7** VB.NET friction is retained and re-grounded on the documented preview status rather than inference. Blazor UI components are named as not transformed.

### R2 — Spring / Java target
- **R2.1** Target is **Spring Boot 4.1.x**, pinned to the minor, not "Spring Boot 4". Boot 4.0 is named as the wrong landing point.
- **R2.2** The ~13-month minor cadence is stated so programmes plan for 4.2/4.3 rather than being surprised.
- **R2.3** Java target is **21 or 25 (Corretto)**, with 17 as floor only. Java 25 is the default recommendation.
- **R2.4** Jakarta EE 11 (Servlet 6.1, JPA 3.2, Bean Validation 3.1) replaces Jakarta EE 9/10 as the target baseline.
- **R2.5** The namespace/compatibility table gains a **Tomcat 11 / Servlet 6.1 / Boot 4** row.
- **R2.6** Sequencing becomes three stages — Java 8 → 21/25, Boot 2.7 → 3.5, Boot 3.5 → 4.1 — with the middle stage **mandatory**, because Boot 4 removes every Boot 3 deprecation and the cleanup must happen on 3.5 with deprecation-as-error enabled.
- **R2.7** A Boot 4 breaking-change cluster is added: starter modularisation and package moves, Jackson 3, Spring Security 7, test-annotation removals, Spring Batch in-memory default, Hibernate 7.4 / Spring Data JPA 4 lazy-loading changes.
- **R2.8** **Undertow becomes a named hard blocker** on the WildFly path, not a strategy-bank row.
- **R2.9** The WildFly "already positioned" advantage is corrected: WildFly 27+/EAP 8 are Jakarta EE **10**, closer to EE 11 but not there.
- **R2.10** OpenRewrite's Boot 4 recipe is named as tooling.

### R3 — Blocking vs reactive (decision C)
- **R3.1** Both are presented with consequences; **neither is ranked or recommended**, consistent with how the power already handles SPA-vs-hybrid and React-vs-Vue.
- **R3.2** The **stated starting assumption** is blocking Spring MVC + virtual threads on Java 21/25, with reactive adopted where evidence justifies it — streaming, SSE, very high connection counts, existing reactive capability.
- **R3.3** The reasoning is recorded: for a *legacy migration* audience, reactive stacks a paradigm change on top of a platform change. Virtual threads let ported blocking logic stay blocking and still scale.
- **R3.4** Four steering files are renamed to drop "Reactive" from their titles.
- **R3.5** R2DBC becomes the alternative, JPA the default, across all affected guidance.
- **R3.6** New findings: virtual-thread pinning (`synchronized` → `ReentrantLock`), and ThreadLocal / SecurityContext propagation under virtual threads.

### R4 — Front-end target generalised
- **R4.1** The prompt accepts **any named SPA framework** — React, Vue, Angular, Svelte, other — plus **undecided** and **backend-only**.
- **R4.2** The analysis path stays **framework-agnostic**; only a small target-specific section varies.
- **R4.3** "Undecided" is a first-class answer: size the rewrite framework-agnostically and name the choice as an open question for the customer.
- **R4.4** Target-specific content is limited to: hybrid-embedding friction (Vue's edge for embedding into server-rendered pages), meta-framework coupling (Next.js/Nuxt/SvelteKit and the SSR/routing/deployment consequences), and source-side component-library continuity (PrimeFaces → PrimeVue/PrimeReact both exist; RichFaces/IceFaces/Vaadin have no equivalent in any target).
- **R4.5** The no-advocacy rule is retained and extended to all frameworks, not just React vs Vue.
- **R4.6** Spring Security 7's CSRF-on-by-default for API endpoints is added as a high-priority SPA finding.
- **R4.7** The claim that AI assistants generate better React than Vue is **not encoded** — single weak source, and it edges into advocacy.

### R5 — Version and release
- **R5.1** Ship as **v4.0.0**. Retiring a target platform is a breaking change to the power's contract.
- **R5.2** `POWER.md` version, description and keywords updated.
- **R5.3** `MIGRATION-NOTES.md` updated for the atx monolith.

## Invariants (unchanged from v3)

- `report-structure.md` stays AUTHORITATIVE: **11** numbered sections, **43** checklist items, exactly **3** ranked pathways
- No dollar amounts, no hour/day effort estimates, no ASCII-art diagrams; counts are inventory only
- All steering files `inclusion: manual`, every file reachable from the POWER.md dispatch table, no `fileMatch` and no transclusion
- Ground rules hold: findings are evidence for modernization specialists; no go/no-go decision tables; no failure case studies
- When Java is chosen, no ".NET first, then Java" bridge pathway
- Database migration scope is never assumed in either direction
