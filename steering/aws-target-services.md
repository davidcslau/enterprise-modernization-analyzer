---
inclusion: manual
---

# AWS Target Services for Modernization

This guide maps common legacy components to AWS-native services.

## Compute Services

| Legacy Component | AWS Service | Notes |
|------------------|-------------|-------|
| Application Server (WebLogic, WebSphere, WildFly/JBoss EAP, IIS) | Amazon ECS / EKS | Container orchestration |
| WildFly / JBoss EAP domain mode (domain controller + host controllers) | Amazon ECS / EKS | The domain controller concept disappears; the orchestrator manages replicas |
| Tomcat / Jetty (servlet container) | Embedded server inside the container image | Embedded **Tomcat 11** or **Jetty 12.1** (Servlet 6.1, required by Spring Boot 4), or Netty on the reactive stack |
| **Undertow** (WildFly / JBoss default) | Embedded Tomcat 11 or Jetty 12.1 | **Undertow has no Servlet 6.1 release and Spring Boot 4 removed support for it entirely** — a hard blocker, no workaround |
| Virtual Machines | Amazon EC2 / Fargate | Serverless containers preferred |
| Batch Processing | AWS Batch / Step Functions | Managed batch workloads |
| Scheduled Jobs | Amazon EventBridge / Lambda | Serverless scheduling |
| EJB Timer Service / Quartz cluster jobs | Amazon EventBridge Scheduler | Cluster-wide scheduling without leader election in application code |

### Java Runtime Targets

| Target | Position |
|--------|----------|
| **Amazon Corretto 25** | Current LTS, generally available. The default recommendation for a Spring Boot 4.1 target |
| **Amazon Corretto 21** | LTS, the conservative choice |
| Java 17 | Spring Boot 4's documented floor, but not a recommendation — some Boot-managed dependencies already require 21+ |
| **AWS Lambda** | Supports Java 25 as both a managed runtime and a container base image, on Corretto |

Graviton (ARM64) is supported across these; verify per-dependency ARM64 support before committing,
particularly for native libraries.

### Container Recommendations

- **ECS Fargate**: Simplified container deployment, no server management
- **EKS**: Kubernetes-based orchestration for complex workloads
- **Graviton Processors**: Up to 40% cost savings with ARM64

## Database Services

**⛔ Engine change requires confirmed scope.** Database migration is a scope decision the customer
makes, not something the analyzer infers from the presence of a commercial engine. Some programmes
deliberately keep the database unchanged so the application migration is the only variable. Report
the database footprint, state the scope question explicitly, and only then apply an engine-change
row from the table below. See the Database Detection section in POWER.md.

| Legacy Database | AWS Service | Migration Path | Applies when |
|-----------------|-------------|----------------|--------------|
| SQL Server | Amazon RDS SQL Server | Lift-and-shift, no engine change | Database migration out of scope |
| SQL Server | SQL Server on Amazon EC2 | Lift-and-shift where RDS feature gaps apply | Database migration out of scope |
| SQL Server | Aurora PostgreSQL | T-SQL conversion + data migration workstream | **Only when migration is confirmed in scope** |
| Oracle | Amazon RDS for Oracle | Lift-and-shift, no engine change | Database migration out of scope |
| Oracle | Aurora PostgreSQL | Full PL/SQL conversion workstream — load `steering/oracle-to-postgresql.md` | **Only when migration is confirmed in scope** |
| DB2 | Amazon RDS for Db2 | Lift-and-shift, no engine change | Database migration out of scope |
| DB2 | Aurora PostgreSQL | Via SCT/DMS, with SQL and stored-logic conversion | **Only when migration is confirmed in scope** |
| MySQL | Amazon RDS MySQL / Aurora MySQL | Direct migration, no dialect change | Open-source engine; no licensing driver |
| PostgreSQL | Amazon RDS PostgreSQL / Aurora PostgreSQL | Direct migration | Open-source engine; no licensing driver |

### Database Migration Tools

- **AWS Schema Conversion Tool (SCT)**: Schema and stored procedure conversion
- **AWS Database Migration Service (DMS)**: Data migration with minimal downtime
- **pgLoader**: Open-source alternative for PostgreSQL migration

### Cost Optimization

Where a commercial database engine is in use, licensing is often the largest single cost component:
- SQL Server licensing: Very High ongoing cost
- Oracle licensing: Very High ongoing cost
- Aurora PostgreSQL: No licensing fees, High savings potential

Report this as **context for the customer's business case**, not as a reason to override a scope
decision. Where the customer has confirmed the database stays as it is, the licensing position is
still worth stating — it may inform a later phase — but no database migration workstream belongs in
the pathways.

### Application Server Licensing and Subscription

| Current platform | Commercial position | Target position |
|------------------|--------------------|-----------------|
| IBM WebSphere ND | Commercial licence, per-PVU | Removed entirely on Spring Boot + ECS/EKS |
| Oracle WebLogic | Commercial licence | Removed entirely |
| Red Hat JBoss EAP | Red Hat subscription, per socket or core | Removed entirely; note some organisations value the subscription for support and certification, so its removal is a trade-off they weigh |
| Community WildFly | **No subscription** | No change — do not claim a saving that does not exist |
| Apache Tomcat / Jetty | No licence cost | No change |

Report qualitatively. No dollar amounts, consistent with `report-structure.md`.

## Messaging Services

| Legacy Messaging | AWS Service | Use Case |
|------------------|-------------|----------|
| MSMQ | Amazon SQS | Point-to-point queuing |
| WebSphere MQ | Amazon SQS / Amazon MQ | Enterprise messaging |
| WebLogic JMS | Amazon SQS / MSK | JMS replacement |
| ActiveMQ Artemis (WildFly 10+ / JBoss EAP 7+) | Amazon MQ (ActiveMQ engine) / SQS / MSK | Amazon MQ preserves JMS semantics and wire protocol most closely |
| HornetQ (JBoss EAP 6 and earlier) | Amazon MQ / SQS / MSK | HornetQ-specific client APIs have no successor and need rework |
| Embedded broker in `standalone-full.xml` | Amazon MQ / SQS / MSK | An embedded broker is not a viable container target — an external broker must be introduced |
| RabbitMQ | Amazon MQ | Managed RabbitMQ |
| Kafka | Amazon MSK | Managed Kafka |
| Pub/Sub | Amazon SNS | Fan-out messaging |
| Event-Driven | Amazon EventBridge | Event bus |

## Security Services

| Legacy Security | AWS Service | Notes |
|-----------------|-------------|-------|
| Windows Auth | Amazon Cognito | OAuth 2.0/OIDC |
| LDAP | Amazon Cognito / Directory Service | Identity management |
| Custom Auth | Amazon Cognito | User pools |
| Container-managed security (`web.xml` security constraints) | Spring Security + Amazon Cognito | Declarative constraints become application configuration |
| JAAS login modules | Spring Security authentication providers | Custom login modules are application code and must be rewritten |
| WildFly Elytron / legacy security domains | Spring Security + Amazon Cognito | Establish which of the two stacks is in use first |
| PicketLink (SAML federation) | Amazon Cognito with SAML federation | PicketLink is end-of-life |
| WebLogic security realm / WebSphere security domain | Spring Security + Amazon Cognito | Proprietary realm APIs have no direct successor |
| RACF / ACF2 / Top Secret (mainframe) | Amazon Cognito / Directory Service | Mainframe authorization model must be re-expressed explicitly |
| Secrets Storage | AWS Secrets Manager | Credential management |
| Certificate Management | AWS Certificate Manager | SSL/TLS certificates |

## Configuration & Storage

| Legacy Component | AWS Service | Notes |
|------------------|-------------|-------|
| Config Files | AWS Systems Manager Parameter Store | Centralized config |
| `standalone.xml` / `domain.xml` subsystem configuration | Parameter Store + `application.yml` | Server-level configuration becomes application and infrastructure configuration |
| JBoss Vault (`vault.dat`, `${VAULT::...}`) | AWS Secrets Manager | Masked credentials move out of server configuration |
| File Storage | Amazon S3 | Object storage |
| `jboss.server.data.dir` and other server-relative paths | Amazon S3 / Amazon EFS | Server directory layout has no container equivalent |
| Session State | Amazon ElastiCache / DynamoDB | Distributed sessions |
| Caching | Amazon ElastiCache | Redis/Memcached |
| Infinispan (embedded or remote) | Amazon ElastiCache (Redis) via Spring Cache | Embedded-cache semantics (co-located, transactional) do not survive the move |
| Oracle Coherence | Amazon ElastiCache | Distributed caching |
| Ehcache (in-process) | Amazon ElastiCache | Required once more than one replica runs |

## Observability

| Legacy Monitoring | AWS Service | Notes |
|-------------------|-------------|-------|
| Application Logs | Amazon CloudWatch Logs | Centralized logging |
| Metrics | Amazon CloudWatch Metrics | Application metrics |
| Tracing | AWS X-Ray | Distributed tracing |
| APM | CloudWatch Application Insights | Application monitoring |

## Networking

| Legacy Component | AWS Service | Notes |
|------------------|-------------|-------|
| Load Balancer | Application Load Balancer (ALB) | Layer 7 load balancing |
| DNS | Amazon Route 53 | DNS management |
| CDN | Amazon CloudFront | Content delivery |
| VPN | AWS VPN / Direct Connect | Hybrid connectivity |

## AWS Well-Architected Alignment

### Operational Excellence
- Infrastructure as Code (CloudFormation, CDK)
- Automated deployment pipelines (CodePipeline)
- Observability (CloudWatch, X-Ray)

### Security
- Secrets management (Secrets Manager)
- IAM roles for service authentication
- Encryption in transit and at rest
- VPC isolation and security groups

### Reliability
- Multi-AZ deployment
- Auto-scaling
- Circuit breakers (with application code)
- Graceful degradation patterns

### Performance Efficiency
- Graviton processors for cost-optimized performance
- Right-sizing based on workload
- Caching strategies

### Cost Optimization
- Graviton instances (up to 40% savings)
- Spot instances for non-critical workloads
- Reserved capacity for predictable workloads
- License elimination (Aurora PostgreSQL vs SQL Server)

## Recommended Migration Tools

| Tool | Purpose |
|------|---------|
| AWS Application Discovery Service | Discover on-premises applications |
| AWS Migration Hub | Track migration progress |
| AWS App2Container | Containerize .NET and Java apps |
| AWS Transform | .NET modernization assistance |
| Kiro | AI-powered migration assistance |
