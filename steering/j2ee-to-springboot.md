---
inclusion: manual
---

<!--
  Shared target-architecture module. Dispatched explicitly by the dispatch table
  in POWER.md Step 2, alongside websphere-to-springboot.md,
  weblogic-to-springboot.md, wildfly-to-springboot.md or
  dotnet-to-springboot.md.

  Do NOT switch this file to `always` or to pattern-matched inclusion, and do
  not pull it in with steering file-reference transclusion. Explicit dispatch
  from POWER.md Step 2 is the only loading mechanism used by this power.
-->

# J2EE to Spring Boot Migration - Common Patterns

This steering file contains common migration patterns shared between the WebSphere, WebLogic and WildFly/JBoss EAP paths to Spring Boot Reactive migrations, together with the J2EE and Java analysis depth required on all three.

## Required J2EE / Java Analysis Depth

**Mandatory for every path that loads this file** — WebSphere, WebLogic and WildFly/JBoss EAP. It
sits on top of the universal Mandatory Baseline Inventory in `evaluation-framework.md`, and the
vendor-specific detection in the platform steering file does not replace it.

The plain-Java path (`java-to-springboot.md`) does not load this file and carries its own equivalent
section.

### Application Server, Version and javax/jakarta Position

Report the server and version precisely, and state its namespace position, because together they
decide how many upgrade stages are unavoidable:

| Server / container | Namespace | Jakarta EE level | Distance to the Boot 4.1 target |
|--------------------|-----------|------------------|--------------------------------|
| Tomcat 8.5 / 9.x | `javax.*` | EE 8 | Namespace migration, then the EE 11 step. Boot 2.x is the ceiling until the rename happens |
| Tomcat 10.0 / 10.1 | `jakarta.*` | EE 9 / 10 | Rename done; still an EE 11 version step. Boot 3.x ceiling |
| **Tomcat 11** | `jakarta.*` | **EE 11 (Servlet 6.1)** | **On the target baseline** — Boot 4.x reachable |
| WildFly 26 and earlier, JBoss EAP 7.x | `javax.*` | EE 8 | Namespace migration, then the EE 11 step |
| WildFly 27+, JBoss EAP 8 | `jakarta.*` | **EE 10** | Rename done, but **not** on the EE 11 baseline — still a version step to Boot 4 |
| JBoss AS 5/6, EAP 5/6 | `javax.*`, older EE profile | pre-EE 8 | Furthest away; expect EJB 2.x and legacy security |

**Note the EE 10 trap.** WildFly 27+ and JBoss EAP 8 are frequently described as "already on
Jakarta EE", and that was sufficient for Spring Boot 3. Spring Boot 4 raises the baseline to
**Jakarta EE 11** — Servlet 6.1, JPA 3.2, Bean Validation 3.1 — so an EE 10 application is closer
than a `javax.*` one but is **not** on the target baseline. Report the EE level, not just the
namespace, so this does not get lost.

**The consequence to state explicitly:** reaching Spring Boot 4.1 from a `javax.*` Java 8
application is a **three-stage** sequence — Java 8 → 21/25, then Spring Boot 2.7 → 3.5 for the
namespace rename and deprecation cleanup, then 3.5 → 4.1 for Jakarta EE 11, starter modularisation,
Jackson 3 and Spring Security 7. Each stage carries its own validation cycle.

**Stage 2 is mandatory even though Boot 3.5 is out of OSS support** (ended 30 June 2026). Boot 4
removes every API deprecated anywhere in Boot 3.x with no grace period, and only Boot 3.x emits the
deprecation warnings that tell you what to fix — so the cleanup has to happen on 3.5 with
deprecation-as-error enabled. Boot 3.5 is a **transit version, not a destination**; do not let "3.x
is EOL" be read as "skip it".

Where the application is already on `jakarta.*` and Java 21+, the sequence collapses to stage 3
alone. This is one of the highest-value findings on any Java path — do not leave the reader to
infer it.

### Framework Stack and Its Migration Cost

| Current stack | Migration character |
|---------------|---------------------|
| **Spring MVC** (already Spring) | **Upgrades most readily.** Often a version and configuration migration rather than a rewrite |
| **CDI + JAX-RS** (typical modern WildFly) | Translates mechanically — CDI maps onto Spring DI, JAX-RS onto Spring REST |
| **Struts 1** | End-of-life, no upgrade path. **Full rewrite** of the web layer; Struts 1 Actions and ActionForms have no equivalent |
| **Struts 2** | No forward path to Spring MVC. Materially more rewriting than Spring MVC, including the interceptor stack and OGNL expressions in views |
| **JSF** (Facelets, PrimeFaces / RichFaces / IceFaces) | **Materially more rewriting.** The stateful component model and backing-bean lifecycle have no Spring MVC equivalent. Almost always implies a front-end rewrite too |
| **Plain Servlet/JSP** | Mechanical but pervasive; business logic in scriptlets must be extracted first |
| **Seam** (older JBoss stack) | End-of-life. Full rewrite; Seam conversations and page-flow have no successor |

### J2EE / Jakarta API Usage

Inventory which APIs are in use and report each with its target:

| API | Target | Migration note |
|-----|--------|----------------|
| **EJB 2.x** (home/remote interfaces, `EJBHome`, CMP entity beans, `ejb-jar.xml` deployment) | Spring `@Service` and Spring Data | **Flag as the hardest single construct to migrate.** Home interfaces, CMP entity beans and the container-managed lifecycle have no equivalent and require redesign, not translation |
| **EJB 3.x** (`@Stateless`, `@Stateful`, `@Singleton`) | Spring `@Service` / `@Component` | Much closer to Spring; largely mechanical for stateless beans |
| **JMS** | Amazon MQ / SQS / MSK | Destination topology and delivery guarantees must be re-established explicitly |
| **JPA** | Spring Data JPA or R2DBC | **Direct Spring equivalent.** Provider version upgrade is the main work |
| **JTA** | Spring `@Transactional` | Single-resource transactions map cleanly; distributed XA needs Saga or Outbox |
| **JNDI** | Spring dependency injection and configuration | Every lookup becomes an injected bean plus configuration |
| **JAX-RS** | Spring WebFlux / Spring MVC REST | Annotation-level translation; the API contract is preserved |
| **JAX-WS / SOAP** | **Needs rework.** Spring WS, Apache CXF, or re-expose as REST | No clean Spring-native equivalent. WSDL contracts and consumers constrain what can change |
| **CDI** | Spring DI | **Direct Spring equivalent** — the closest mapping in the whole J2EE surface |
| **JAAS** | Spring Security | Custom login modules are application code and must be rewritten |
| **JCA resource adapters** | Purpose-built client, or isolate behind an API | Rare but high-effort where present |
| **JBatch (JSR-352)** | Spring Batch | Concepts map reasonably well |

### Removed-API Usage — Blocks the JDK Upgrade

These were removed in Java 11 (and some in Java 9) and each needs a sourced replacement. Scan for
them explicitly; they are a common cause of a stalled JDK upgrade:

| Removed API | Replacement |
|-------------|-------------|
| `javax.xml.bind.*` (JAXB) | `jakarta.xml.bind` plus a runtime implementation, added as an explicit dependency |
| `javax.activation.*` | `jakarta.activation` as an explicit dependency |
| `javax.xml.ws.*` (JAX-WS) | `jakarta.xml.ws` plus an implementation, or migrate off SOAP |
| CORBA (`javax.rmi.CORBA`, `org.omg.*`) | Removed with no successor. Requires redesign onto REST or gRPC |
| `javax.transaction.*` (the JDK-bundled subset) | `jakarta.transaction` as an explicit dependency |
| `sun.*` internal packages (`sun.misc.*`, `sun.security.*`, `com.sun.image.*`) | Supported public API equivalents; each usage needs individual assessment |

### Libraries Reaching Into Removed JDK Internals

Distinct from the above, and easier to miss because the application's own source is clean: a
**dependency** compiled for Java 8 may itself reach into internals that later JDKs removed or closed
off.

- `sun.misc.Unsafe` — heavily used by older versions of Netty, Guava, Hibernate, Kryo, Jackson and many caching libraries
- Reflective access into `java.*` internals — produces illegal-reflective-access warnings on Java 11 and hard failures on Java 17 and later
- Bytecode manipulation libraries (ASM, cglib, Javassist, ByteBuddy) at versions predating the target JDK's class file format
- Any library with no release since Java 8's era

**Detection approach:** for every dependency, establish whether a version supporting the target Java
release exists — that is the concrete question, and it is answerable from the registry. Where no such
version exists, the dependency becomes a blocking finding for the JDK upgrade, and belongs in
section 5 alongside the licence analysis.

## Target Architecture

All J2EE migrations target:
- Spring Boot 4.1.x with Java 21 or 25 (Java 17 is the floor, not the recommendation)
- AWS container-based deployments (ECS/EKS)
- Graviton processor optimization
- Amazon Corretto

**The concurrency model is a separate decision** — see below. It is not fixed by this file.

## Blocking or Reactive: a Decision, Not a Default

**Present both with their consequences. Rank neither, and do not recommend one.** This is the same
discipline the power applies to full-SPA-versus-hybrid and to front-end framework choice: the
analyzer supplies evidence, the customer and their modernization specialists decide.

### The starting assumption, and why it is only that

**Absent evidence to the contrary, assume blocking Spring MVC with virtual threads enabled.** That
is a default to depart from, not a verdict — state it as such.

The reasoning is specific to *migration*, and it is worth writing into the report because it does
not apply to greenfield work:

- Ported J2EE business logic is **blocking by construction** — EJB methods, servlet request
  handling, JDBC calls, synchronous JMS. Keeping it blocking means the translated code keeps the
  same shape as the original, which is exactly what a behavioural-equivalence acceptance criterion
  wants to compare.
- Rewriting that logic into Reactor operator chains stacks a **paradigm change on top of a platform
  change**. Two simultaneous changes, and the reactive one is where debuggability, stack traces and
  team-readiness problems concentrate.
- Virtual threads (Java 21+, first-class on the Java 25 target) remove the original reason most
  teams adopted reactive in the first place: thread-per-request no longer caps concurrency the way
  it did on Java 8. Published head-to-head benchmarking puts virtual threads on Netty ahead in
  roughly half of measured contests, WebFlux ahead in roughly a quarter, with the remainder
  inconclusive — which is not the decisive reactive advantage the older guidance assumed.

### When reactive earns its place

Depart from the default when the evidence supports it. These are concrete, checkable conditions,
not preferences:

| Condition | Why it favours reactive |
|-----------|------------------------|
| **Streaming or server-sent-event endpoints** | Backpressure and incremental delivery are what Reactor is for; virtual threads do not provide them |
| **Very high concurrent connection counts**, especially long-lived or idle ones | Memory per connection stays lower without a thread per request, even a virtual one |
| **The team already writes and operates reactive code** | The learning-curve and debuggability arguments largely disappear |
| **A fully non-blocking driver stack already exists** end to end | Reactive gains nothing if one JDBC call in the chain blocks, so this is a precondition rather than a benefit |
| **An existing reactive codebase** being extended | Consistency beats mixing models |

Where **none** of these hold, adopting reactive means paying Reactor's complexity for throughput the
blocking-plus-virtual-threads stack would have delivered anyway. Say so plainly.

### What each choice implies

| | Blocking Spring MVC + virtual threads | Reactive WebFlux |
|---|---|---|
| Web layer | `@RestController`, servlet stack, embedded Tomcat 11 or Jetty 12.1 | `@RestController` returning `Mono`/`Flux`, embedded Netty |
| Data access | **Spring Data JPA / Hibernate 7.4**, or `JdbcClient` | **Spring Data R2DBC**, with a reactive driver |
| Transactions | `@Transactional` — familiar semantics | Reactive transactions; no thread-bound context |
| Ported EJB logic | Translates with its shape intact | Rewritten into operator chains |
| Debugging | Ordinary stack traces | Operator-fused traces; needs Reactor tooling and habits |
| Blocking libraries | Fine — that is the point | **A single blocking call poisons the event loop.** Every driver and SDK must be non-blocking |
| Enable with | `spring.threads.virtual.enabled=true` | The WebFlux starter instead of the web MVC starter |

### Virtual threads: two findings to report if they are enabled

Virtual threads remain **opt-in** in Spring Boot 4 (`spring.threads.virtual.enabled=true`), so
enabling them is a deliberate act. Two consequences belong in the findings matrix, because both are
silent and both are common in ported legacy code:

- **Pinning.** A `synchronized` block on an I/O path pins the virtual thread to its carrier thread,
  which reproduces exactly the thread-starvation bottleneck virtual threads were meant to remove.
  Legacy Java is full of `synchronized` around caches, connection handling and encryption helpers.
  The remedy is `ReentrantLock`, which lets the virtual thread unmount while blocked. Scan for
  `synchronized` on paths that perform I/O, and report the count and locations. Running with
  `-Djdk.tracePinnedThreads=full` in staging surfaces the rest.
- **ThreadLocal and security context propagation.** Request-scoped state held in `ThreadLocal` —
  `SecurityContextHolder` being the common case — behaves differently once carrier threads are
  reused, and context bleed between requests is a correctness and security problem rather than a
  performance one. Inventory custom `ThreadLocal` usage; `ScopedValue` is the modern replacement.

**Report guidance.** State which model the analysis assumes, state the evidence for or against
reactive from the conditions above, and present the consequences table. Do not declare a winner, and
do not present reactive as the modern or advanced choice — that framing is what the older guidance
got wrong.

## Common Migration Strategy Bank

### Application Server → Spring Boot

| J2EE Component | Spring Boot Equivalent |
|----------------|------------------------|
| EJB Stateless Session Beans | Spring `@Service` with reactive return types (Mono/Flux) |
| EJB Stateful Session Beans | Spring service + Redis/DynamoDB for state |
| EJB Message-Driven Beans | Reactor Kafka / AWS SQS listeners |
| J2EE Security | Spring Security |
| J2EE Timer Service | Spring `@Scheduled` |
| JNDI DataSource | Spring `DataSource` bean / R2DBC |
| JMS | Amazon SQS / MSK (Kafka) |
| Work Manager / Async Beans | Reactor Schedulers |
| Application Server Clustering | ECS/EKS + ALB |
| Server Diagnostics | Spring Boot Actuator + CloudWatch |

### Data Access Migration

| J2EE JPA | Spring Data |
|----------|-------------|
| JPA with Hibernate/TopLink/EclipseLink | Spring Data R2DBC (reactive) |
| `persistence.xml` | `application.yml` R2DBC config |
| EntityManager | R2DatabaseClient |
| JPQL queries | Native SQL / query methods |
| JTA transactions | R2DBC reactive transactions |

### Messaging Migration

| J2EE JMS | AWS Messaging |
|----------|---------------|
| JMS Connection Factory | Kafka/SQS connection config |
| JMS Queues | Kafka topics / SQS queues |
| JMS Topics | Kafka topics / SNS topics |
| JMS MessageListener | Reactor Kafka / SQS async |
| XA Transactions | Saga pattern / Outbox pattern |

### Security Migration

| J2EE Security | Spring Security |
|---------------|--------------------------|
| User Registry (LDAP) | ReactiveAuthenticationManager |
| Security Tokens | JWT / OAuth2 |
| Security Roles | Spring authorities |
| `@RolesAllowed` | `@PreAuthorize` |
| Credential Vault | AWS Secrets Manager |

## Common Implementation Phases

### Phase 0: Dependency Analysis

1. Scan for J2EE imports (`javax.ejb`, `javax.servlet`, `javax.persistence`, `javax.jms`)
2. Identify application server-specific imports
3. Analyze deployment descriptors
4. Calculate dependency density scores
5. Generate migration complexity report

### Phase 1: Project Structure Migration

1. Update to the Spring Boot 4.1.x parent
2. Remove ALL J2EE and application server dependencies
3. Add Spring Boot reactive starters:
   - `spring-boot-starter-webflux` (NOT `spring-boot-starter-web`)
   - `spring-boot-starter-data-r2dbc`
   - `spring-boot-starter-rsocket`
4. Configure multi-architecture Docker build (x86_64 + ARM64)

### Phase 2: Configuration Migration

1. Remove `web.xml` entirely
2. Migrate deployment descriptors to `application.yml`
3. Replace JNDI lookups with Spring DI
4. Configure R2DBC data sources

### Phase 3: EJB Migration

1. Convert Stateless Session Beans to `@Service`
2. Convert Stateful Session Beans to services + Redis
3. Migrate MDBs to reactive message listeners
4. Replace `@EJB` with constructor injection

### Phase 4: Data Access Migration

1. Remove `persistence.xml`
2. Configure Spring Data R2DBC
3. Convert JPA entities to R2DBC entities
4. Rewrite JPQL to native SQL

### Phase 5: Web Services Migration

1. Convert JAX-RS to Spring WebFlux
2. Replace servlet filters with WebFilter
3. Eliminate HttpServletRequest/Response usage

### Phase 6: Messaging Migration

1. Replace JMS with Kafka/SQS
2. Convert JMS producers to reactive publishers
3. Migrate MDBs to reactive consumers

### Phase 7: Security Migration

1. Replace J2EE security with Spring Security
2. Migrate user registries to Cognito/LDAP
3. Replace security tokens with JWT/OAuth2

### Phase 8: Container Optimization

1. Create multi-arch Dockerfile (x86_64 + ARM64)
2. Configure for AWS Java Runtime (Corretto)
3. Optimize for Graviton processors

## J2EE to Jakarta EE Namespace Change

All J2EE migrations must handle the namespace change:
- `javax.*` packages → `jakarta.*` packages
- Spring Boot 3.x uses Jakarta EE 9+; **Spring Boot 4.1 requires Jakarta EE 11** (Servlet 6.1, JPA 3.2, Bean Validation 3.1)
- Requires dependency updates across the board

## Common Code Migration Examples

### EJB to Spring Service

**Before (J2EE EJB):**
```java
@Stateless
public class OrderServiceBean implements OrderService {
    @Resource
    private SessionContext ctx;
    
    @EJB
    private InventoryService inventory;
    
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public Order createOrder(OrderRequest request) {
        // blocking implementation
    }
}
```

**After (Spring Boot Reactive):**
```java
@Service
public class OrderService {
    private final InventoryService inventory;
    
    public OrderService(InventoryService inventory) {
        this.inventory = inventory;
    }
    
    @Transactional
    public Mono<Order> createOrder(OrderRequest request) {
        return inventory.checkStock(request.getItems())
            .flatMap(available -> saveOrder(request));
    }
}
```

### JMS MDB to Reactive Kafka

**Before (J2EE MDB):**
```java
@MessageDriven(activationConfig = {
    @ActivationConfigProperty(propertyName = "destinationType", 
                              propertyValue = "javax.jms.Queue"),
    @ActivationConfigProperty(propertyName = "destination", 
                              propertyValue = "jms/OrderQueue")
})
public class OrderMessageBean implements MessageListener {
    public void onMessage(Message message) {
        // blocking processing
    }
}
```

**After (Reactor Kafka):**
```java
@Component
public class OrderMessageConsumer {
    @Bean
    public Consumer<Flux<ReceiverRecord<String, Order>>> orderConsumer() {
        return records -> records
            .flatMap(record -> processOrder(record.value())
                .doOnSuccess(v -> record.receiverOffset().acknowledge()))
            .subscribe();
    }
}
```

### JAX-RS to WebFlux

**Before (JAX-RS):**
```java
@Path("/orders")
public class OrderResource {
    @GET
    @Path("/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getOrder(@PathParam("id") String id) {
        Order order = orderService.findById(id);
        return Response.ok(order).build();
    }
}
```

**After (Spring WebFlux):**
```java
@RestController
@RequestMapping("/orders")
public class OrderController {
    private final OrderService orderService;
    
    @GetMapping("/{id}")
    public Mono<Order> getOrder(@PathVariable String id) {
        return orderService.findById(id);
    }
}
```

### JPA to R2DBC

**Before (JPA):**
```java
@Entity
@Table(name = "orders")
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToMany(mappedBy = "order", fetch = FetchType.LAZY)
    private List<OrderItem> items;
}

public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByCustomerId(Long customerId);
}
```

**After (R2DBC):**
```java
@Table("orders")
public class Order {
    @Id
    private Long id;
    // Note: No relationship annotations in R2DBC
}

public interface OrderRepository extends ReactiveCrudRepository<Order, Long> {
    Flux<Order> findByCustomerId(Long customerId);
}
```

## AWS Target Services

| Component | AWS Service |
|-----------|-------------|
| Container Orchestration | Amazon ECS / EKS |
| Database | Amazon Aurora PostgreSQL (R2DBC) |
| Messaging | Amazon SQS / MSK (Kafka) |
| Identity | Amazon Cognito |
| Caching | Amazon ElastiCache (Redis) |
| Secrets | AWS Secrets Manager |
| Configuration | AWS Parameter Store |
| Logging | Amazon CloudWatch Logs |
| Tracing | AWS X-Ray |
| Load Balancing | Application Load Balancer |

## Validation Criteria

All J2EE to Spring Boot reactive migrations must meet:

1. Zero J2EE/Jakarta/Application Server dependencies in final build
2. Application starts with an embedded container - Tomcat 11 / Jetty 12.1 on the servlet stack, or Netty on the reactive stack - not a managed application server
3. All EJBs converted to Spring reactive services
4. All data access migrated off the app server: Spring Data JPA / Hibernate 7.4 on the blocking stack, or Spring Data R2DBC on the reactive stack
5. Messaging works with Kafka/SQS
6. Security implemented with Spring Security
7. Container runs on both x86_64 and ARM64 (Graviton)
8. All tests pass - MockMvc / RestTestClient on the servlet stack, or WebTestClient and StepVerifier on the reactive stack

## Risk Mitigation Patterns

### Stateful Session Bean State Management

**Risk**: Loss of conversational state
**Mitigation**: External session storage with Redis
```java
@Service
public class SessionStateService {
    private final ReactiveRedisTemplate<String, SessionState> redisTemplate;
    
    public Mono<SessionState> getState(String sessionId) {
        return redisTemplate.opsForValue().get(sessionId);
    }
    
    public Mono<Boolean> saveState(String sessionId, SessionState state) {
        return redisTemplate.opsForValue().set(sessionId, state, Duration.ofMinutes(30));
    }
}
```

### XA Transaction Replacement

**Risk**: Loss of distributed transaction support
**Mitigation**: Saga pattern with outbox
```java
@Service
public class OrderSagaService {
    public Mono<Order> createOrderSaga(OrderRequest request) {
        return orderRepository.save(order)
            .flatMap(saved -> outboxRepository.save(new OutboxEvent(saved)))
            .flatMap(event -> inventoryService.reserve(request.getItems())
                .onErrorResume(e -> compensate(order)));
    }
}
```

### Lazy Loading Replacement

**Risk**: N+1 query problems without lazy loading
**Mitigation**: Explicit reactive data fetching
```java
public Mono<OrderWithItems> getOrderWithItems(Long orderId) {
    return Mono.zip(
        orderRepository.findById(orderId),
        orderItemRepository.findByOrderId(orderId).collectList()
    ).map(tuple -> new OrderWithItems(tuple.getT1(), tuple.getT2()));
}
```
