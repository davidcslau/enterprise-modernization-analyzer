---
inclusion: manual
---

# Front-End to SPA Migration — Sizing and Risk Analysis

## Objective

Detect the application's current front-end technology, inventory what exists, and size the rewrite to
the **user-nominated** SPA framework. This file is a cross-cutting dimension, not a platform path: it
is dispatched alongside a source→target path whenever the back-end target is Java Spring Boot **and**
the user has named a front-end framework — React, Vue, Angular, Svelte or any other — or has said the
choice is not yet decided.

**This file is not loaded when the user answered "backend-only"** in POWER.md Step 1B. Backend-only is
a legitimate and common scope — plenty of programmes modernize the back end and leave the existing UI
in place — and in that case no front-end rewrite analysis belongs in the report at all.

## ⛔ The Framework Choice Is the Customer's, Not the Analyzer's

**The target framework is user input. It is never an analyzer recommendation.** This applies to
every framework, not to a shortlist of two.

- The user names the target framework in POWER.md Step 1B. Accept it as given, whatever it is —
  React, Vue, Angular, Svelte, or something else entirely.
- **Never compare frameworks.** No feature tables, no ecosystem comparisons, no hiring-pool or
  talent-availability commentary, no "safer default" or "industry standard" language, no maturity or
  popularity rankings, no benchmark comparisons.
- **Never advocate any of them**, and never imply the customer chose wrongly or should reconsider.
- Do not present a framework-selection decision, a framework evaluation matrix, or a framework
  recommendation anywhere in the report.
- Do not rank frameworks by how well AI assistants generate code for them. That comparison is
  weakly evidenced and amounts to advocacy.

**This analysis is framework-agnostic, and that is a substantive point rather than a limitation.**
Almost everything expensive in a front-end migration sits on the *source* side — the screen
inventory, whether a REST API already exists, business logic in the view layer, what does not port
cleanly, session and auth coupling. None of it changes with the target. Only a small set of
target-specific consequences varies, and those are confined to the Target-Specific Considerations
section near the end of this file.

The analyzer's job on this dimension is exactly three things: **detect what exists today, size the
rewrite, and surface the risks** of getting from here to the framework the customer has already
chosen.

### When the framework is not yet decided

"Not decided yet" is a **first-class answer**, not a blocker:

- Size the rewrite framework-agnostically. Every number in the screen inventory and every finding
  about view-layer logic, session state and non-portable capabilities is unaffected by the choice.
- Name the framework choice as an **open question requiring customer input**, alongside the other
  items in the derivable-vs-customer-input contract in `evaluation-framework.md`.
- Do **not** choose on the customer's behalf, and do not stall the analysis waiting for a decision
  it does not depend on.
- Where a target-specific consequence would change the answer — the hybrid-embedding point below is
  the main one — state it conditionally: "if the chosen framework is X, then Y follows."

Where the report needs to name the target, name what the user said: "the target React SPA", "the
target Angular SPA", and so on. Where guidance applies regardless, write "the target SPA".

## Current Front-End Detection

Detect what the application uses today. Applications frequently contain **several** of these at once —
a JSF core with a jQuery-enhanced admin area and two Struts-era screens nobody has touched in a
decade. Report the mix, not a single label.

### Java / J2EE Front-End Technologies

| Technology | Detection signals | What it means for the rewrite |
|------------|-------------------|-------------------------------|
| **JSP** | `.jsp`, `.jspf`, `.tag` files; `<jsp:` tags; `web.xml` servlet mappings | Server-rendered. Rewrite required. **Measure scriptlet density** — see below |
| **JSF / Jakarta Faces** | `.xhtml` with `xmlns:h`/`xmlns:f`; `faces-config.xml`; `FacesServlet` in `web.xml`; `@ManagedBean`, `@ViewScoped`, `@SessionScoped` backing beans | Hardest Java front end to move. Stateful component tree and view-scoped server state have no SPA equivalent |
| **JSF component libraries** | `org.primefaces`, `org.richfaces`, `com.icesoft.faces`, `openfaces` | Rich widgets (data tables with server-side paging, wizards, editable grids) must be re-implemented in the target SPA's own component library. Inventory which widgets are used |
| **Struts 1** | `struts-config.xml`; `<html:form>`, `<bean:write>`, `<logic:iterate>` tags; `ActionForm` subclasses | Tag-based server rendering plus form-bean state. Full rewrite |
| **Struts 2** | `struts.xml`; `<s:form>`, `<s:iterator>`, `<s:property>` tags; OGNL expressions in views | Full rewrite. OGNL expressions in views frequently contain logic — count them |
| **Thymeleaf** | `th:` attributes in HTML templates | Cleanest starting point of the server-rendered options; templates are already close to plain HTML |
| **Velocity / FreeMarker** | `.vm`, `.ftl`, `.ftlh` templates; `VelocityEngine`, `Configuration` beans | Template logic must be relocated — either into the API or into the SPA |
| **Tiles / SiteMesh** | `tiles.xml`, `tiles-defs.xml`, `decorators.xml` | Layout composition becomes SPA layout components and routing |
| **GWT** | `.gwt.xml` module files, `client/`/`shared/` package split, `GWT.create()` | Java compiled to JavaScript. The Java-side UI code is discarded entirely; treat as a full rewrite with no reusable front-end assets |
| **Vaadin (classic)** | `com.vaadin` dependencies, `UI` subclasses | Server-driven UI with server-held component state. Full rewrite |
| **Apache Wicket** | `.html` paired with same-named Java classes, `WebPage` subclasses | Component-oriented server rendering. Full rewrite |
| **Dojo / ExtJS / YUI** | `dojo.require`, `Ext.define`, `Ext.create`, vendored library directories | Existing client-side JavaScript. Some structure is transferable in principle, but the component model is not |
| **jQuery** | `jquery*.js`, `$(...)`, `$.ajax`, `$(document).ready` | **Look closely: this is a favourable signal.** `$.ajax` calls mean server endpoints returning data already exist — see the REST API question below |
| **Applets** | `<applet>`, `<object>` tags, `.jar` served to the browser, `java.applet` | Dead technology, removed from browsers. Requires full replacement and often a rethink of the interaction model |

### .NET Front-End Technologies

| Technology | Detection signals | What it means for the rewrite |
|------------|-------------------|-------------------------------|
| **ASP.NET Web Forms** | `.aspx`, `.ascx` user controls, `.master` master pages, `.aspx.cs`/`.aspx.vb` code-behind, `runat="server"`, ViewState | Hardest .NET front end to move. The postback and ViewState model has no SPA equivalent — every interaction is re-modelled as an explicit API call |
| **Web Forms server controls** | `<asp:GridView>`, `<asp:Repeater>`, `<asp:UpdatePanel>`, `<asp:Wizard>` | Each control's behaviour (paging, sorting, partial postback) must be re-implemented client-side. Inventory which are used |
| **ASP.NET MVC Razor** | `.cshtml`, `.vbhtml`, `@Html.` helpers, `@model` directives | Server-rendered but with a clean controller separation. Better starting point than Web Forms |
| **Razor Pages** | `.cshtml` with `@page` directive, `PageModel` classes | Similar; the handler methods often map onto API endpoints readily |
| **ASP.NET AJAX / UpdatePanel** | `ScriptManager`, `UpdatePanel`, `.asmx` script services | Partial-postback model. `.asmx` services may already be a usable data surface |
| **Silverlight** | `.xap` packages, `System.Windows.*` in a web project | Dead technology. Full replacement |
| **ActiveX controls** | `<object classid=`, `.ocx` references | Dead technology, and often wrapped a desktop or hardware capability the browser cannot reach. See "What Does Not Port Cleanly" |
| **Crystal Reports / RDLC viewers in pages** | `CrystalReportViewer`, `ReportViewer` controls | See "What Does Not Port Cleanly" |

### COBOL / Mainframe Front-End

| Technology | Detection signals | What it means for the rewrite |
|------------|-------------------|-------------------------------|
| **BMS maps / 3270 screens** | `.bms`, `.BMS` files; `DFHMSD`, `DFHMDI`, `DFHMDF` macros; `EXEC CICS SEND MAP` / `RECEIVE MAP` | See the dedicated BMS section below |
| **Screen-scraping middleware** | HLLAPI, EHLLAPI, terminal-emulator automation scripts | An existing integration layer that may already expose the transactions — worth locating |

### Already-Modern Front Ends

| Technology | Detection signals | What it means |
|------------|-------------------|---------------|
| **Existing SPA** | `package.json` with React, Vue, Angular, Svelte; `webpack.config.js`, `vite.config.*`, `angular.json` | **Detect this before assuming a rewrite.** An existing SPA may need a version upgrade or a framework change rather than a rewrite from server-rendered pages, which is a completely different piece of work. Report the framework and version found |
| **Existing REST API consumed by it** | `fetch(`, `axios`, `XMLHttpRequest`, `HttpClient` in front-end code | The API contract already exists. Inventory it — it is the most valuable asset in the whole migration |

## Screen Inventory

Produce a concrete inventory. These are **counts of what exists**, reported as inventory in section 3
(Visual Architecture State) and section 4 (Critical Findings Matrix). Per the report standards, never
convert them into an effort figure, and never use them as an effort proxy.

| Inventory item | What to count | Why it matters |
|----------------|---------------|----------------|
| **Page count** | `.jsp` / `.xhtml` / `.aspx` / `.cshtml` / `.vm` / `.ftl` files that render a full page | The primary size signal for the rewrite |
| **Partial / fragment count** | `.jspf`, `.ascx` user controls, Thymeleaf fragments, Tiles definitions, included templates | Reusable fragments often map onto SPA components more directly than pages do |
| **Form count** | `<form>` elements, `<h:form>`, `<s:form>`, `<asp:...>` form regions | Each form is a validation surface and an API contract |
| **Field count on the largest forms** | Input fields per form for the biggest screens | A 90-field screen is a different proposition from a 6-field one, and averages hide this |
| **Custom tag libraries** | `.tld` files, custom `SimpleTagSupport`/`TagSupport` classes, custom JSF components, custom Web Forms controls | **Custom tags frequently contain business logic.** Each needs reading, not just replacing |
| **Server-side includes** | `<jsp:include>`, `<%@ include %>`, `<!--#include`, Razor partials, `<asp:ContentPlaceHolder>` | Reveals the real composition structure behind the page count |
| **Master pages / templates / layouts** | `.master`, `_Layout.cshtml`, Tiles definitions, SiteMesh decorators, JSF templates | These become the SPA's layout and routing shell |
| **Navigation definitions** | `faces-config.xml` navigation rules, `struts-config.xml` forward mappings, `struts.xml` results, route tables | The existing route map, and the starting point for SPA routing |
| **Client-side script volume** | Hand-written `.js` files, inline `<script>` blocks, and which libraries are vendored | Inline script in server-rendered pages is the least portable code in the application |
| **Localization resources** | `.properties` message bundles, `.resx` files, `<fmt:message>`, `@Html.Localize` | Multi-locale UIs need the whole i18n approach re-established in the SPA |
| **Client-side validation** | `<asp:...Validator>` controls, JSF validators, Struts validation XML, jQuery Validate rules | Validation usually exists in two places (client and server) and the rules may have diverged. Report where each rule lives |
| **Accessibility features present today** | ARIA attributes, `alt` text, semantic markup, keyboard handlers, skip links | Establishes the accessibility baseline. Report what exists; a rewrite must not regress it, and a compliance obligation is a customer-input question |

## The Dominant Sizing Question: Does a REST API Already Exist?

**Establish this before anything else in this analysis, and before discussing full SPA versus hybrid.**
It is the single largest determinant of what the front-end work actually is, and getting it wrong
misstates the whole programme.

### Determine which of these three positions applies

**Position 1 — A usable API already exists.**

Signals: `@RestController` / `@RequestMapping` returning data, JAX-RS resources, `ApiController`,
`.asmx` script services, `$.ajax` or `fetch` calls in existing pages, an OpenAPI/Swagger document, a
WSDL for data services, a mobile app consuming the same back end.

Consequence: **the SPA largely drops in against it.** The work is front-end work — build the SPA
against existing endpoints, close whatever gaps the UI needs, and retire the server-rendered pages.
Business logic stays where it is.

Verify rather than assume: check the endpoints actually return **data** (JSON/XML) rather than HTML
fragments, and that they cover the screens in scope rather than one convenient corner of them. Report
the coverage honestly — "an API exists for 12 of 40 screens" is a materially different finding from
"an API exists".

**Position 2 — No API, and the view layer holds business logic.**

Signals: JSP scriptlets containing calculations or decisions, JSF backing beans doing domain work, Web
Forms code-behind with business rules, database access from within a page or code-behind.

Consequence: **this is a front-end rewrite PLUS a business-logic extraction workstream**, and the
second part is frequently larger than the first. The API does not exist and cannot simply be exposed —
it has to be *created* from logic currently embedded in pages, which means finding it, extracting it,
and proving it still behaves the same way.

**Position 3 — No API, but business logic is cleanly separated in a service layer.**

Signals: pages and code-behind that only bind and render, with all rules in service classes.

Consequence: **a front-end rewrite plus an API layer over existing services.** The API needs designing
and building, but the logic is already isolated, so it is a genuinely smaller proposition than
Position 2.

### Report this explicitly and do not conflate the three

**These are materially different efforts and the report must not blur them.** State which position
applies, with the evidence for it. Where different parts of the application sit in different
positions — common in a large estate — say so per module rather than averaging into a single
misleading answer.

The distinction to make unmistakable: **"the SPA drops in against an existing API" and "the SPA
requires business logic to be extracted out of the view layer first" are not variations of the same
task.** Presenting Position 2 as a front-end project understates it substantially, and that
understatement is one of the more consequential errors this analysis can make.

## Full SPA vs Hybrid

Both are viable. **Present both with their consequences and let the customer choose** — this is a
scope and risk-appetite decision that belongs to them and their modernization specialists, not to the
analyzer. Do not rank them, score them, or nominate one as recommended.

### Full SPA + REST/GraphQL API

The server renders no HTML. The SPA owns all rendering and routing; the back end serves data only.

| Consequence | Detail |
|-------------|--------|
| Scope | A **complete** front-end rewrite. Every screen in scope is rebuilt |
| Cutover | Tends toward a bigger-bang transition per functional area, since a screen cannot be half-migrated |
| API requirement | The API must cover every screen before that screen can go live |
| Session model | Forces the stateless model early — see Session and Auth below |
| End state | Clean separation, independent deploy cadence for front and back end, and a front end that can serve other clients too |
| Risk concentration | Front-loaded. Little user-visible progress until the first area is complete |

### Hybrid — SPA Components Inside Server-Rendered Pages

Existing server-rendered pages remain, with SPA components mounted into specific regions, migrating
outward over time.

| Consequence | Detail |
|-------------|--------|
| Scope | Incremental. High-value or high-churn screens can move first, and low-value screens may never move |
| Cutover | Continuous. Each component ships independently, so progress is visible early |
| API requirement | Only for the regions being migrated, so the API grows with the UI |
| Session model | Server-side session survives during the transition, deferring the stateless change — which is also a deferred risk, not an avoided one |
| End state | Two rendering models coexisting, potentially for a long time. Two build pipelines, two sets of conventions, and duplicated concerns like validation and formatting |
| Risk concentration | Spread out, but sustained. The transitional state has its own carrying cost, and "temporary" hybrid states have a way of persisting |

### What genuinely constrains the choice

Report these as evidence rather than as a recommendation:

- **JSF and Web Forms resist hybridisation.** Their stateful component trees and postback lifecycles do
  not coexist comfortably with client-side components owning part of the page. Mounting a SPA component
  inside a JSF view or an `UpdatePanel` is possible but fights both frameworks. Where the current front
  end is JSF or Web Forms, say plainly that hybrid is harder here than the general case suggests.
- **JSP and Razor hybridise more readily.** A `<div id="app-root">` in a JSP or `.cshtml` page with a
  mounted component is a well-trodden pattern.
- **Position 2 above (no API, logic in views) makes both options carry the extraction workstream.**
  Neither approach avoids it. Presenting hybrid as a way to sidestep the extraction is wrong, and
  worth stating explicitly because it is a tempting misreading.

## Business Logic in the View Layer

**This is routinely the hidden bulk of the effort.** Quantify it rather than describing it, because a
qualitative statement here is too easy to discount.

### What to scan for

| Source | Pattern | How to quantify |
|--------|---------|-----------------|
| **JSP scriptlets** | `<% ... %>`, `<%= ... %>`, `<%! ... %>` declarations | Count scriptlet blocks and the pages containing them. **Report scriptlet density** — blocks per page, and which pages are worst |
| **JSP scriptlets doing data access** | `Connection`, `Statement`, `ResultSet`, `DriverManager` inside a `.jsp` | Count separately. This is the most severe form: logic *and* data access in the view |
| **JSF backing beans doing domain work** | `@ManagedBean` / `@Named` classes containing calculations, validation rules, or repository calls beyond view coordination | Count beans and identify which methods are domain logic rather than view state |
| **Web Forms code-behind** | `.aspx.cs` / `.aspx.vb` containing calculations, business rules, or data access | Count files and identify the rule-bearing methods. Distinguish event wiring from domain logic |
| **Struts Action classes** | `execute()` methods containing business rules rather than delegating to a service | Count actions with embedded logic |
| **OGNL / EL expressions containing logic** | Arithmetic, conditionals or method chains inside `${...}` or `<s:property value="...">` | Count expressions that compute rather than read |
| **Custom tags and controls** | Custom `.tld` tag handlers, custom JSF components, custom Web Forms controls | Read each one. Custom tags are a favourite hiding place for business rules |
| **Validation rules in the view** | Validator controls, client-side rules, inline checks in pages | Count rules, and flag any that exist **only** in the view — those are rules with no server-side enforcement, which is both a migration finding and a security observation |
| **Formatting and calculation in templates** | Currency, date, rounding, tax or total computation inside templates | Count occurrences. Rounding and currency logic in a view is a correctness risk when relocated |

### How to report it

- Give the counts, and name the **specific worst offenders** by file with what they contain
- State the consequence explicitly: logic in the view layer means the SPA migration includes a
  business-logic extraction workstream, and the API surface has to be **designed** rather than
  exposed
- Flag **duplicated and possibly diverged rules** — the same calculation in three pages that no
  longer agree. This is a correctness risk during extraction, not just untidiness, and the customer
  will need to decide which version is right
- Connect it to B4 in `evaluation-framework.md`, which asks the same question at the whole-application
  level. This section is the front-end-specific depth behind that finding

## Session and Auth Interaction

The front-end model and the session model are coupled. A SPA plus stateless horizontal scaling cannot
be reached while the application depends on server-held session state, so these findings belong
together.

### Session state

| Current model | Detection | Consequence for a SPA target |
|---------------|-----------|------------------------------|
| **In-process HTTP session** | `HttpSession` / `Session[...]` writes, `session.setAttribute`, `@SessionScoped`, `@ViewScoped`, Web Forms `Session` | **Blocks stateless scaling.** Either externalise the session (ElastiCache, DynamoDB, Spring Session) or move the state to the client and to tokens |
| **Sticky sessions** | Load-balancer configuration, `jsessionid` in URLs, session affinity settings | Same constraint, plus a deployment dependency that has to be removed before replicas are interchangeable |
| **Large session objects** | Whole result sets, shopping carts or wizard state in session | The SPA target usually holds this client-side. Inventory what is in session — this is design input for the SPA, not just a technical detail |
| **JSF view state** | `@ViewScoped` beans, `javax.faces.ViewState` hidden fields, server-side state saving | **A specific and severe case.** The component tree itself lives on the server between requests, with no SPA equivalent. Every view-scoped interaction is redesigned |
| **Web Forms ViewState** | `__VIEWSTATE` hidden fields, `ViewState[...]` usage | Same character: page state round-tripped through the browser. Interactions become explicit API calls with client-held state |
| **Already stateless** | Tokens only, no session writes | No constraint. Report it as a favourable finding |

### Authentication

| Current mechanism | Detection | Target |
|-------------------|-----------|--------|
| **Container-managed auth** | `<security-constraint>`, `<login-config>`, `FORM` auth with `j_security_check` | JWT or OAuth2/OIDC with Amazon Cognito; declarative constraints become API-level authorization |
| **JAAS** | `LoginModule` implementations, JAAS configuration | Spring Security. Custom login modules are application code and must be rewritten |
| **Windows Authentication** | `<authentication mode="Windows" />`, `WindowsIdentity`, Kerberos/NTLM | Cannot survive as-is. Cognito with SAML/OIDC federation to the corporate directory |
| **Forms Authentication (.NET)** | `<authentication mode="Forms">`, `FormsAuthentication.SetAuthCookie` | Token-based auth; the cookie-and-redirect flow is replaced by an explicit login API |
| **Spring Security with server-side session** | `formLogin()`, session-based `SecurityContext` | Stateless JWT resource server, or Cognito-issued tokens |
| **LDAP / AD direct bind** | `PrincipalContext`, `InitialDirContext`, LDAP URLs | Cognito with an AD/LDAP identity source, or Spring Security LDAP behind the API |

### Consequences a SPA introduces that server-rendered pages did not have

Cover each of these explicitly — they are new concerns, not carried-over ones, and they are commonly
discovered late:

- **Token storage in the browser.** Where the token lives (in-memory, `sessionStorage`,
  `localStorage`, or an HttpOnly cookie) is a security decision with real consequences: `localStorage`
  is readable by any script on the page, so an XSS becomes a token theft. Report the decision as one
  the customer's security function must make, and state the trade-off rather than picking for them.
- **CSRF — and note the Spring Security 7 default changed.** The server-rendered synchroniser-token
  pattern (hidden form fields, `<form:form>` tokens, `__RequestVerificationToken`) does not carry over
  unchanged. A token-in-header API has a different CSRF posture from a cookie-authenticated one — and a
  cookie-authenticated SPA still needs CSRF protection. Inventory the existing CSRF mechanism so it is
  replaced deliberately rather than dropped by accident.

  **⚠️ High-priority finding on a Spring Boot 4.1 target.** Spring Security 7 **applies CSRF protection
  to API endpoints by default**. A stateless REST API that never sent a CSRF token — which is the normal
  shape of an API behind a SPA — starts returning **403** until it is explicitly configured. This is a
  new default, not a carried-over one, and it bites at exactly the seam this file owns: the first time
  the new SPA calls the new back end. Report it in section 4 with the remedy named (configure the CSRF
  policy deliberately for the chosen auth model — disabled with justification for token-in-header
  stateless APIs, or a token repository for cookie-authenticated ones), and flag that it will surface
  during integration rather than at build time.

- **CORS.** Once the SPA is served from a different origin than the API — S3/CloudFront in front of a
  Spring Boot back end, for example — CORS configuration becomes load-bearing. Note whether the
  chosen serving model creates a cross-origin situation at all, since serving the SPA from Spring
  Boot's static resources avoids it.
- **Session timeout and renewal UX.** Server-rendered pages could redirect to a login page on
  timeout. A SPA has to detect expiry, refresh silently or prompt, and avoid losing in-progress form
  data. Where long-running data entry exists in the current screens, flag it.
- **Authorization granularity.** Page-level `<security-constraint>` rules become API endpoint
  authorization plus client-side route guards. Client-side guards are cosmetic — the API must enforce
  everything. Flag any authorization that currently exists **only** as a page constraint or a hidden
  menu item, because that is authorization that will be missing once the API is directly reachable.

## What Does Not Port Cleanly

**Treat this as its own risk class**, reported together in section 4 rather than scattered. These are
capabilities the current UI has that a SPA does not straightforwardly reproduce. Each needs a named
replacement approach, and several may point at the EC2 legacy sidecar pattern.

| Capability | Detection | Why it does not port | Replacement direction |
|------------|-----------|---------------------|----------------------|
| **Crystal Reports viewers** | `CrystalReportViewer`, `CrystalDecisions.*`, `.rpt` files | Windows-bound rendering engine embedded in the page | A reporting service behind an API returning PDF/data, or isolate on a legacy host |
| **SSRS / RDLC report viewers** | `ReportViewer`, `.rdlc`, SSRS endpoints | Server control with its own rendering and paging model | Keep SSRS behind an API and render the output, or rebuild on a Java/JS reporting stack |
| **JasperReports embedded in pages** | `net.sf.jasperreports`, `.jrxml` | Server-side rendering tied to the page lifecycle | Generate server-side, deliver as a download or an embedded viewer |
| **Server-side PDF generation tied to the page** | iText, PDFBox, `Response.BinaryWrite`, `application/pdf` writes from a page | Depends on server-held page context | An explicit API endpoint returning the document |
| **Print-oriented pages** | `window.print()`, print-only CSS, print-specific layouts, pagination for paper | Print layout is a genuine design surface, not just CSS | Deliberate print stylesheets in the SPA, or server-generated PDF. Do not assume it comes for free |
| **File upload flows** | `<input type="file">`, `multipart/form-data`, `HttpPostedFile`, Struts `FormFile`, JSF file components | Progress, chunking, resume, size limits and virus scanning all become explicit client concerns | Direct-to-S3 presigned uploads, or an API endpoint with client-side progress handling |
| **File download flows** | `Content-Disposition` writes, streaming from a page, session-dependent download links | A SPA cannot simply navigate to a session-protected stream and keep its auth model clean | Presigned S3 URLs, or an authenticated download endpoint |
| **Excel export** | `Microsoft.Office.Interop.Excel`, Apache POI in a page, `application/vnd.ms-excel` writes | Often built from server-held page state | Server-side generation behind an API, or client-side generation from the API data |
| **Excel or Word interop** | `Excel.Application`, `Word.Application` | Requires Office installed on the server; Windows-only | OpenXML, Apache POI, or a document service |
| **Applets** | `<applet>`, `<object>` with Java, `.jar` served to browsers | Removed from all browsers | Full replacement, usually with an interaction rethink |
| **ActiveX controls** | `<object classid=`, `.ocx` | Removed from modern browsers; Windows and IE only | Full replacement. **Check what capability it provided** — often hardware access such as scanners, card readers or signature pads, which the browser may not be able to reach at all. Flag as potentially unresolvable |
| **Browser plugins generally** | Flash, Silverlight, custom NPAPI/ActiveX | Removed from browsers | Full replacement |
| **Signed applets or plugins for device access** | Applet or ActiveX touching local hardware, drivers, smartcards, USB devices | The browser security model does not allow it | May require a local companion application or a hardware-specific web API. **Flag as a possible hard constraint requiring customer input** |
| **Windows Integrated Auth in the browser** | Kerberos/NTLM negotiation, no login page | Depends on the browser and server sharing a Windows domain context | Federated identity via Cognito. The seamless-SSO user experience must be explicitly re-created |
| **Frames and iframe-composed screens** | `<frameset>`, `<frame>`, iframe-based navigation, cross-frame scripting | `<frameset>` is obsolete; cross-frame coupling breaks under SPA routing | SPA layout components and routing |
| **Modal dialogs via `window.showModalDialog`** | `showModalDialog` | Removed from browsers | SPA modal components; note the synchronous-return semantics do not exist and calling code changes shape |
| **Server-push and long-polling** | Comet, hidden-iframe streaming, `UpdatePanel` polling, SignalR | Older mechanisms have no direct SPA equivalent | Server-Sent Events, WebSockets, or RSocket |
| **Deep links to server URLs** | Bookmarked `.aspx`/`.jsp` URLs, emailed links, links from other systems | SPA routing changes URL structure | **Plan redirects.** Inventory externally-known URLs — other systems and users' bookmarks depend on them, and this is easy to discover only after cutover |

## Target-Side Patterns

Cover these as the mechanics of getting to the chosen SPA. Where a choice exists, present the options
with consequences rather than nominating one.

### BFF (Backend-for-Frontend)

A dedicated API layer shaped for the SPA's needs, sitting in front of the domain services.

- Lets the SPA make one call where the domain would require several, which matters most where the
  current screens are dense and aggregate a lot of data
- Keeps SPA-specific shaping out of the domain services, so the domain API stays reusable
- Adds a component to build, deploy and maintain
- Worth flagging specifically where the screen inventory shows **wide screens aggregating many
  sources** — a 90-field screen assembled from six tables is exactly the case a BFF addresses

### Front-End Build Integrated Into the Java Build

The SPA's npm/Vite build has to run somewhere. Two established options:

| Option | Mechanics | Consequences |
|--------|-----------|--------------|
| **Integrated into Maven/Gradle** | `frontend-maven-plugin` or a Gradle Node plugin runs the npm/Vite build during the Java build and packages the output into the artifact | One artifact, one pipeline, one version. Slower Java builds, and the Java build now depends on Node and the npm registry |
| **Separate front-end pipeline** | The SPA builds and deploys independently | Faster, independent cadences; front-end developers are not blocked by the Java build. Requires version and contract coordination between two deployables |

### Serving the SPA

| Option | Mechanics | Consequences |
|--------|-----------|--------------|
| **Spring Boot static resources** | Built assets packaged in `src/main/resources/static` and served by the application | Same origin, so **no CORS**. Simplest deployment and auth story. Couples front-end releases to back-end releases, and application instances serve static files |
| **S3 + CloudFront** | Assets uploaded to S3, served via CloudFront, API called cross-origin | Better caching, global edge delivery, cheaper at scale, independent front-end deploys. Requires CORS configuration, and cookie-based auth becomes cross-origin — which interacts with the token-storage decision above |

State which of these the chosen serving model implies for CORS and auth, since that connection is
frequently missed.

### Route-by-Route Strangler Migration of the Front End

The front-end counterpart of the strangler pattern: a router or reverse proxy in front of both the
legacy application and the new SPA, directing each route to whichever implementation owns it, and
moving routes across one at a time.

- Implemented with CloudFront behaviours, ALB listener rules, or API Gateway routing
- Lets a single screen or functional area migrate and go live independently
- **Requires the session and auth story to work across both sides for the duration** — this is the
  hard part, and the report should say so. Both implementations must accept the same identity, which
  usually means the token/session bridge is designed up front, not improvised
- Shared concerns during the transition: consistent navigation, consistent styling, and users being
  handed between two UIs without noticing
- Report the routing inventory (from the navigation definitions in the screen inventory) as the
  candidate migration sequence

### OpenAPI Contract Generation as the Workstream Seam

Where the front-end and back-end workstreams proceed in parallel, the API contract is the seam between
them, and it needs to be an artifact rather than an understanding.

- Generate an OpenAPI document from the back end (springdoc-openapi) or write it contract-first and
  generate both sides from it
- The contract lets the SPA be built against a mock while the real endpoints are still in progress,
  which is what makes genuine parallel work possible
- Generated typed clients keep the SPA aligned with the API as it changes
- Where the existing integrations already have documented contracts (see B9 in
  `evaluation-framework.md`), those documents are the starting point
- Recommend the contract as the seam wherever the analysis shows the two workstreams running in
  parallel, and note that without it the two teams discover their disagreements late

### Accessibility and Browser Support

- Report the accessibility features present today (from the screen inventory) as the baseline the
  rewrite must at least preserve
- Whether a formal accessibility standard applies is a **customer-input question** — do not assume one,
  and do not assert a compliance level. Full accessibility validation requires manual testing with
  assistive technologies and expert review, which is outside what a code analysis can determine
- Report the browser support the current application requires, especially where IE-only constructs
  were found. A dependency on IE-era behaviour is a finding in its own right

## COBOL BMS Map / 3270 Screen Mapping

Where the source platform is COBOL/Mainframe, the front end is a set of BMS maps driving 3270
terminal screens. This is a genuinely different starting point from a web UI, and mapping it needs its
own treatment. Referenced from `cobol-to-java.md`.

### What to extract from the BMS source

BMS maps are declarative screen definitions, which makes them a better migration input than most
server-rendered page technologies — the field structure, positions, lengths and attributes are all
explicit rather than buried in markup.

| BMS construct | What it defines | SPA equivalent |
|---------------|-----------------|----------------|
| `DFHMSD` | Mapset — a group of maps, with storage and language options | A feature area or route group in the SPA |
| `DFHMDI` | Map — one screen, with size and positioning | One SPA view / route |
| `DFHMDF` | Field — position, length, attributes, initial value, picture | One form field or display element |
| `POS=(row,col)` | Absolute row/column position on the 24×80 (or 27×132) grid | Layout position. **Do not reproduce the grid literally** — translate the *grouping* the layout expresses into a responsive layout |
| `LENGTH=` | Field length in characters | Input `maxlength` and the validation rule behind it |
| `ATTRB=(PROT)` / `UNPROT` | Protected (display-only) vs unprotected (enterable) | Read-only vs editable field |
| `ATTRB=(NUM)` | Numeric-only entry, enforced by the terminal | Input type and client-side validation rule |
| `ATTRB=(BRT)` / `NORM` / `DRK` | Bright / normal / dark (non-display) intensity | Emphasis styling; `DRK` usually means a password or hidden field |
| `ATTRB=(ASKIP)` | Auto-skip — cursor jumps past the field | Tab order and focus management |
| `ATTRB=(FSET)` / `MDT` | Modified Data Tag — whether the field was changed | **Dirty-field tracking.** The SPA equivalent is form dirty state, and the semantics matter: MDT-based programs often act only on changed fields |
| `PICIN` / `PICOUT` | Input/output picture — implicit formatting and decimal placement | Display formatting and parsing rules. **Read these carefully**: an implied decimal (`PIC 9(5)V99`) means the terminal showed a decimal point the data does not contain |
| `COLOR=`, `HILIGHT=` | Colour and highlighting, frequently encoding meaning (red for error, reverse video for a required field) | The **meaning** must be preserved, not the colour choice. Establish what each convention signified |
| `INITIAL=` | Literal text — labels, headings, instructions | Static labels and help text; also the source of the screen's terminology |
| `MAPSET` / map name in `SEND MAP` / `RECEIVE MAP` | Which program shows which screen | The navigation graph between views |

### The mapping approach

1. **Inventory the maps.** Count mapsets, maps per mapset, and fields per map. Identify the largest
   and most complex screens — a 24×80 screen packed with 60 fields is a dense data-entry surface
2. **Build the screen flow graph** from `EXEC CICS SEND MAP` / `RECEIVE MAP` calls and the
   pseudo-conversational transaction transfers (`XCTL`, `RETURN TRANSID`) between programs. This is the
   route map for the SPA, and it is derivable from the code
3. **Extract the field model** — name, length, type, picture, attributes — as the API contract and the
   form model. This is the most mechanical and reliable part of the whole COBOL front-end migration
4. **Recover validation rules from two places**: BMS attributes (`NUM`, `LENGTH`, `PROT`) give the
   terminal-enforced rules, and the COBOL program gives the rest. **The program-side rules are the
   substantive ones** and they are not in the map at all — they are in the `PROCEDURE DIVISION`, which
   is why this analysis pairs with the business rule extraction in `cobol-to-java.md`
5. **Re-express the interaction model.** 3270 is a full-screen send/receive cycle with AID keys
   (`ENTER`, `PF1`–`PF24`, `CLEAR`, `PA1`). The SPA equivalent is form submission plus explicit
   actions. **Inventory the PF-key conventions** — `PF3=Exit`, `PF7/PF8=Page Up/Down`, `PF12=Cancel`
   are conventions users know by muscle memory, and they need deliberate equivalents in the new UI
6. **Handle the pseudo-conversational model.** State between screens lives in the CICS COMMAREA or
   temporary storage rather than in the program. Inventory what is carried there — it is the
   equivalent of session or client-side state and it is design input for the SPA

### COBOL-specific findings to report

- **Screen density and field counts** — mainframe screens routinely carry far more fields per screen
  than a typical web page, and re-laying them out is a UX design task the customer will need to
  resource, not something the migration resolves mechanically
- **Terminology from `INITIAL=` literals** — abbreviated to fit 80 columns (`CUST NBR`, `TRN DT`).
  Expanding these into meaningful labels requires business input; do not invent expansions
- **Numeric field semantics** — implied decimals, signed overpunch, `COMP-3` packed fields. Getting
  these wrong produces silently incorrect values in the new UI
- **EBCDIC-related considerations** — collation order differences and any characters used with
  special meaning
- **Existing screen-scraping integrations** — where middleware already drives these screens
  programmatically, other systems depend on the exact screen layout, and changing the UI breaks them.
  This is a coupling finding that belongs in the integration inventory (B9)

## Target-Specific Considerations

Everything above this point is framework-agnostic. These are the only places where the chosen
framework changes the analysis. State them as **consequences of the customer's own combination of
choices**, never as reasons to pick differently.

### Hybrid embedding is not equally easy in every framework

This matters because "hybrid" in this file means precisely *SPA components embedded in existing
server-rendered pages*, so the framework interacts directly with a strategy we present.

Vue has a documented advantage for integrating into existing server-rendered applications —
progressive adoption into a page that already exists is a first-class use case for it. React is
entirely capable of the same thing, but its centre of gravity is the full application, so mounting
islands into legacy pages tends to involve more build and bundling setup. Angular's structure and
bootstrap model make partial embedding the least natural of the three, and it is most at home owning
the whole application shell.

**How to report it:** if the customer has chosen hybrid **and** a framework whose strengths lie in
owning the full page, say that the combination carries additional friction, and quantify it in terms
of the build and bootstrap setup involved. Do **not** suggest changing framework, and do **not**
suggest changing strategy. Both are the customer's decisions; the interaction between them is
evidence.

If the framework is **undecided** and hybrid is the likely strategy, note that the two decisions
interact and should be taken together rather than separately.

### Choosing a framework increasingly means choosing a meta-framework

The prevailing pattern pairs each framework with a meta-framework — React with Next.js, Vue with
Nuxt, Svelte with SvelteKit, and Angular with its own full-stack tooling. A large share of new React
applications are built on Next.js rather than React alone.

This matters to a migration because a meta-framework brings decisions a plain SPA does not:

| Concern | Plain SPA | With a meta-framework |
|---------|-----------|----------------------|
| Rendering | Client-side only | Server-side rendering and hydration, with its own runtime |
| Routing | A client-side router | File-system routing, which shapes project structure |
| Hosting | Static assets from Spring Boot resources, or S3 + CloudFront | Needs a Node runtime, so a second deployable alongside the Spring Boot service |
| Build integration | Fits the npm/Vite-into-Maven pattern described above | More involved; the Node server becomes part of the deployment topology |

**Ask whether a meta-framework is in scope**, because it changes the target architecture diagram and
the deployment model, not just the front-end code. If the customer has not considered it, that is an
open question worth naming rather than an omission to fill in.

### Component-library continuity is a source-side finding

Whether the legacy component library has a successor is decided by what the application uses **today**,
not by the target:

| Current library | Continuity position |
|-----------------|--------------------|
| **PrimeFaces** | Same-vendor ports exist for both React and Vue, with recognisably similar component semantics. The most favourable starting point of the JSF options |
| **RichFaces** | End-of-life with no successor in any target framework. Every component is re-implemented |
| **IceFaces** | No successor in any target framework |
| **Vaadin (classic)** | Server-driven component model with no SPA equivalent; Vaadin Flow keeps you in Java rather than moving to a SPA |
| **ExtJS / Dojo / YUI** | Commercial or legacy JS component suites. Data grids are the usual sticking point |
| **ASP.NET Web Forms server controls** | `GridView`, `Repeater`, `UpdatePanel` and wizards each need a client-side equivalent built or bought |

**The recurring hard case is the enterprise data grid.** Legacy screens frequently rely on
server-side paging, sorting, filtering, inline editing, grouping and export in a single component.
Equivalents exist for every major framework, several commercially licensed. Inventory which grid
features are actually used — that inventory, not the framework choice, is what sizes the work. Where
a commercial grid licence would be needed, note it as a dependency finding for section 5.

## Validation Checklist

A front-end migration analysis is complete when:

1. Every front-end technology present is detected and reported, including mixes and any already-modern SPA
2. The screen inventory is produced with concrete counts — pages, fragments, forms, fields on the largest forms, custom tag libraries, includes, master pages/layouts, navigation definitions
3. **The REST API question is answered explicitly**, with the position (1, 2 or 3) stated, the evidence for it, and honest coverage where an API exists only partially
4. Full SPA and hybrid are both presented with consequences, neither ranked or recommended, and the JSF/Web Forms hybridisation constraint stated where it applies
5. Business logic in the view layer is **quantified**, with the worst offenders named and duplicated/diverged rules flagged
6. Session state is reported with its consequence for stateless scaling, including JSF view state and Web Forms ViewState where present
7. The auth mechanism is mapped to a target, and the token-storage, CSRF, CORS, timeout and authorization-granularity consequences are all covered
8. Everything that does not port cleanly is reported **as one risk class**, with a named replacement direction for each item and any potentially unresolvable items flagged for customer input
9. Target-side patterns are covered — BFF where screen density warrants it, build integration options, serving options with their CORS/auth implications, strangler routing with the cross-cutting session/auth requirement, and OpenAPI as the workstream seam
10. Externally-known URLs are inventoried where deep links exist
11. The accessibility baseline present today is reported, with formal compliance obligations named as a customer-input question
12. **No comparison of frameworks appears anywhere** — no feature tables, hiring-pool commentary, popularity rankings or AI-codegen comparisons — and no framework recommendation is made. The user's chosen framework is used throughout, or the choice is named as an open question where undecided
13. All counts are presented as inventory, never as effort estimates, and no dollar amounts appear
14. Findings surface in existing report sections 3 and 4; no new report section is introduced
