# Graph Report - training  (2026-11-25)

## Corpus Check
- 115 files · ~40,719 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 37 file(s) not represented in the graph (top: .properties 10, .gz 6, (none) 5)
- WARNING: 37 of 154 files seen (24%) have no supported extractor and are missing from this graph entirely. It may look complete while representing only part of the codebase.

## Summary
- 1017 nodes · 1933 edges · 66 communities (34 shown, 32 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 106 edges (avg confidence: 0.86)
- Token cost: 37,570 input · 0 output

## Community Hubs (Navigation)
- TrackMetricAspect.java
- AuthorizationServerConfig.java
- Card loading options
- org.springframework.stereotype.Component
- AGENTS.md
- index.ts
- org.springframework.http.ResponseEntity
- otel-collector.yaml
- Department
- org.junit.jupiter.api.Test
- Docker Compose Services
- services
- CardDto
- graphify Tooling Docs
- Gradle Test Logging
- floci & Pulumi Docs
- AOP Pointcuts
- DepartmentService
- Devcontainer Post-Start
- ARCHITECTURE.md
- CardControllerTests.java
- DepartmentNotFoundException
- .from
- CategoryCountDto
- tempo.yaml
- Kind
- datasources
- Card
- providers
- global
- CardFact
- CardServiceImpl.java
- KindCountDto
- Category
- CardControllerTests
- CardController.java
- DepartmentFilter
- .getDepartmentById
- DepartmentServiceImpl.java
- Where to find each exam topic
- FakeCognito
- .mcp.json
- Architecture
- Dev container
- .securityProperties
- package.json
- AboutController.java
- Setup
- resolvePlaceholders
- volumes
- AppPrincipal
- Spring Boot Training
- createGroupMembership
- helper.ts

## God Nodes (most connected - your core abstractions)
1. `Department` - 45 edges
2. `Card` - 35 edges
3. `WithoutOAuth2Application` - 28 edges
4. `AbstractAuthenticationTests` - 19 edges
5. `CardControllerTests` - 18 edges
6. `CardDto` - 17 edges
7. `CardServiceImpl` - 15 edges
8. `DepartmentServiceImpl` - 15 edges
9. `Category` - 15 edges
10. `Kind` - 15 edges

## Surprising Connections (you probably didn't know these)
- `Layout` --references--> `WithoutOAuth2Application`  [INFERRED]
  AGENTS.md → src/test/java/eu/meiyu/training/WithoutOAuth2Application.java
- `Testing` --references--> `WithoutOAuth2Application`  [INFERRED]
  ARCHITECTURE.md → src/test/java/eu/meiyu/training/WithoutOAuth2Application.java
- `Where to find each exam topic` --references--> `SamplePostProcessor`  [INFERRED]
  ARCHITECTURE.md → src/main/java/eu/meiyu/training/feature/sample/SamplePostProcessor.java
- `Where to find each exam topic` --references--> `OAuth2Controller`  [INFERRED]
  ARCHITECTURE.md → src/main/java/eu/meiyu/training/controller/OAuth2Controller.java
- `Where to find each exam topic` --references--> `DepartmentSpecifications`  [INFERRED]
  ARCHITECTURE.md → src/main/java/eu/meiyu/training/feature/department/repository/DepartmentSpecifications.java

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Local AWS emulation with floci and Pulumi** — iac_readme_pulumi, iac_readme_floci, hello_floci_floci, hello_floci_s3 [INFERRED 0.75]

## Communities (66 total, 32 thin omitted)

### Community 0 - "TrackMetricAspect.java"
Cohesion: 0.11
Nodes (9): MetricType, COUNTER, DISTRIBUTION_SUMMARY, LONG_TASK_TIMER, TIMER, TrackMetric, TrackMetrics, TrackMetricService (+1 more)

### Community 1 - "AuthorizationServerConfig.java"
Cohesion: 0.08
Nodes (6): ActuatorConfig, RepositoryConfig, AuthorizationServerConfig, RestSecurityConfig, TrainingApplication, TrainingConfig

### Community 2 - "Card loading options"
Cohesion: 0.05
Nodes (37): 1. Current solution: offset pages with early prefetch, 2. Alternative: cursor pages, 3. Alternative: server-sent events, 4. Alternative: newline-delimited JSON, 5. Alternative: WebSocket, 6. Alternative: windowed rendering, Benefits, Benefits (+29 more)

### Community 3 - "org.springframework.stereotype.Component"
Cohesion: 0.05
Nodes (10): ExecutionPerService, PerformanceHealthIndicator, PerformanceTracker, LoggingAspect, TimingAspect, AppConfigProperties, SampleBean, InlineSampleBean (+2 more)

### Community 4 - "AGENTS.md"
Cohesion: 0.25
Nodes (6): Commands, Conventions, Documentation style, Graphify, Layout, Ports

### Community 5 - "index.ts"
Cohesion: 0.07
Nodes (25): allUserGroups, appBaseUrls, appCluster, appImageName, appService, appSettingsFile, appSettingsVars, appTaskDefinition (+17 more)

### Community 6 - "org.springframework.http.ResponseEntity"
Cohesion: 0.17
Nodes (3): OAuth2Controller, StudyCardsPageController, SampleController

### Community 7 - "otel-collector.yaml"
Cohesion: 0.06
Nodes (32): verbosity, exporters, debug, otlp/tempo, prometheus, endpoint, endpoint, context (+24 more)

### Community 9 - "org.junit.jupiter.api.Test"
Cohesion: 0.06
Nodes (9): AboutControllerTests, DepartmentControllerTests, AbstractAuthenticationTests, LoginStart, AuthorizationCodePkceTests, BearerTokenTests, ClientCredentialsTests, OidcLoginTests (+1 more)

### Community 10 - "Docker Compose Services"
Cohesion: 0.14
Nodes (13): compilerOptions, experimentalDecorators, forceConsistentCasingInFileNames, module, moduleResolution, noFallthroughCasesInSwitch, noImplicitReturns, outDir (+5 more)

### Community 11 - "services"
Cohesion: 0.05
Nodes (39): FLOCI_SERVICES_ECS_HOST_VOLUME_ROOTS, FLOCI_STORAGE_MODE, GF_AUTH_ANONYMOUS_ENABLED, GF_AUTH_ANONYMOUS_ORG_ROLE, GF_AUTH_DISABLE_LOGIN_FORM, environment, image, ports (+31 more)

### Community 12 - "CardDto"
Cohesion: 0.25
Nodes (3): CardDto, CardPageDto, CardServiceImpl

### Community 13 - "graphify Tooling Docs"
Cohesion: 0.18
Nodes (10): config, pulumi:tags, description, name, packagemanager, value, runtime, name (+2 more)

### Community 14 - "Gradle Test Logging"
Cohesion: 0.14
Nodes (13): config, aws:accessKey, aws:endpoints, aws:region, aws:s3UsePathStyle, aws:secretKey, aws:skipCredentialsValidation, aws:skipMetadataApiCheck (+5 more)

### Community 15 - "floci & Pulumi Docs"
Cohesion: 0.25
Nodes (8): graphify skill (/graphify trigger), .claude/skills/graphify/SKILL.md, graphify-out/graph.json, GRAPH_REPORT.md, graphify knowledge graph (graphify-out/), graphify query / path / explain, graphify update . (AST-only refresh), graphify-out/wiki/index.md

### Community 17 - "AOP Pointcuts"
Cohesion: 0.40
Nodes (5): floci (free local S3 alternative), AWS S3, floci (local backend for Pulumi), Pulumi, pulumi login --local

### Community 21 - "ARCHITECTURE.md"
Cohesion: 0.17
Nodes (5): post-create.sh script, post-start.sh script, start-relay.sh script, Karate REST Tests, Load test

### Community 22 - "CardControllerTests.java"
Cohesion: 0.09
Nodes (4): CardRepositoryTests, CategoryRepositoryTests, KindRepositoryTests, WithoutOAuth2Application

### Community 25 - ".from"
Cohesion: 0.18
Nodes (4): CategoryDto, FactDto, KindDto, RelatedCardDto

### Community 27 - "tempo.yaml"
Cohesion: 0.12
Nodes (16): distributor, receivers, endpoint, path, protocols, grpc, otlp, server (+8 more)

### Community 29 - "datasources"
Cohesion: 0.15
Nodes (12): apiVersion, datasources, access, editable, isDefault, jsonData, name, type (+4 more)

### Community 31 - "providers"
Cohesion: 0.18
Nodes (10): apiVersion, path, providers, allowUiUpdates, disableDeletion, folder, name, options (+2 more)

### Community 32 - "global"
Cohesion: 0.25
Nodes (7): global, evaluation_interval, scrape_interval, scrape_configs, job_name, static_configs, targets

### Community 34 - "CardServiceImpl.java"
Cohesion: 0.17
Nodes (3): CardRepository, CategoryRepository, KindRepository

### Community 42 - "CardController.java"
Cohesion: 0.26
Nodes (3): CardController, CardNameDto, CardService

### Community 52 - "Architecture"
Cohesion: 0.20
Nodes (10): App entry points, Architecture, Endpoints and ports, Observability, Overview, Ports, Profiles and configuration, Security and authentication (+2 more)

### Community 53 - "Dev container"
Cohesion: 0.22
Nodes (9): Configuration, Daily use, Dev container, Getting started, Host vs. container, mise tasks, Reaching host services, Troubleshooting (+1 more)

### Community 56 - "package.json"
Cohesion: 0.15
Nodes (16): allowScripts, protobufjs@7.6.6, dependencies, @pulumi/aws@^7.54.0, @pulumi/command@^1.3.0, @pulumi/postgresql@^3.18.3, devDependencies, @types/node@^18 (+8 more)

### Community 58 - "Setup"
Cohesion: 0.25
Nodes (8): AWS CLI profile for Floci, Connecting the app to Floci, Full reset, Host setup, Host vs. dev container, Linux hosts, Setup, Troubleshooting

### Community 61 - "volumes"
Cohesion: 0.50
Nodes (4): volumes, grafana-data, prometheus-data, tempo-data

### Community 62 - "AppPrincipal"
Cohesion: 0.06
Nodes (7): PrincipalDto, AppClaims, AppJwtAuthenticationToken, AppAuthorities, AppPrincipal, CognitoOidcPrincipal, JwtAppPrincipal

### Community 63 - "Spring Boot Training"
Cohesion: 0.50
Nodes (4): Documentation, Key features, Prerequisites, Spring Boot Training

### Community 66 - "createGroupMembership"
Cohesion: 0.67
Nodes (3): createGroupMembership(), createGroups(), createUserAndGroups()

### Community 67 - "helper.ts"
Cohesion: 0.32
Nodes (5): propertiesFileToJson(), propertiesToJson(), readFileContents(), @pulumi/pulumi@^3.113.0, @pulumi/pulumi

## Knowledge Gaps
- **9 isolated node(s):** `COUNTER`, `DISTRIBUTION_SUMMARY`, `LONG_TASK_TIMER`, `TIMER`, `graphify update . (AST-only refresh)` (+4 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 340 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **32 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `WithoutOAuth2Application` connect `CardControllerTests.java` to `AuthorizationServerConfig.java`, `org.springframework.stereotype.Component`, `AGENTS.md`, `org.springframework.http.ResponseEntity`, `CardControllerTests`, `org.junit.jupiter.api.Test`, `Architecture`?**
  _High betweenness centrality (0.153) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `WithoutOAuth2Application` (e.g. with `Layout` and `Testing`) actually correct?**
  _`WithoutOAuth2Application` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `COUNTER`, `DISTRIBUTION_SUMMARY`, `LONG_TASK_TIMER` to the rest of the system?**
  _9 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `TrackMetricAspect.java` be split into smaller, more focused modules?**
  _Cohesion score 0.10606060606060606 - nodes in this community are weakly interconnected._
- **Why does `AppConfigProperties` connect `org.springframework.stereotype.Component` to `AuthorizationServerConfig.java`, `org.springframework.http.ResponseEntity`, `CardControllerTests.java`?**
  _High betweenness centrality (0.152) - this node is a cross-community bridge._
- **Should `AuthorizationServerConfig.java` be split into smaller, more focused modules?**
  _Cohesion score 0.07653061224489796 - nodes in this community are weakly interconnected._
- **Why does `Architecture` connect `Architecture` to `ARCHITECTURE.md`, `Where to find each exam topic`?**
  _High betweenness centrality (0.074) - this node is a cross-community bridge._