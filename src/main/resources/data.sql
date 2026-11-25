INSERT INTO card_category (id, code, name)
VALUES (1, 'core', 'Container & Config'),
       (2, 'aop', 'AOP'),
       (3, 'data', 'Data & Transactions'),
       (4, 'jpa', 'Spring Data JPA'),
       (5, 'web', 'Web & REST'),
       (6, 'sec', 'Security'),
       (7, 'test', 'Testing'),
       (8, 'boot', 'Spring Boot')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

INSERT INTO card_kind (id, name, hint)
VALUES (1, 'Annotation', 'Java annotation such as @Bean or @Transactional'),
       (2, 'Starter', 'Spring Boot starter dependency (spring-boot-starter-*)'),
       (3, 'Property', 'Configuration property for application.properties / .yml'),
       (4, 'Interface / class', 'Spring interface or class used in code'),
       (5, 'Expression', 'Expression syntax: pointcuts, SpEL, security rules, query method names'),
       (6, 'Actuator endpoint', 'Actuator HTTP endpoint under /actuator'),
       (7, 'Concept', 'Concept or mechanism explained across several APIs')
ON CONFLICT (id) DO NOTHING;

INSERT INTO card (id, name, kind_id, category_id, description, example_code, info_tables, source_url)
VALUES (1, '@Configuration', 1, 1, 'Marks a class as a source of bean definitions (Java config).', '@Configuration
public class AppConfig {
  @Bean public TransferService transferService() {
    return new TransferServiceImpl(accountRepository());
  }
  @Bean public AccountRepository accountRepository() {...}
}', NULL, NULL),
       (2, '@Bean', 1, 1, 'Method-level: the return value is registered as a Spring bean.', '@Bean(name = "ds", initMethod = "init", destroyMethod = "close")
public DataSource dataSource() {...}', NULL, NULL),
       (3, '@ComponentScan', 1, 1,
        'Detects classes annotated with @Component (and stereotypes) and registers them as beans.', '@Configuration
@ComponentScan(basePackages = "com.bank.app",
  excludeFilters = @Filter(type = FilterType.ANNOTATION, classes = Controller.class))
public class AppConfig {}', NULL, NULL),
       (4, '@Component', 1, 1,
        'Generic stereotype: marks a class as a Spring-managed bean found by component scanning.', '@Component("transferService")
public class TransferServiceImpl implements TransferService {}', NULL, NULL),
       (5, '@Service', 1, 1, 'Stereotype for the service (business) layer. A @Component with clearer intent.', '@Service
public class OrderService {...}', NULL, NULL),
       (6, '@Repository', 1, 1, 'Stereotype for the data-access layer.', '@Repository
public class JdbcAccountRepository implements AccountRepository {...}', NULL, NULL),
       (7, '@Controller', 1, 1, 'Stereotype for a Spring MVC web controller; return values are view names by default.', '@Controller
public class HomeController {
  @GetMapping("/") public String home() { return "index"; }
}', NULL, NULL),
       (8, '@Autowired', 1, 1, 'Asks Spring to inject a dependency by type.', '@Service
public class TransferServiceImpl {
  private final AccountRepository repo;
  public TransferServiceImpl(AccountRepository repo) { this.repo = repo; }
}', NULL, NULL),
       (9, '@Qualifier', 1, 1, 'Selects one bean by id (or qualifier value) when several beans share a type.',
        'public TransferServiceImpl(@Qualifier("jdbcAccountRepository") AccountRepository r) {...}', NULL, NULL),
       (10, '@Primary', 1, 1, 'Marks the default bean when several of the same type exist.', '@Bean @Primary
public DataSource mainDataSource() {...}', NULL, NULL),
       (11, '@Value', 1, 1, 'Injects a value from a property placeholder ${...} or a SpEL expression #{...}.', 'public Service(@Value("${daily.limit:100}") int limit,
               @Value("#{systemProperties[''user.region'']}") String region) {...}', NULL, NULL),
       (12, '@PropertySource', 1, 1, 'Adds a .properties file to the Spring Environment.', '@Configuration
@PropertySource("classpath:/com/bank/config/app.properties")
public class DbConfig {}', NULL, NULL),
       (13, '@Profile', 1, 1, 'The bean or configuration class is only registered when the given profile is active.', '@Configuration @Profile("jdbc")
public class JdbcConfig {...}

@Bean @Profile("!prod") DataSource embedded() {...}', NULL, NULL),
       (14, '@Scope', 1, 1, 'Defines the bean''s lifecycle scope.', '@Component
@Scope(value = "session", proxyMode = ScopedProxyMode.TARGET_CLASS)
public class ShoppingCart {...}', NULL, NULL),
       (15, '@Lazy', 1, 1, 'Delays creating a singleton until it is first requested.', '@Bean @Lazy
public ExpensiveClient client() {...}', NULL, NULL),
       (16, '@Import', 1, 1, 'Pulls other configuration classes into this one.', '@Configuration
@Import({ApplicationConfig.class, InfrastructureConfig.class})
public class TestConfig {}', NULL, NULL),
       (17, '@PostConstruct / @PreDestroy', 1, 1,
        'JSR-250 lifecycle callbacks: run after dependency injection / before the context closes.', '@PostConstruct void populateCache() {...}
@PreDestroy   void flushCache() {...}', NULL, NULL),
       (18, '@DependsOn', 1, 1,
        'Forces other beans to be initialised before this one, even without a direct dependency.', '@Bean @DependsOn("schemaInitializer")
public CacheLoader cacheLoader() {...}', NULL, NULL),
       (19, '@Resource / @Inject', 1, 1,
        'Standard alternatives to @Autowired: @Resource (JSR-250) and @Inject (JSR-330).', '@Resource(name = "jdbcAccountRepository")
private AccountRepository repo;', NULL, NULL),
       (20, '@Conditional', 1, 1, 'Registers a bean only when a Condition implementation matches.', '@Bean @Conditional(OnLinuxCondition.class)
public Shell shell() {...}', NULL, NULL),
       (21, '@ImportResource', 1, 1, 'Imports bean definitions from XML files into a Java @Configuration class.', '@Configuration
@ImportResource("classpath:/legacy/datasource-config.xml")
public class AppConfig {}', NULL, NULL),
       (22, '@Named', 1, 1,
        'JSR-330 annotation: declares a component (like @Component) or qualifies an injection point (like @Qualifier).', '@Named("accountRepository")
public class JdbcAccountRepository implements AccountRepository {}

@Inject
public TransferServiceImpl(@Named("accountRepository") AccountRepository r) {...}', NULL, NULL),
       (23, '@Nullable', 1, 1, 'Spring''s null-safety annotation: a parameter, field or return value may be null.',
        'public TransferServiceImpl(AccountRepository repo, @Nullable AuditLog audit) {...}', NULL, NULL),
       (24, '@Validated', 1, 1,
        'Spring''s variant of @Valid: turns on method-level validation for a bean and supports validation groups.', '@Service @Validated
public class TransferService {
  public void transfer(@NotNull Account from, @Min(1) BigDecimal amount) {...}
}', NULL, NULL),
       (25, '@AliasFor', 1, 1,
        'Declares that an annotation attribute is an alias for another attribute, in the same annotation or in a meta-annotation.', '// Explicit alias pair in one annotation
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface MyAnnotation {
  @AliasFor("location")
  String value() default "";
  @AliasFor("value")
  String location() default "";
}
// @MyAnnotation("x") == @MyAnnotation(location = "x")

// Alias for a meta-annotation attribute
@Target(ElementType.TYPE) @Retention(RetentionPolicy.RUNTIME)
@Service @Transactional
public @interface TransactionalService {
  @AliasFor(annotation = Service.class, attribute = "value")
  String name() default "";
  @AliasFor(annotation = Transactional.class)
  boolean readOnly() default false;
}', NULL, NULL),
       (26, '@Aspect', 1, 2, 'Marks a class as an aspect: a module of advice + pointcuts for cross-cutting concerns.', '@Aspect @Component
public class PerformanceMonitor {...}', NULL, NULL),
       (27, '@EnableAspectJAutoProxy', 1, 2, 'Turns on proxy creation for beans matched by @Aspect pointcuts.', '@Configuration
@EnableAspectJAutoProxy(proxyTargetClass = true)
public class AspectConfig {}', NULL, NULL),
       (28, '@Pointcut', 1, 2, 'Declares a reusable, named pointcut expression.', '@Pointcut("execution(* com.bank..*Service.*(..))")
public void serviceMethods() {}

@Before("serviceMethods() && @annotation(Audited)")', NULL, NULL),
       (29, '@Before', 1, 2, 'Advice that runs before the join point.', '@Before("execution(void set*(*))")
public void trackChange(JoinPoint jp) {
  log.info("About to call " + jp.getSignature().getName());
}', NULL, NULL),
       (30, '@AfterReturning', 1, 2, 'Runs after the method returns normally.', '@AfterReturning(value = "execution(* service..*.find*(..))", returning = "result")
public void audit(JoinPoint jp, Object result) {...}', NULL, NULL),
       (31, '@AfterThrowing', 1, 2, 'Runs only when the method throws an exception.', '@AfterThrowing(value = "serviceMethods()", throwing = "e")
public void report(JoinPoint jp, DataAccessException e) {...}', NULL, NULL),
       (32, '@After', 1, 2, 'Runs after the method, whether it returned or threw (like finally).', '@After("serviceMethods()")
public void cleanup(JoinPoint jp) {...}', NULL, NULL),
       (33, '@Around', 1, 2, 'Wraps the method: runs before and after, and decides whether to call it.', '@Around("execution(@Cacheable * *(..))")
public Object cache(ProceedingJoinPoint pjp) throws Throwable {
  Object v = cache.get(key(pjp));
  if (v == null) { v = pjp.proceed(); cache.put(key(pjp), v); }
  return v;
}', NULL, NULL),
       (34, '@Transactional', 1, 3, 'Runs the method in a transaction managed by a PlatformTransactionManager.', '@Transactional(propagation = Propagation.REQUIRES_NEW,
               rollbackFor = InsufficientFundsException.class)
public void transfer(...) {...}', '[
           {
               "caption": "Isolation levels: can the anomaly happen?",
               "headers": [
                   "Isolation",
                   "Dirty",
                   "Non-repeatable",
                   "Phantom"
               ],
               "rows": [
                   [
                       "READ_UNCOMMITTED",
                       "Yes",
                       "Yes",
                       "Yes"
                   ],
                   [
                       "READ_COMMITTED",
                       "No",
                       "Yes",
                       "Yes"
                   ],
                   [
                       "REPEATABLE_READ",
                       "No",
                       "No",
                       "Yes"
                   ],
                   [
                       "SERIALIZABLE",
                       "No",
                       "No",
                       "No"
                   ]
               ]
           },
           {
               "caption": "Propagation",
               "headers": [
                   "Value",
                   "Tx exists",
                   "No tx"
               ],
               "rows": [
                   [
                       "REQUIRED",
                       "join it",
                       "create new"
                   ],
                   [
                       "REQUIRES_NEW",
                       "suspend, create new",
                       "create new"
                   ],
                   [
                       "NESTED",
                       "savepoint in it",
                       "create new"
                   ],
                   [
                       "SUPPORTS",
                       "join it",
                       "run without"
                   ],
                   [
                       "MANDATORY",
                       "join it",
                       "exception"
                   ],
                   [
                       "NOT_SUPPORTED",
                       "suspend, run without",
                       "run without"
                   ],
                   [
                       "NEVER",
                       "exception",
                       "run without"
                   ]
               ]
           }
       ]'::jsonb, NULL),
       (35, '@EnableTransactionManagement', 1, 3,
        'Turns on annotation-driven transaction management (proxies for @Transactional).', '@Configuration @EnableTransactionManagement
public class TxConfig {
  @Bean PlatformTransactionManager txManager(DataSource ds) {
    return new DataSourceTransactionManager(ds);
  }
}', NULL, NULL),
       (36, '@Sql', 1, 3, 'Test annotation: runs SQL scripts before (default) or after a test method or class.', '@Test
@Sql(scripts = "/testfiles/cleanup.sql",
     executionPhase = Sql.ExecutionPhase.AFTER_TEST_METHOD)
void findAll() {...}', NULL, NULL),
       (37, '@SqlConfig', 1, 3, 'Configures how @Sql scripts are parsed and executed.', '@Sql(scripts = "/data.sql",
     config = @SqlConfig(errorMode = SqlConfig.ErrorMode.CONTINUE_ON_ERROR,
                         separator = "@@"))', NULL, NULL),
       (38, '@SqlMergeMode', 1, 3, 'Decides whether method-level @Sql replaces or adds to class-level @Sql.', '@SpringJUnitConfig(TestConfig.class)
@Sql("/schema.sql") @SqlMergeMode(MergeMode.MERGE)
class RepoTests {
  @Test @Sql("/extra-data.sql") void find() {...}   // runs both scripts
}', NULL, NULL),
       (39, '@Entity / @Id / @Table / @Column', 1, 4,
        'JPA mapping annotations: a persistent class, its primary key, table and columns.', '@Entity @Table(name = "T_CUSTOMER")
public class Customer {
  @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "cust_id") private Long id;
}', NULL, NULL),
       (40, '@EnableJpaRepositories', 1, 4,
        'Scans for interfaces extending Repository and creates their implementations at runtime.', 'public interface CustomerRepository extends CrudRepository<Customer, Long> {
  List<Customer> findByEmailIgnoreCase(String email);
}', NULL, NULL),
       (41, '@Query', 1, 4, 'Supplies an explicit JPQL (or native SQL) query for a repository method.', '@Query("select c from Customer c where c.email not like ''%@%''")
List<Customer> findInvalidEmails();

@Modifying @Query("update Customer c set c.active = false where c.id = :id")
int deactivate(@Param("id") Long id);', NULL, NULL),
       (42, '@EntityScan', 1, 4,
        'Spring Boot: tells JPA where to find @Entity classes outside the main application package.', '@SpringBootApplication
@EntityScan("com.bank.domain")
@EnableJpaRepositories("com.bank.repo")
public class App {}', NULL, NULL),
       (43, '@GeneratedValue', 1, 4, 'Lets the database or JPA provider generate the @Id value.', '@Id @GeneratedValue(strategy = GenerationType.SEQUENCE)
private Long id;', NULL, NULL),
       (44, '@OneToMany / @ManyToOne / @JoinColumn', 1, 4,
        'Map relationships between entities; @JoinColumn names the foreign-key column.', '@Entity public class Customer {
  @OneToMany(mappedBy = "customer", cascade = CascadeType.ALL)
  private List<Order> orders;
}
@Entity public class Order {
  @ManyToOne @JoinColumn(name = "customer_id")
  private Customer customer;
}', NULL, NULL),
       (45, '@Transient', 1, 4, 'Excludes a field from persistence: JPA does not map it to a column.', '@Transient
private BigDecimal cachedTotal;', NULL, NULL),
       (46, '@Modifying', 1, 4, 'Marks a repository @Query as an UPDATE, DELETE or INSERT instead of a SELECT.', '@Transactional
@Modifying(clearAutomatically = true)
@Query("update Customer c set c.active = false where c.id = :id")
int deactivate(@Param("id") Long id);', NULL, NULL),
       (47, '@Param', 1, 4, 'Names a repository method parameter so a @Query can refer to it as :name.', '@Query("select c from Customer c where c.lastName = :name")
List<Customer> findByName(@Param("name") String lastName);', NULL, NULL),
       (48, '@RestController', 1, 5,
        '@Controller + @ResponseBody: every handler''s return value is written to the HTTP response body.', '@RestController @RequestMapping("/accounts")
public class AccountController {
  @GetMapping("/{id}") public Account get(@PathVariable long id) {...}
}', NULL, NULL),
       (49, '@RequestMapping', 1, 5, 'Maps requests to a controller class or handler method.', '@RequestMapping(path = "/orders", method = RequestMethod.POST,
                consumes = "application/json")', NULL, NULL),
       (50, '@GetMapping / @PostMapping / @PutMapping / @DeleteMapping / @PatchMapping', 1, 5,
        'Composed shortcuts for @RequestMapping with a fixed HTTP method.', '@PostMapping("/accounts")
public ResponseEntity<Void> create(@RequestBody Account a) {
  Account saved = service.save(a);
  URI loc = ServletUriComponentsBuilder.fromCurrentRequestUri()
     .path("/{id}").buildAndExpand(saved.getId()).toUri();
  return ResponseEntity.created(loc).build();
}', NULL, NULL),
       (51, '@PathVariable', 1, 5, 'Binds a URI template variable, e.g. /accounts/{id}.', '@GetMapping("/accounts/{id}/beneficiaries/{name}")
public Beneficiary get(@PathVariable long id, @PathVariable("name") String n) {...}', NULL, NULL),
       (52, '@RequestParam', 1, 5, 'Binds a query string or form parameter, e.g. ?page=2.', '@GetMapping("/accounts")
public List<Account> list(@RequestParam(defaultValue = "0") int page) {...}', NULL, NULL),
       (53, '@RequestBody', 1, 5, 'Converts the HTTP request body into a Java object via an HttpMessageConverter.', '@PutMapping("/accounts/{id}")
public void update(@PathVariable long id, @Valid @RequestBody Account a) {...}', NULL, NULL),
       (54, '@ResponseBody', 1, 5, 'Writes the return value directly to the response body instead of resolving a view.', '@Controller
public class Api {
  @GetMapping("/ping") @ResponseBody public String ping() { return "ok"; }
}', NULL, NULL),
       (55, '@ResponseStatus', 1, 5, 'Sets the HTTP status of a handler method or of an exception class.', '@PostMapping @ResponseStatus(HttpStatus.CREATED) ...

@ResponseStatus(HttpStatus.NOT_FOUND)
public class AccountNotFoundException extends RuntimeException {}', NULL, NULL),
       (56, '@RequestHeader / @CookieValue', 1, 5, 'Bind an HTTP header or a cookie value to a method parameter.', 'public String home(@RequestHeader("User-Agent") String agent,
                   @CookieValue("JSESSIONID") String session) {...}', NULL, NULL),
       (57, '@ExceptionHandler', 1, 5, 'Handles exceptions thrown by handler methods.', '@ExceptionHandler(AccountNotFoundException.class)
@ResponseStatus(HttpStatus.NOT_FOUND)
public void notFound() {}', NULL, NULL),
       (58, '@ControllerAdvice / @RestControllerAdvice', 1, 5,
        'A component holding @ExceptionHandler (and @ModelAttribute/@InitBinder) methods shared by all controllers.', '@RestControllerAdvice
public class GlobalErrors {
  @ExceptionHandler(IllegalArgumentException.class)
  public ResponseEntity<String> bad(IllegalArgumentException e) {
    return ResponseEntity.badRequest().body(e.getMessage());
  }
}', NULL, NULL),
       (59, '@ModelAttribute', 1, 5, 'Binds request parameters to an object, or adds an attribute to the model.', '@PostMapping("/register")
public String register(@ModelAttribute User user) {...}', NULL, NULL),
       (60, '@EnableWebMvc', 1, 5, 'Imports Spring MVC configuration in a plain Spring app.', '@Configuration
public class WebConfig implements WebMvcConfigurer {
  @Override public void addViewControllers(ViewControllerRegistry r) {...}
}', NULL, NULL),
       (61, '@Valid', 1, 5,
        'Bean Validation: triggers validation of the annotated argument, or cascades into a nested object.', '@PostMapping("/accounts")
public ResponseEntity<Void> create(@Valid @RequestBody Account a) {...}', NULL, NULL),
       (62, '@NotNull / @NotEmpty / @NotBlank / @Size / @Min / @Max / @Email', 1, 5,
        'Bean Validation constraints on fields or parameters, checked when @Valid or @Validated triggers validation.', 'public class Account {
  @NotBlank          private String name;
  @Email             private String email;
  @Min(0)            private BigDecimal balance;
  @Size(max = 5)     private List<Beneficiary> beneficiaries;
}', NULL, NULL),
       (63, '@InitBinder', 1, 5,
        'Customises data binding for a controller: allowed fields, property editors, formatters, validators.', '@InitBinder
public void init(WebDataBinder b) {
  b.setDisallowedFields("id");
  b.registerCustomEditor(Date.class, new CustomDateEditor(fmt, true));
}', NULL, NULL),
       (64, '@EnableWebSecurity', 1, 6, 'Enables Spring Security''s web support and the springSecurityFilterChain.', '@Bean
SecurityFilterChain chain(HttpSecurity http) throws Exception {
  http.authorizeRequests()
      .mvcMatchers("/admin/**").hasRole("ADMIN")
      .anyRequest().authenticated()
      .and().httpBasic();
  return http.build();
}', NULL, NULL),
       (65, '@EnableMethodSecurity', 1, 6,
        'Enables method-level security annotations. The successor to @EnableGlobalMethodSecurity.', '@Configuration
@EnableMethodSecurity(securedEnabled = true)
public class MethodSecurityConfig {}', NULL, NULL),
       (66, '@EnableGlobalMethodSecurity', 1, 6,
        'Enables method-level security annotations (Spring Security 5). Deprecated in favour of @EnableMethodSecurity.', '@Configuration
@EnableGlobalMethodSecurity(prePostEnabled = true, securedEnabled = true)
public class MethodSecurityConfig {}', NULL, NULL),
       (67, '@PreAuthorize / @PostAuthorize', 1, 6, 'SpEL-based access checks before or after a method runs.', '@PreAuthorize("hasRole(''ADMIN'') or #id == authentication.principal.id")
public Account find(long id) {...}', NULL, NULL),
       (68, '@Secured / @RolesAllowed', 1, 6,
        'Simple role checks on methods: @Secured (Spring) and @RolesAllowed (JSR-250).', '@Secured("ROLE_ADMIN")
public void deleteAll() {...}', NULL, NULL),
       (69, '@WithMockUser', 1, 6, 'Test annotation: runs the test as an authenticated mock user.', '@Test @WithMockUser(roles = "ADMIN")
void adminCanDelete() throws Exception {
  mockMvc.perform(delete("/accounts/1")).andExpect(status().isNoContent());
}', NULL, NULL),
       (70, '@PreFilter / @PostFilter', 1, 6,
        'Filter a collection argument or return value element by element with a SpEL expression.', '@PostFilter("filterObject.owner == authentication.name")
public List<Account> findAll() {...}', NULL, NULL),
       (71, '@SpringJUnitConfig', 1, 7,
        'JUnit 5 shortcut = @ExtendWith(SpringExtension.class) + @ContextConfiguration.', '@SpringJUnitConfig(classes = TestInfrastructureConfig.class)
class TransferServiceTests {
  @Autowired TransferService service;
}', NULL, NULL),
       (72, '@ExtendWith(SpringExtension.class)', 1, 7, 'Plugs the Spring TestContext Framework into JUnit 5.', '@ExtendWith(SpringExtension.class)
@ContextConfiguration(classes = AppConfig.class)
class MyTest {}', NULL, NULL),
       (73, '@ContextConfiguration', 1, 7,
        'Says which configuration classes (or XML) build the test ApplicationContext.',
        '@ContextConfiguration(classes = {AppConfig.class, TestDbConfig.class})', NULL, NULL),
       (74, '@ActiveProfiles', 1, 7, 'Activates bean definition profiles for a test context.', '@SpringJUnitConfig(AppConfig.class)
@ActiveProfiles({"jdbc", "dev"})
class JdbcTests {}', NULL, NULL),
       (75, '@TestPropertySource', 1, 7, 'Adds properties (or property files) with high precedence for a test.',
        '@TestPropertySource(properties = "daily.limit=500")', NULL, NULL),
       (76, '@DirtiesContext', 1, 7, 'Marks the cached ApplicationContext as dirty so it is closed and rebuilt.', '@Test @DirtiesContext
void changesSharedState() {...}', NULL, NULL),
       (77, '@Rollback / @Commit', 1, 7, 'Controls whether a test-managed transaction rolls back (default) or commits.', '@Test @Transactional @Commit
void persistsForReal() {...}', NULL, NULL),
       (78, '@SpringBootTest', 1, 7, 'Loads the full Spring Boot application context for an integration test.', '@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class AccountApiTests {
  @Autowired TestRestTemplate rest;
}', NULL, NULL),
       (79, '@WebMvcTest', 1, 7,
        'Slice test: loads only the web layer (controllers, advice, converters, filters) and a MockMvc.', '@WebMvcTest(AccountController.class)
class AccountControllerTests {
  @Autowired MockMvc mvc;
  @MockBean AccountService service;
  @Test void get() throws Exception {
    given(service.find(1L)).willReturn(new Account(1L));
    mvc.perform(get("/accounts/1")).andExpect(status().isOk());
  }
}', NULL, NULL),
       (80, '@DataJpaTest', 1, 7,
        'Slice test for JPA: entities, repositories, an embedded database and TestEntityManager.', '@DataJpaTest
class CustomerRepositoryTests {
  @Autowired TestEntityManager em;
  @Autowired CustomerRepository repo;
}', NULL, NULL),
       (81, '@MockBean / @SpyBean', 1, 7,
        'Adds (or replaces) a bean in the Spring test context with a Mockito mock or spy.', '@SpringBootTest
class TransferTests {
  @MockBean AccountRepository repo;   // replaces the real bean
}', NULL, NULL),
       (82, '@MockitoBean / @MockitoSpyBean', 1, 7,
        'Spring Framework''s replacement for Boot''s @MockBean / @SpyBean: overrides a bean in the test ApplicationContext with a Mockito mock or spy.', '@SpringBootTest
class TransferTests {
  @MockitoBean    AccountRepository repo;     // mock replaces the real bean
  @MockitoSpyBean RewardService rewards;      // spy wraps the real bean
}', NULL, NULL),
       (83, '@AutoConfigureMockMvc', 1, 7, 'Adds a MockMvc bean to a @SpringBootTest context.', '@SpringBootTest @AutoConfigureMockMvc
class FullStackTests { @Autowired MockMvc mvc; }', NULL, NULL),
       (84, '@TestConfiguration', 1, 7,
        'Extra configuration for tests that adds to, rather than replaces, the primary configuration.', '@SpringBootTest
@Import(StubClockConfig.class)
class ClockTests {}', NULL, NULL),
       (85, '@LocalServerPort', 1, 7, 'Injects the actual port of the embedded server started by a RANDOM_PORT test.',
        '@LocalServerPort int port;', NULL, NULL),
       (86, '@RunWith', 1, 7,
        'JUnit 4: chooses the test runner; @RunWith(SpringRunner.class) plugs in the Spring TestContext Framework.', '@RunWith(SpringRunner.class)
@ContextConfiguration(classes = AppConfig.class)
public class TransferServiceTests {...}', NULL, NULL),
       (87, '@AutoConfigureTestDatabase', 1, 7,
        'Controls whether a test swaps the application DataSource for an embedded one.', '@DataJpaTest
@AutoConfigureTestDatabase(replace = Replace.NONE)
class PostgresRepositoryTests {...}', NULL, NULL),
       (88, '@Mock / @Spy / @InjectMocks', 1, 7,
        'Plain Mockito: creates mocks or spies and builds the class under test with them injected. No Spring context.', '@ExtendWith(MockitoExtension.class)
class TransferServiceTests {
  @Mock        AccountRepository repo;
  @InjectMocks TransferServiceImpl service;
}', NULL, NULL),
       (89, '@TestBean', 1, 7,
        'Bean Override (Spring 6.2): replaces a bean in the test context with the one returned by a static factory method.', '@SpringJUnitConfig(AppConfig.class)
class ClockTests {
  @TestBean Clock clock;
  static Clock clock() { return Clock.fixed(Instant.EPOCH, ZoneOffset.UTC); }
}', NULL, NULL),
       (90, '@SpringBootApplication', 1, 8, '@SpringBootConfiguration + @EnableAutoConfiguration + @ComponentScan.', '@SpringBootApplication(exclude = DataSourceAutoConfiguration.class)
public class App {
  public static void main(String[] a) { SpringApplication.run(App.class, a); }
}', NULL, NULL),
       (91, '@EnableAutoConfiguration', 1, 8,
        'Lets Boot configure beans based on the classpath, existing beans and properties.',
        '@EnableAutoConfiguration(exclude = {SecurityAutoConfiguration.class})', NULL, NULL),
       (92, '@ConditionalOnClass / @ConditionalOnMissingClass', 1, 8,
        'Apply a configuration only if a class is (or is not) on the classpath.', '@Configuration
@ConditionalOnClass(DataSource.class)
public class DataSourceAutoConfig {...}', NULL, NULL),
       (93, '@ConditionalOnBean / @ConditionalOnMissingBean', 1, 8,
        'Apply a bean only if another bean of that type is (or is not) already defined.', '@Bean @ConditionalOnMissingBean
public ObjectMapper objectMapper() {...}', NULL, NULL),
       (94, '@ConditionalOnProperty', 1, 8, 'Apply a configuration depending on a property''s presence or value.', '@Bean
@ConditionalOnProperty(prefix = "feature", name = "audit", havingValue = "true")
public AuditService audit() {...}', NULL, NULL),
       (95, '@AutoConfigureAfter / @AutoConfigureBefore', 1, 8,
        'Order one auto-configuration class relative to other auto-configuration classes.', '@AutoConfiguration
@AutoConfigureAfter(DataSourceAutoConfiguration.class)
@ConditionalOnBean(DataSource.class)
public class MyRepoAutoConfig {...}', NULL, NULL),
       (96, '@AutoConfigureOrder', 1, 8, 'Like @Order, but sets the order of auto-configuration classes.', '@AutoConfiguration
@AutoConfigureOrder(Ordered.HIGHEST_PRECEDENCE)
public class EarlyAutoConfig {...}', NULL, NULL),
       (97, '@ConfigurationProperties', 1, 8,
        'Binds a group of properties with a common prefix to a typed Java object.', '@ConfigurationProperties(prefix = "rewards.client")
public class ClientProps {
  private String host; private int port;
  // getters + setters
}', NULL, NULL),
       (98, '@EnableConfigurationProperties', 1, 8, 'Registers the listed @ConfigurationProperties classes as beans.', '@SpringBootApplication
@EnableConfigurationProperties(ClientProps.class)
public class App {}', NULL, NULL),
       (99, '@Endpoint (Actuator)', 1, 8, 'Defines a custom Actuator endpoint exposed over HTTP and/or JMX.', '@Component @Endpoint(id = "release-notes")
public class ReleaseNotesEndpoint {
  @ReadOperation public String notes() {...}
  @ReadOperation public String version(@Selector String v) {...}
}', NULL, NULL),
       (100, '@SpringBootConfiguration', 1, 8,
        'A @Configuration that marks the application''s primary configuration; part of @SpringBootApplication.', '@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan
public class App {}   // equivalent to @SpringBootApplication', NULL, NULL),
       (101, '@ConfigurationPropertiesScan', 1, 8,
        'Scans packages for @ConfigurationProperties classes and registers them as beans.', '@SpringBootApplication
@ConfigurationPropertiesScan("com.bank.config")
public class App {}', NULL, NULL),
       (102, '@ConstructorBinding', 1, 8,
        'Binds @ConfigurationProperties through the constructor, giving immutable properties classes.', '@ConfigurationProperties("rewards.client")
@ConstructorBinding                      // Boot 2.x
public class ClientProps {
  private final String host; private final int port;
  public ClientProps(String host, int port) {...}
}', NULL, NULL),
       (103, '@ReadOperation / @WriteOperation / @DeleteOperation', 1, 8,
        'Expose methods of a custom Actuator @Endpoint as operations.', '@WriteOperation
public void configure(String name, boolean enabled) {...}
// POST /actuator/features  {"name":"audit","enabled":true}', NULL, NULL),
       (104, '@Selector', 1, 8, 'Binds a path segment of a custom Actuator endpoint to an operation parameter.', '@ReadOperation
public String notes(@Selector String version) {...}', NULL, NULL),
       (105, '@WebEndpoint / @JmxEndpoint', 1, 8,
        'Variants of @Endpoint that are exposed only over HTTP, or only over JMX.', '@Component @WebEndpoint(id = "feature-flags")
public class FeatureFlagsEndpoint {...}', NULL, NULL),
       (106, 'spring-boot-starter', 2, 8,
        'Core starter, including auto-configuration support, logging and YAML. Every other starter depends on it.', '<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter</artifactId>
</dependency>', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/using.html#using.build-systems.starters'),
       (107, 'spring-boot-starter-parent', 2, 8,
        'Parent POM (not a dependency). Its own parent is spring-boot-dependencies, the BOM that manages versions of Spring and third-party libraries.', '<parent>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-parent</artifactId>
  <version>2.7.18</version>
</parent>', NULL, 'https://docs.spring.io/spring-boot/docs/2.7.18/maven-plugin/reference/htmlsingle/#using.parent-pom'),
       (108, 'spring-boot-starter-web', 2, 5,
        'Starter for building web, including RESTful, applications using Spring MVC. Uses Tomcat as the default embedded container.', '<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-web</artifactId>
</dependency>', '[
           {
               "caption": "What comes from where",
               "headers": [
                   "Dependency",
                   "Gives you"
               ],
               "rows": [
                   [
                       "spring-webmvc",
                       "DispatcherServlet, @Controller model"
                   ],
                   [
                       "starter-json",
                       "Jackson ObjectMapper"
                   ],
                   [
                       "starter-tomcat",
                       "Embedded Tomcat"
                   ],
                   [
                       "spring-web",
                       "HTTP abstractions, RestTemplate"
                   ]
               ]
           }
       ]'::jsonb, 'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/web.html#web.servlet'),
       (109, 'spring-boot-starter-validation', 2, 5, 'Starter for using Java Bean Validation with Hibernate Validator.', '<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-validation</artifactId>
</dependency>', NULL,
        'https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-2.3-Release-Notes#validation-starter-no-longer-included-in-web-starters'),
       (110, 'spring-boot-starter-json', 2, 5,
        'Starter for reading and writing JSON. Included by the web and webflux starters.',
        'spring.jackson.serialization.indent-output=true', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.json'),
       (111, 'spring-boot-starter-webflux', 2, 5,
        'Starter for building WebFlux applications using Spring Framework''s reactive web support.', '<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>', NULL, 'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/web.html#web.reactive'),
       (112, 'spring-boot-starter-jdbc', 2, 3, 'Starter for using JDBC with the HikariCP connection pool.', '<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-jdbc</artifactId>
</dependency>
<dependency>
  <groupId>com.h2database</groupId>
  <artifactId>h2</artifactId>
  <scope>runtime</scope>
</dependency>', NULL, 'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/data.html#data.sql.datasource'),
       (113, 'spring-boot-starter-data-jpa', 2, 4, 'Starter for using Spring Data JPA with Hibernate.', '<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>', '[
           {
               "caption": "What comes from where",
               "headers": [
                   "Dependency",
                   "Gives you"
               ],
               "rows": [
                   [
                       "hibernate-core",
                       "JPA provider"
                   ],
                   [
                       "spring-data-jpa",
                       "Repository interfaces, derived queries"
                   ],
                   [
                       "starter-jdbc",
                       "DataSource, HikariCP, JdbcTemplate"
                   ],
                   [
                       "starter-aop",
                       "Proxies for repositories / @Transactional"
                   ]
               ]
           }
       ]'::jsonb,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/data.html#data.sql.jpa-and-spring-data'),
       (114, 'spring-boot-starter-aop', 2, 2, 'Starter for aspect-oriented programming with Spring AOP and AspectJ.', '<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-aop</artifactId>
</dependency>', NULL, 'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.aop'),
       (115, 'spring-boot-starter-security', 2, 6, 'Starter for using Spring Security.', '<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-security</artifactId>
</dependency>', NULL, 'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/web.html#web.security'),
       (116, 'spring-boot-starter-oauth2-resource-server', 2, 6,
        'Starter for using Spring Security''s OAuth2 resource server features.',
        'spring.security.oauth2.resourceserver.jwt.issuer-uri=https://idp.example.com', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/web.html#web.security.oauth2.server'),
       (117, 'spring-boot-starter-test', 2, 7,
        'Starter for testing Spring Boot applications with libraries including JUnit Jupiter, Hamcrest and Mockito.', '<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-test</artifactId>
  <scope>test</scope>
</dependency>', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.testing.test-scope-dependencies'),
       (118, 'spring-boot-starter-actuator', 2, 8,
        'Starter for using Spring Boot''s Actuator, which provides production-ready features to help you monitor and manage your application.', '<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>', NULL, 'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.enabling'),
       (119, 'spring-boot-starter-logging / -tomcat / -jetty / -undertow', 2, 8,
        'Technical starters: pulled in transitively, or used to swap the logging system or embedded server.', '<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-web</artifactId>
  <exclusions>
    <exclusion>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-tomcat</artifactId>
    </exclusion>
  </exclusions>
</dependency>
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-jetty</artifactId>
</dependency>', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/howto.html#howto.webserver.use-another'),
       (120, 'spring.profiles.active', 3, 1,
        'Comma-separated list of active profiles. Can be overridden by a command line switch.', '# application.properties
spring.profiles.active=dev,hsqldb

# or: java -jar app.jar --spring.profiles.active=prod', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.profiles'),
       (121, 'spring.profiles.include / spring.profiles.group', 3, 1,
        'include: unconditionally activate extra profiles on top of the active ones. group: give a logical name to a set of profiles.', 'spring.profiles.include=common,local
spring.profiles.group.production[0]=proddb
spring.profiles.group.production[1]=prodmq', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.profiles.groups'),
       (122, 'spring.config.import', 3, 8, 'Import additional config data (Boot 2.4+).',
        'spring.config.import=optional:file:./dev.properties', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.external-config.files.importing'),
       (123, 'spring.config.location / additional-location', 3, 8,
        'Where Boot looks for application.properties / .yml.',
        'java -jar app.jar --spring.config.additional-location=optional:file:/etc/myapp/', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.external-config.files'),
       (124, 'spring.main.lazy-initialization', 3, 8,
        'Whether initialization should be performed lazily. Default false.', 'spring.main.lazy-initialization=true',
        NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.spring-application.lazy-initialization'),
       (125, 'debug', 3, 8, 'Enable debug logs for a selection of core loggers. Default false.',
        'java -jar app.jar --debug', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.logging.console-output'),
       (126, 'logging.level.*', 3, 8, 'Log level per logger name, e.g. logging.level.org.springframework=DEBUG.', 'logging.level.root=WARN
logging.level.org.springframework.web=DEBUG
logging.level.org.hibernate=ERROR', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.logging.log-levels'),
       (127, 'server.port', 3, 5, 'HTTP port of the embedded server. Defaults to 8080.', 'server.port=9090', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/howto.html#howto.webserver.change-port'),
       (128, 'server.servlet.context-path', 3, 5, 'Context path of the application. No default (served at /).',
        'server.servlet.context-path=/bank', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/application-properties.html#appendix.application-properties.server'),
       (129, 'spring.datasource.url', 3, 3,
        'JDBC URL of the database (with spring.datasource.username / password / driver-class-name).', 'spring.datasource.url=jdbc:postgresql://localhost/bank
spring.datasource.username=bank
spring.datasource.password=secret', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/data.html#data.sql.datasource.production'),
       (130, 'spring.sql.init.mode', 3, 3,
        'When to run schema.sql / data.sql. Values: embedded (default), always, never.', 'spring.sql.init.mode=always
spring.sql.init.schema-locations=classpath:db/schema.sql', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/howto.html#howto.data-initialization.using-basic-sql-scripts'),
       (131, 'spring.jpa.hibernate.ddl-auto', 3, 4,
        'Hibernate schema generation: none, validate, update, create, create-drop.',
        'spring.jpa.hibernate.ddl-auto=validate', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/howto.html#howto.data-initialization.using-hibernate'),
       (132, 'spring.jpa.show-sql', 3, 4, 'Whether to enable logging of SQL statements. Default false.',
        'spring.jpa.show-sql=true', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/application-properties.html#appendix.application-properties.data'),
       (133, 'spring.jpa.open-in-view', 3, 4,
        'Register OpenEntityManagerInViewInterceptor: binds a JPA EntityManager to the thread for the entire request.',
        'spring.jpa.open-in-view=false', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/data.html#data.sql.jpa-and-spring-data.open-entity-manager-in-view'),
       (134, 'spring.jpa.defer-datasource-initialization', 3, 4,
        'Defer schema.sql / data.sql until after EntityManagerFactory beans are created and initialized. Default false.', 'spring.jpa.hibernate.ddl-auto=create
spring.jpa.defer-datasource-initialization=true', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/howto.html#howto.data-initialization.using-basic-sql-scripts'),
       (135, 'management.endpoints.web.exposure.include / exclude', 3, 8,
        'Which Actuator endpoints are exposed over HTTP. Default include = health, exclude = empty.', 'management.endpoints.web.exposure.include=health,info,metrics
management.endpoints.web.exposure.exclude=env,beans', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.endpoints.exposing'),
       (136, 'management.endpoint.health.show-details', 3, 8,
        'When to show health details: never (default), when-authorized, always.',
        'management.endpoint.health.show-details=always', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.endpoints.health'),
       (137, 'management.endpoints.web.base-path / management.server.port', 3, 8,
        'base-path changes the /actuator prefix. management.server.port serves Actuator on a separate port.', 'management.endpoints.web.base-path=/manage
management.server.port=8081', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.monitoring'),
       (138, 'info.* / management.info.<id>.enabled', 3, 8,
        'info.*: arbitrary properties shown by /actuator/info. management.info.<id>.enabled switches info contributors on or off.', 'management.info.env.enabled=true
info.app.name=Bank
info.app.version=@project.version@', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.endpoints.info'),
       (139, 'spring.security.user.name / password', 3, 6,
        'Override the default "user" and generated password that Boot sets up when Spring Security is on the classpath.', 'spring.security.user.name=admin
spring.security.user.password=secret', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/web.html#web.security'),
       (140, 'spring.aop.proxy-target-class', 3, 2,
        'Whether subclass-based (CGLIB) proxies are used (true, the Boot default) rather than JDK interface-based proxies (false).',
        'spring.aop.proxy-target-class=false', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.aop'),
       (141, 'ApplicationContext', 4, 1,
        'The Spring IoC container: creates, configures and wires beans, and adds events, i18n, resources and the Environment on top of BeanFactory.', 'ApplicationContext ctx = new AnnotationConfigApplicationContext(AppConfig.class);
TransferService ts = ctx.getBean(TransferService.class);
((ConfigurableApplicationContext) ctx).close();', NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/core.html#beans-introduction'),
       (142, 'BeanFactoryPostProcessor', 4, 1,
        'Operates on bean configuration metadata (bean definitions) before any bean is instantiated.', '@Bean
public static PropertySourcesPlaceholderConfigurer pspc() {
  return new PropertySourcesPlaceholderConfigurer();
}', NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/core.html#beans-factory-extension-factory-postprocessors'),
       (143, 'BeanPostProcessor', 4, 1,
        'Operates on bean instances: called for every bean around its initialization callbacks.', 'public class AuditBpp implements BeanPostProcessor {
  public Object postProcessAfterInitialization(Object bean, String name) {
    return bean; // or a proxy
  }
}', NULL, 'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/core.html#beans-factory-extension-bpp'),
       (144, 'InitializingBean / DisposableBean', 4, 1,
        'Interface-based lifecycle callbacks: afterPropertiesSet() and destroy().', 'public class Cache implements InitializingBean, DisposableBean {
  public void afterPropertiesSet() {...}
  public void destroy() {...}
}', NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/core.html#beans-factory-lifecycle-combined-effects'),
       (145, 'FactoryBean', 4, 1,
        'A bean that is a factory for another object: the container exposes the object it produces, not itself.', 'Object product = ctx.getBean("myFactory");
FactoryBean<?> factory = (FactoryBean<?>) ctx.getBean("&myFactory");', NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/core.html#beans-factory-extension-factorybean'),
       (146, 'Environment', 4, 1, 'Models two aspects of the application: profiles and properties.', '@Autowired Environment env;
String url = env.getRequiredProperty("db.url");
int port = env.getProperty("server.port", Integer.class, 8080);', NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/core.html#beans-environment'),
       (147, 'CommandLineRunner / ApplicationRunner', 4, 8,
        'Beans implementing either interface run once, just before SpringApplication.run(…) completes.', '@Bean
CommandLineRunner seed(AccountRepository repo) {
  return args -> repo.save(new Account("demo"));
}', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.spring-application.command-line-runner'),
       (148, 'JdbcTemplate', 4, 3,
        'Central JDBC class: handles connections, statements, result-set iteration and exception translation. Thread-safe once configured.', 'int n = jdbc.queryForObject("select count(*) from T_ACCOUNT", Integer.class);
Account a = jdbc.queryForObject("select * from T_ACCOUNT where id=?",
    (rs, row) -> new Account(rs.getLong("id"), rs.getString("name")), id);
jdbc.update("update T_ACCOUNT set name=? where id=?", name, id);', NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/data-access.html#jdbc-JdbcTemplate'),
       (149, 'RowMapper / RowCallbackHandler / ResultSetExtractor', 4, 3,
        'The three JdbcTemplate callbacks for turning a ResultSet into results.', 'jdbc.query(sql, (ResultSet rs) -> {  // RowCallbackHandler
  writer.write(rs.getString("name"));
});
Map<Long,Order> m = jdbc.query(sql, rs -> {  // ResultSetExtractor
  Map<Long,Order> map = new HashMap<>();
  while (rs.next()) {...}
  return map;
});', '[
           {
               "caption": "Which callback?",
               "headers": [
                   "Callback",
                   "Called",
                   "Returns",
                   "State"
               ],
               "rows": [
                   [
                       "RowMapper<T>",
                       "per row: mapRow(rs, rowNum)",
                       "one T per row → List<T>",
                       "stateless"
                   ],
                   [
                       "RowCallbackHandler",
                       "per row: processRow(rs)",
                       "void",
                       "stateful"
                   ],
                   [
                       "ResultSetExtractor<T>",
                       "once: extractData(rs)",
                       "one T for all rows",
                       "stateless"
                   ]
               ]
           }
       ]'::jsonb,
        'https://docs.spring.io/spring-framework/docs/5.3.x/javadoc-api/org/springframework/jdbc/core/ResultSetExtractor.html'),
       (150, 'NamedParameterJdbcTemplate', 4, 3,
        'Wraps a JdbcTemplate to support named parameters (:name) instead of ? placeholders.', 'String sql = "select count(*) from T_ACCOUNT where name = :name";
int n = named.queryForObject(sql, new MapSqlParameterSource("name", "Kate"), Integer.class);', NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/data-access.html#jdbc-NamedParameterJdbcTemplate'),
       (151, 'DataAccessException', 4, 3,
        'Root of Spring''s data access exception hierarchy. Unchecked (extends NestedRuntimeException) and technology independent.', 'try { jdbc.update(sql, id); }
catch (DataIntegrityViolationException e) {...}  // no SQLException handling needed', NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/data-access.html#dao-exceptions'),
       (152, 'PlatformTransactionManager', 4, 3,
        'Imperative transaction strategy interface: getTransaction(definition), commit(status), rollback(status).', '@Bean
public PlatformTransactionManager transactionManager(DataSource ds) {
  return new DataSourceTransactionManager(ds);
}', NULL, 'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/data-access.html#transaction-strategies'),
       (153, 'TransactionTemplate', 4, 3,
        'Programmatic transactions with a callback, as an alternative to @Transactional.', 'return txTemplate.execute(status -> {
  repo.debit(from, amt);
  repo.credit(to, amt);
  return true;
});', NULL, 'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/data-access.html#tx-prog-template'),
       (154, 'CrudRepository / PagingAndSortingRepository / JpaRepository', 4, 4,
        'Spring Data repository hierarchy: Repository (marker) → CrudRepository → PagingAndSortingRepository → JpaRepository.', 'public interface AccountRepository extends JpaRepository<Account, Long> {
  List<Account> findByOwnerLastName(String lastName);
}', NULL, 'https://docs.spring.io/spring-data/jpa/docs/2.7.x/reference/html/#repositories.core-concepts'),
       (155, 'ResponseEntity', 4, 5, 'Like @ResponseBody but with status and headers: the whole HTTP response.', '@PostMapping("/accounts")
ResponseEntity<Void> create(@RequestBody Account a) {
  URI loc = URI.create("/accounts/" + service.save(a).getId());
  return ResponseEntity.created(loc).build();
}', NULL, 'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/web.html#mvc-ann-responseentity'),
       (156, 'RestTemplate', 4, 5, 'Synchronous client to perform HTTP requests.', 'Account a = rest.getForObject("http://localhost:8080/accounts/{id}", Account.class, 1);
URI loc = rest.postForLocation("http://localhost:8080/accounts", newAccount);', NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/integration.html#rest-client-access'),
       (157, 'MockMvc', 4, 7,
        'Tests annotated controllers through the DispatcherServlet with mock requests: no running server.', 'mockMvc.perform(get("/accounts/1").accept(MediaType.APPLICATION_JSON))
  .andExpect(status().isOk())
  .andExpect(jsonPath("$.name").value("Kate"));', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.testing.spring-boot-applications.with-mock-environment'),
       (158, 'TestRestTemplate', 4, 7, 'RestTemplate variant for integration tests against a real running server.', '@SpringBootTest(webEnvironment = RANDOM_PORT)
class AccountIT {
  @Autowired TestRestTemplate rest;
  @Test void get() {
    ResponseEntity<Account> r = rest.getForEntity("/accounts/1", Account.class);
    assertThat(r.getStatusCode()).isEqualTo(HttpStatus.OK);
  }
}', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.testing.utilities.test-rest-template'),
       (159, 'DelegatingFilterProxy / FilterChainProxy', 4, 6,
        'How Spring Security plugs into the servlet container: a servlet Filter that delegates to Spring beans.', NULL,
        NULL,
        'https://github.com/spring-projects/spring-security/blob/5.8.x/docs/modules/ROOT/pages/servlet/architecture.adoc'),
       (160, 'SecurityFilterChain', 4, 6,
        'An ordered list of security filters plus a request matcher that decides when the chain applies. Built with HttpSecurity.', '@Bean
SecurityFilterChain api(HttpSecurity http) throws Exception {
  http.authorizeHttpRequests(a -> a
        .antMatchers("/admin/**").hasRole("ADMIN")
        .anyRequest().authenticated())
      .httpBasic();
  return http.build();
}', NULL,
        'https://github.com/spring-projects/spring-security/blob/5.8.x/docs/modules/ROOT/pages/servlet/architecture.adoc'),
       (161, 'SecurityContextHolder / Authentication', 4, 6,
        'SecurityContextHolder stores the SecurityContext, which holds the Authentication of the current user.', 'Authentication auth = SecurityContextHolder.getContext().getAuthentication();
String user = auth.getName();
Collection<? extends GrantedAuthority> roles = auth.getAuthorities();', NULL,
        'https://github.com/spring-projects/spring-security/blob/5.8.x/docs/modules/ROOT/pages/servlet/authentication/architecture.adoc'),
       (162, 'AuthenticationManager / ProviderManager / AuthenticationProvider', 4, 6,
        'AuthenticationManager is the API for authenticating; ProviderManager is its usual implementation and delegates to a list of AuthenticationProviders.',
        NULL, NULL,
        'https://github.com/spring-projects/spring-security/blob/5.8.x/docs/modules/ROOT/pages/servlet/authentication/architecture.adoc'),
       (163, 'UserDetailsService / UserDetails', 4, 6,
        'UserDetailsService loads a user for DaoAuthenticationProvider; UserDetails is the user it returns.', '@Bean
UserDetailsService users() {
  UserDetails u = User.withUsername("kate").password("{bcrypt}$2a$10$…").roles("USER").build();
  return new InMemoryUserDetailsManager(u);
}', NULL,
        'https://github.com/spring-projects/spring-security/blob/5.8.x/docs/modules/ROOT/pages/servlet/authentication/passwords/user-details-service.adoc'),
       (164, 'PasswordEncoder / DelegatingPasswordEncoder', 4, 6,
        'PasswordEncoder performs a one-way transformation of passwords. DelegatingPasswordEncoder is the default and picks the algorithm from an {id} prefix.', 'PasswordEncoder enc = PasswordEncoderFactories.createDelegatingPasswordEncoder();
String hash = enc.encode("secret");   // {bcrypt}$2a$10$...', NULL,
        'https://github.com/spring-projects/spring-security/blob/5.8.x/docs/modules/ROOT/pages/features/authentication/password-storage.adoc'),
       (165, 'HealthIndicator', 4, 8,
        'Contributes to /actuator/health: implement health() and return a Health with a status and optional details.', '@Component
public class MyHealthIndicator implements HealthIndicator {
  public Health health() {
    return ok() ? Health.up().build()
                : Health.down().withDetail("error", 42).build();
  }
}', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.endpoints.health.writing-custom-health-indicators'),
       (166, 'InfoContributor', 4, 8, 'Adds data to /actuator/info: implement contribute(Info.Builder).', '@Component
public class MyInfo implements InfoContributor {
  public void contribute(Info.Builder b) {
    b.withDetail("example", Map.of("key", "value"));
  }
}', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.endpoints.info.writing-custom-info-contributors'),
       (167, 'MeterRegistry', 4, 8,
        'Micrometer''s registry of meters (counters, timers, gauges). Boot auto-configures a composite MeterRegistry.', '@Component
public class Orders {
  private final Counter placed;
  Orders(MeterRegistry reg) { placed = reg.counter("orders.placed"); }
  void place() { placed.increment(); }
}', NULL, 'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.metrics'),
       (168, 'execution(…) pointcut', 5, 2,
        'The main Spring AOP pointcut designator: matches method execution join points.', '@Pointcut("execution(* com.bank.service..*Service.*(..))")
public void serviceMethods() {}', '[
           {
               "caption": "Read these",
               "headers": [
                   "Pointcut",
                   "Matches"
               ],
               "rows": [
                   [
                       "execution(* *(..))",
                       "any method"
                   ],
                   [
                       "execution(public * *(..))",
                       "any public method"
                   ],
                   [
                       "execution(* set*(..))",
                       "any method starting with set"
                   ],
                   [
                       "execution(* com.bank.service.*.*(..))",
                       "any method in the service package"
                   ],
                   [
                       "execution(* com.bank..*.*(..))",
                       "service package and subpackages"
                   ]
               ]
           }
       ]'::jsonb, 'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/core.html#aop-pointcuts-examples'),
       (169, 'Other pointcut designators', 5, 2,
        'Besides execution: within, this, target, args, @target, @args, @within, @annotation, and Spring-only bean.', '@Before("@annotation(com.bank.Audited) && args(accountId,..)")
public void audit(Long accountId) {...}', NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/core.html#aop-pointcuts-designators'),
       (170, '${…} vs #{…}', 5, 1,
        '${…} is a property placeholder resolved from the Environment. #{…} is a SpEL expression evaluated at runtime.', '@Value("${app.timeout:30}") int timeout;
@Value("#{systemProperties[''user.region'']}") String region;
@Value("#{ T(java.lang.Math).random() * 100 }") double random;', NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/core.html#expressions-beandef'),
       (171, 'Security expressions', 5, 6, 'SpEL expressions used in @PreAuthorize / @PostAuthorize and in URL rules.', '@PreAuthorize("hasRole(''ADMIN'') or #username == authentication.name")
public Account find(String username) {...}', NULL,
        'https://github.com/spring-projects/spring-security/blob/5.8.x/docs/modules/ROOT/pages/servlet/authorization/expression-based.adoc'),
       (172, 'Method security variables', 5, 6, 'Extra names available in method security expressions.', '@PostAuthorize("returnObject.owner == authentication.name")
public Account load(Long id) {...}

@PostFilter("filterObject.owner == authentication.name")
public List<Account> all() {...}', NULL,
        'https://github.com/spring-projects/spring-security/blob/5.8.x/docs/modules/ROOT/pages/servlet/authorization/expression-based.adoc'),
       (173, 'Request matcher order', 5, 6,
        'URL authorization rules are considered in the order they are declared: the first match wins.', 'http.authorizeHttpRequests(a -> a
  .antMatchers("/accounts/edit*").hasRole("ADMIN")
  .antMatchers("/accounts/**").hasAnyRole("USER","ADMIN")
  .anyRequest().authenticated());', NULL,
        'https://github.com/spring-projects/spring-security/blob/5.8.x/docs/modules/ROOT/pages/servlet/authorization/authorize-http-requests.adoc'),
       (174, 'Derived query methods', 5, 4,
        'Spring Data builds the query from the repository method name: subject (find…By, count…By, exists…By, delete…By) + predicate.', 'List<Person> findByLastnameIgnoreCaseOrderByFirstnameAsc(String lastname);
long countByLastname(String lastname);
boolean existsByEmail(String email);
Optional<Person> findFirstByOrderByAgeDesc();', NULL,
        'https://docs.spring.io/spring-data/jpa/docs/2.7.x/reference/html/#repositories.query-methods.query-creation'),
       (175, 'Actuator endpoint exposure', 7, 8,
        'Endpoints are enabled (they exist) and exposed (reachable over HTTP or JMX). Boot 2.x defaults below.', 'management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.shutdown.enabled=true', '[
           {
               "caption": "Boot 2.7 defaults",
               "headers": [
                   "Endpoint",
                   "Enabled",
                   "Web",
                   "JMX"
               ],
               "rows": [
                   [
                       "health",
                       "✓",
                       "exposed",
                       "exposed"
                   ],
                   [
                       "info",
                       "✓",
                       "–",
                       "exposed"
                   ],
                   [
                       "metrics",
                       "✓",
                       "–",
                       "exposed"
                   ],
                   [
                       "beans / env / configprops",
                       "✓",
                       "–",
                       "exposed"
                   ],
                   [
                       "mappings / conditions / loggers",
                       "✓",
                       "–",
                       "exposed"
                   ],
                   [
                       "shutdown",
                       "–",
                       "–",
                       "exposed if enabled"
                   ]
               ]
           }
       ]'::jsonb,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.endpoints.exposing'),
       (176, '/actuator/health', 6, 8, 'Shows application health information.', 'GET /actuator/health
{"status":"UP"}', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.endpoints.health'),
       (177, '/actuator/info', 6, 8, 'Displays arbitrary application info from InfoContributors.', 'GET /actuator/info
{"app":{"name":"Bank"},"build":{"version":"1.0"}}', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.endpoints.info'),
       (178, '/actuator/metrics', 6, 8, 'Shows metrics information from Micrometer.', 'GET /actuator/metrics/jvm.memory.max?tag=area:nonheap
GET /actuator/metrics/http.server.requests?tag=status:200', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.metrics.endpoint'),
       (179, '/actuator/loggers', 6, 8, 'Shows and modifies the configuration of loggers in the application.', 'POST /actuator/loggers/com.bank
Content-Type: application/json

{"configuredLevel": "DEBUG"}', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.loggers'),
       (180, '/actuator/beans · /env · /configprops · /mappings', 6, 8,
        'Introspection endpoints. beans: all beans. env: properties from the Environment. configprops: all @ConfigurationProperties. mappings: all @RequestMapping paths.',
        'GET /actuator/env/server.port', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.endpoints'),
       (181, '/actuator/conditions', 6, 8,
        'Shows the conditions evaluated on configuration and auto-configuration classes and why they did or did not match.',
        'GET /actuator/conditions', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.endpoints'),
       (182, '/actuator/shutdown', 6, 8,
        'Lets the application be gracefully shut down (POST). Only works with jar packaging.', 'management.endpoint.shutdown.enabled=true
management.endpoints.web.exposure.include=health,shutdown
# POST /actuator/shutdown', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/actuator.html#actuator.endpoints.enabling'),
       (183, 'Bean lifecycle', 7, 1,
        'Initialization: load bean definitions → BeanFactoryPostProcessors → instantiate → inject → BeanPostProcessors + init callbacks → ready. Destruction on context close.',
        NULL, NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/core.html#beans-factory-lifecycle-combined-effects'),
       (184, 'Singleton vs prototype', 7, 1,
        'singleton (default): one instance per container. prototype: a new instance on every injection / getBean().', '@Bean @Scope("prototype")
public Report report() { return new Report(); }', NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/core.html#beans-factory-scopes'),
       (185, 'JDK vs CGLIB proxies', 7, 2,
        'Spring AOP (and @Transactional) work through proxies. JDK dynamic proxies implement interfaces; CGLIB proxies subclass the target class.',
        NULL, '[
           {
               "caption": "Proxy types",
               "headers": [
                   "",
                   "JDK dynamic proxy",
                   "CGLIB"
               ],
               "rows": [
                   [
                       "Needs",
                       "an interface",
                       "a non-final class"
                   ],
                   [
                       "Proxy is a",
                       "interface impl",
                       "subclass of target"
                   ],
                   [
                       "Intercepts",
                       "interface methods",
                       "public/protected non-final methods"
                   ]
               ]
           }
       ]'::jsonb, 'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/core.html#aop-proxying'),
       (186, 'Advice order', 7, 2, 'How several pieces of advice on the same join point are ordered.', '@Aspect @Order(1)
public class SecurityAspect {...}

@Aspect @Order(2)
public class LoggingAspect {...}', NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/core.html#aop-ataspectj-advice-ordering'),
       (187, 'Transaction propagation', 7, 3,
        'What a @Transactional method does when called with or without an existing transaction. Default REQUIRED.', '@Transactional(propagation = Propagation.REQUIRES_NEW)
public void logAudit(AuditEntry e) {...}', '[
           {
               "caption": "Propagation",
               "headers": [
                   "Value",
                   "Tx exists",
                   "No tx"
               ],
               "rows": [
                   [
                       "REQUIRED",
                       "join it",
                       "create new"
                   ],
                   [
                       "REQUIRES_NEW",
                       "suspend, create new",
                       "create new"
                   ],
                   [
                       "NESTED",
                       "savepoint in it",
                       "create new"
                   ],
                   [
                       "SUPPORTS",
                       "join it",
                       "run without"
                   ],
                   [
                       "MANDATORY",
                       "join it",
                       "exception"
                   ],
                   [
                       "NOT_SUPPORTED",
                       "suspend, run without",
                       "run without"
                   ],
                   [
                       "NEVER",
                       "exception",
                       "run without"
                   ]
               ]
           }
       ]'::jsonb,
        'https://docs.spring.io/spring-framework/docs/5.3.x/javadoc-api/org/springframework/transaction/annotation/Propagation.html'),
       (188, 'Transaction isolation', 7, 3,
        'How much concurrent transactions can see of each other. Default DEFAULT = the database''s own default.',
        '@Transactional(isolation = Isolation.READ_COMMITTED)', '[
           {
               "caption": "Isolation levels: can the anomaly happen?",
               "headers": [
                   "Isolation",
                   "Dirty",
                   "Non-repeatable",
                   "Phantom"
               ],
               "rows": [
                   [
                       "READ_UNCOMMITTED",
                       "Yes",
                       "Yes",
                       "Yes"
                   ],
                   [
                       "READ_COMMITTED",
                       "No",
                       "Yes",
                       "Yes"
                   ],
                   [
                       "REPEATABLE_READ",
                       "No",
                       "No",
                       "Yes"
                   ],
                   [
                       "SERIALIZABLE",
                       "No",
                       "No",
                       "No"
                   ]
               ]
           }
       ]'::jsonb,
        'https://docs.spring.io/spring-framework/docs/5.3.x/javadoc-api/org/springframework/transaction/annotation/Isolation.html'),
       (189, 'Rollback rules', 7, 3, 'Which exceptions roll back a @Transactional method.', '@Transactional(rollbackFor = InsufficientFundsException.class,
               noRollbackFor = AuditException.class)', NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/data-access.html#transaction-declarative-rolling-back'),
       (190, 'Property source precedence', 7, 8,
        'Boot reads properties from many sources; later ones override earlier ones.', '# env var beats application.properties, command line beats both
SERVER_PORT=9000 java -jar app.jar --server.port=9100   # → 9100', NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.external-config'),
       (191, 'Config data file order', 7, 8, 'Order in which application.properties files are applied (later wins).',
        NULL, NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.external-config.files'),
       (192, 'Auto-configuration back-off', 7, 8,
        'Auto-configurations are @Configuration classes guarded by conditions, so they only apply when relevant and when you have not defined the bean yourself.',
        NULL, NULL,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.developing-auto-configuration'),
       (193, '@SpringBootTest webEnvironment', 7, 7, 'Controls whether @SpringBootTest starts a server.', '@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class AppIT { @LocalServerPort int port; }', '[
           {
               "caption": "webEnvironment",
               "headers": [
                   "Value",
                   "What you get"
               ],
               "rows": [
                   [
                       "MOCK (default)",
                       "web context, mock servlet env; use MockMvc"
                   ],
                   [
                       "RANDOM_PORT",
                       "real server, random port; use TestRestTemplate"
                   ],
                   [
                       "DEFINED_PORT",
                       "real server on server.port (8080)"
                   ],
                   [
                       "NONE",
                       "no web environment at all"
                   ]
               ]
           }
       ]'::jsonb,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.testing.spring-boot-applications'),
       (194, 'Test slices', 7, 7,
        'Annotations that load only one layer of the application, with matching auto-configuration.', NULL, '[
           {
               "caption": "Common slices",
               "headers": [
                   "Slice",
                   "Loads"
               ],
               "rows": [
                   [
                       "@WebMvcTest",
                       "@Controller, @ControllerAdvice, Filter, WebMvcConfigurer…; MockMvc"
                   ],
                   [
                       "@DataJpaTest",
                       "@Entity, repositories, embedded DB, TestEntityManager"
                   ],
                   [
                       "@JdbcTest",
                       "embedded DB, JdbcTemplate"
                   ],
                   [
                       "@JsonTest",
                       "ObjectMapper, @JsonComponent, JacksonTester"
                   ],
                   [
                       "@WebFluxTest",
                       "WebFlux controllers; WebTestClient"
                   ]
               ]
           }
       ]'::jsonb,
        'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/features.html#features.testing.spring-boot-applications.autoconfigured-tests'),
       (195, 'DispatcherServlet request flow', 7, 5,
        'Spring MVC''s front controller: every request goes through it and is delegated to special beans.', NULL, NULL,
        'https://docs.spring.io/spring-framework/docs/5.3.x/reference/html/web.html#mvc-servlet-sequence'),
       (196, 'Spring Security request flow', 7, 6,
        'Authentication answers "who are you?"; authorization answers "what may you do?". Both happen in servlet filters before the DispatcherServlet.',
        NULL, NULL,
        'https://github.com/spring-projects/spring-security/blob/5.8.x/docs/modules/ROOT/pages/servlet/architecture.adoc'),
       (197, 'Spring Boot default security', 7, 6,
        'What Boot configures when spring-boot-starter-security is on the classpath and you define nothing.', NULL,
        NULL, 'https://docs.spring.io/spring-boot/docs/2.7.18/reference/html/web.html#web.security')
ON CONFLICT (id) DO NOTHING;

INSERT INTO card_fact (card_id, position, text, important)
SELECT v.card_id, v.position, v.text, v.important
FROM (VALUES (1, 0, 'Is itself a @Component, so component scanning picks it up', false),
             (1, 1, 'Subclassed at runtime by CGLIB (proxyBeanMethods = true by default)', false),
             (1, 2,
              'Calling one @Bean method from another returns the same singleton, because the CGLIB proxy intercepts the call',
              true),
             (1, 3, 'Class and @Bean methods must not be final or private (CGLIB cannot override them)', true),
             (2, 0, 'Bean id defaults to the method name; override with name/value (aliases allowed)', false),
             (2, 1, 'initMethod / destroyMethod attributes; destroyMethod is inferred (public close() or shutdown())',
              false),
             (2, 2, 'Combine with @Scope, @Lazy, @Primary, @Profile, @DependsOn', false),
             (2, 3,
              'Declare BeanFactoryPostProcessors (e.g. PropertySourcesPlaceholderConfigurer) as static @Bean methods',
              true),
             (3, 0, 'basePackages / basePackageClasses; defaults to the package of the annotated class', false),
             (3, 1, 'includeFilters / excludeFilters (ANNOTATION, ASSIGNABLE_TYPE, REGEX, ASPECTJ, CUSTOM)', false),
             (3, 2, 'lazyInit = true makes every scanned singleton lazy (like @Lazy on each); default false = eager',
              false),
             (3, 3, 'Included in @SpringBootApplication', false),
             (3, 4, 'Scanning too broad a package (e.g. "com") slows startup; be specific', true),
             (4, 0,
              'Default bean id = class name with lowercase first letter (TransferServiceImpl → transferServiceImpl)',
              false),
             (4, 1, 'Specialisations: @Service, @Repository, @Controller (plus @Configuration)', false),
             (4, 2, 'Use @Bean instead for third-party classes you cannot annotate', false),
             (5, 0, 'No extra behaviour beyond @Component', false),
             (5, 1, 'Typical place for @Transactional', false),
             (6, 0,
              'Enables exception translation: native persistence exceptions become Spring''s DataAccessException hierarchy',
              false),
             (6, 1, 'Translation is done by PersistenceExceptionTranslationPostProcessor (auto-registered in Boot)',
              false),
             (6, 2, 'DataAccessException is unchecked (RuntimeException)', false),
             (7, 0, 'Add @ResponseBody (or use @RestController) to write the return value to the response body', false),
             (8, 0, 'Works on constructors, setters/methods and fields', false),
             (8, 1, 'Since Spring 4.3 a class with a single constructor needs no @Autowired', true),
             (8, 2, 'Resolution: match by type → narrow by @Qualifier/@Primary → fall back to parameter/field name',
              false),
             (8, 3, 'required = false, Optional<T> or @Nullable avoid failure when no bean exists', true),
             (8, 4, 'Injecting List<T> / Map<String,T> collects all beans of that type', false),
             (8, 5,
              'Field injection cannot be used with final fields and is harder to unit test; constructor injection is preferred for mandatory deps',
              true),
             (9, 0, 'Use at the injection point, and optionally on the bean definition', false),
             (9, 1, 'Without it (or @Primary) multiple candidates throw NoUniqueBeanDefinitionException', true),
             (9, 2, '@Qualifier wins over @Primary', false),
             (10, 0, 'Used on @Component classes or @Bean methods', false),
             (10, 1, 'Only one @Primary per type, or the ambiguity remains', false),
             (11, 0, 'Default value: ${server.port:8080}', false),
             (11, 1, 'SpEL: #{systemProperties[''user.region'']}, #{environment[''app.name'']}, #{bean.property}',
              false),
             (11, 2, 'Works on fields, constructor/method parameters', false),
             (11, 3, '${} resolves from the Environment; #{} evaluates SpEL. You can nest: #{${x} * 2}', true),
             (12, 0, 'Placed on a @Configuration class; repeatable', false),
             (12, 1, 'Prefixes: classpath:, file:, http:', false),
             (12, 2, 'Does not load YAML out of the box', true),
             (12, 3, 'Spring Boot loads application.properties/yml automatically', false),
             (13, 0, 'Expressions: "dev", "!prod", "dev & cloud", "dev | test"', false),
             (13, 1, 'Activate with spring.profiles.active (property, env var, -D) or @ActiveProfiles in tests', false),
             (13, 2, 'Beans without @Profile are always loaded', false),
             (13, 3, 'Profile "default" applies when nothing is activated', false),
             (14, 0, 'singleton (default): one per ApplicationContext; prototype: new instance on each request', false),
             (14, 1, 'Web: request, session, application, websocket', false),
             (14, 2,
              'Injecting a shorter-lived bean into a singleton requires proxyMode = ScopedProxyMode.TARGET_CLASS / INTERFACES',
              true),
             (14, 3, 'Spring does not call destroy callbacks (@PreDestroy) on prototype beans', true),
             (15, 0, 'Singletons are eager by default (created at startup)', false),
             (15, 1, 'On a @Configuration class: applies to all its @Bean methods', false),
             (15, 2, 'At an injection point: injects a lazy-resolution proxy', false),
             (16, 0, 'Lets you split config into modules (e.g. application + infrastructure)', false),
             (16, 1, 'Also accepts ImportSelector and ImportBeanDefinitionRegistrar (how @Enable* annotations work)',
              false),
             (16, 2, '@ImportResource imports XML config', false),
             (17, 0, 'Processed by CommonAnnotationBeanPostProcessor (registered automatically by annotation config)',
              false),
             (17, 1, 'Init order: constructor → DI → @PostConstruct → afterPropertiesSet() → @Bean(initMethod)', false),
             (17, 2, 'Destroy order: @PreDestroy → destroy() → @Bean(destroyMethod)', false),
             (17, 3,
              '@PreDestroy only runs when the context closes cleanly (context.close() or registerShutdownHook())',
              true),
             (17, 4, 'Never called for prototype beans', true),
             (17, 5, 'Package: javax.annotation (Spring 5 / Boot 2); jakarta.annotation in Spring 6 / Boot 3', false),
             (18, 0, 'Also controls destruction order (dependent destroyed first)', false),
             (19, 0, '@Resource injects by name first, then type; on fields and setters only', false),
             (19, 1, '@Inject behaves like @Autowired but has no required attribute; pair with @Named to qualify',
              false),
             (19, 2, '@Named (JSR-330) can also replace @Component', false),
             (20, 0, 'Foundation of @Profile and of all Spring Boot @ConditionalOn… annotations', false),
             (20, 1, 'Implement Condition.matches(ConditionContext, AnnotatedTypeMetadata)', false),
             (21, 0, 'Lets Java config and legacy XML config live side by side', false),
             (21, 1, 'Locations use resource prefixes: classpath:, file:', false),
             (21, 2, 'Java-config counterpart of <import resource="..."/> in XML', false),
             (22, 0, 'On a class: picked up by component scanning, like @Component', false),
             (22, 1, 'On an @Inject point: selects the bean by name', false),
             (22, 2,
              'Package javax.inject (Spring 5) / jakarta.inject (Spring 6); needs the JSR-330 jar on the classpath',
              false),
             (23, 0, 'At an injection point: makes the dependency optional (null if no bean), like required = false',
              false),
             (23, 1, 'Any annotation named Nullable is honoured for injection, e.g. JSR-305''s', false),
             (23, 2, 'Also used by Kotlin and IDEs for null-safety checks', false),
             (23, 3, 'Package org.springframework.lang (Spring 5 / 6)', false),
             (24, 0,
              'On a class: a proxy validates constrained method parameters and return values (MethodValidationPostProcessor, auto-configured in Boot)',
              false),
             (24, 1, 'On a @ConfigurationProperties class: validates the bound properties at startup, failing fast',
              false),
             (24, 2, 'Supports validation groups: @Validated(OnCreate.class); @Valid does not', false),
             (24, 3,
              'Method validation on a service throws ConstraintViolationException, not MethodArgumentNotValidException',
              true),
             (24, 4, 'Proxy-based, so self-invocation is not validated', false),
             (25, 0,
              'Explicit alias within one annotation: e.g. value and path on @RequestMapping, value and name on @Bean',
              false),
             (25, 1,
              'Explicit aliases must be declared on both attributes, have the same type and the same default value',
              true),
             (25, 2,
              'Alias in a meta-annotation: annotation = X.class overrides X''s attribute from a composed annotation (e.g. @GetMapping("/x") sets @RequestMapping''s path)',
              false),
             (25, 3,
              'Only honoured by Spring''s merged-annotation lookup (AnnotatedElementUtils / MergedAnnotations), not plain Java reflection',
              true),
             (25, 4, 'Setting both aliased attributes to different values fails with AnnotationConfigurationException',
              true),
             (25, 5, 'Package org.springframework.core.annotation', false),
             (26, 0, '@Aspect alone does not make a bean; also add @Component or declare a @Bean', true),
             (26, 1, 'Needs @EnableAspectJAutoProxy (auto-configured in Spring Boot with spring-boot-starter-aop)',
              false),
             (26, 2, 'Spring AOP is proxy-based and only advises method execution on Spring beans', false),
             (27, 0, 'JDK dynamic proxy if the bean implements an interface, otherwise CGLIB', false),
             (27, 1, 'proxyTargetClass = true forces CGLIB (Boot''s default)', false),
             (27, 2, 'JDK proxies implement the interfaces only: injecting by the concrete class fails', true),
             (27, 3, 'Self-invocation (this.method()) bypasses the proxy, so no advice runs', true),
             (27, 4, 'CGLIB cannot advise final classes or final/private methods', true),
             (28, 0, 'execution(modifiers? return-type declaring-type? name(params) throws?)', false),
             (28, 1, 'Wildcards: * (one element), .. (any number of params or sub-packages)', false),
             (28, 2, 'Other designators: within(), @annotation(), args(), bean(), target(), this(), @within()', false),
             (28, 3, 'Combine with &&, ||, !', false),
             (29, 0, 'Gets a JoinPoint (method signature, args, target)', false),
             (29, 1, 'Can only stop execution by throwing an exception', true),
             (30, 0, 'returning = "name" binds the return value to a parameter', false),
             (30, 1, 'Cannot change the return value (use @Around for that)', false),
             (31, 0, 'throwing = "name" binds the exception; the parameter type filters which exceptions match', false),
             (31, 1, 'Cannot swallow the exception, only rethrow or wrap it (use @Around to recover)', true),
             (32, 0, 'No access to the return value or exception', false),
             (33, 0, 'Takes ProceedingJoinPoint; call proceed() to invoke the target', false),
             (33, 1, 'The only advice that can skip the call, change arguments, or change the return value', true),
             (33, 2, 'Forgetting to return proceed()''s result returns null to the caller', true),
             (33, 3, 'Typical uses: caching, timing, retries', false),
             (34, 0, 'On a class: applies to every public method; method-level settings override', false),
             (34, 1,
              'propagation: REQUIRED (default), REQUIRES_NEW, NESTED, SUPPORTS, MANDATORY, NOT_SUPPORTED, NEVER; see the propagation table below',
              false),
             (34, 2,
              'isolation: DEFAULT uses the database''s own level (READ_COMMITTED on most DBs, REPEATABLE_READ on MySQL InnoDB); see the table below',
              false),
             (34, 3,
              'Dirty read: you see another transaction''s uncommitted change. Non-repeatable read: re-reading a row gives a different value. Phantom read: re-running a query returns new rows',
              false),
             (34, 4, 'Higher isolation means fewer anomalies but more locking and less concurrency', false),
             (34, 5, 'readOnly, timeout, rollbackFor / noRollbackFor', false),
             (34, 6,
              'Rolls back on RuntimeException and Error only; checked exceptions commit unless rollbackFor is set',
              true),
             (34, 7,
              'Proxy-based: self-invocation is not transactional, and in Spring 5 only public methods are advised',
              true),
             (34, 8, 'In a test method it rolls back at the end by default', true),
             (35, 0,
              'Requires a PlatformTransactionManager bean (DataSourceTransactionManager, JpaTransactionManager…)',
              false),
             (35, 1, 'Spring Boot auto-configures both', false),
             (36, 0, 'executionPhase = BEFORE_TEST_METHOD / AFTER_TEST_METHOD', false),
             (36, 1,
              'Repeatable; class-level scripts are overridden by method-level ones unless merged with @SqlMergeMode',
              false),
             (36, 2, '@SqlConfig controls separators, error mode, data source', false),
             (37, 0,
              'Attributes: separator, commentPrefix, encoding, dataSource, transactionManager, transactionMode, errorMode',
              false),
             (37, 1, 'errorMode: FAIL_ON_ERROR (default), CONTINUE_ON_ERROR, IGNORE_FAILED_DROPS', false),
             (37, 2, 'On the test class: global defaults; inside @Sql(config = ...): local override', false),
             (38, 0, 'OVERRIDE (default): method-level @Sql replaces the class-level declaration', false),
             (38, 1, 'MERGE: class-level scripts run first, then the method-level ones', false),
             (39, 0, '@Entity needs a no-arg constructor (can be protected) and an @Id', false),
             (39, 1, '@GeneratedValue(strategy = IDENTITY / SEQUENCE / TABLE / AUTO)', false),
             (39, 2, '@Table(name) and @Column(name) are optional, needed when names differ', false),
             (39, 3, 'Relationships: @OneToMany, @ManyToOne, @JoinColumn; @Transient excludes a field', false),
             (40, 0, 'Auto-configured by Spring Boot; needed manually in plain Spring', false),
             (40, 1, 'basePackages defaults to the annotated class''s package', false),
             (40, 2, 'Interfaces: Repository → CrudRepository → PagingAndSortingRepository → JpaRepository', false),
             (40, 3, 'Derived queries from method names: findByLastNameAndAgeGreaterThan(...)', false),
             (41, 0, 'nativeQuery = true for SQL', false),
             (41, 1, 'Bind parameters by position ?1 or by name :name with @Param', false),
             (41, 2, 'Update/delete queries also need @Modifying (and a transaction)', true),
             (42, 0, 'By default Boot scans the package of @SpringBootApplication and below', false),
             (42, 1, 'Pair with @EnableJpaRepositories(basePackages) if repositories also live elsewhere', false),
             (43, 0, 'IDENTITY: auto-increment column', false),
             (43, 1, 'SEQUENCE: database sequence (configurable with a sequence generator)', false),
             (43, 2, 'TABLE: a separate id table; AUTO (default): the provider chooses', false),
             (43, 3, 'With IDENTITY, Hibernate cannot batch inserts: the id is only known after each INSERT', true),
             (44, 0, '@ManyToOne is the owning side: its table holds the foreign key', false),
             (44, 1, '@OneToMany(mappedBy = "customer") is the inverse side of a bidirectional mapping', false),
             (44, 2, 'Default fetch: single-valued (…ToOne) is EAGER, collections (…ToMany) are LAZY', false),
             (44, 3, 'Touching a LAZY collection outside a transaction throws LazyInitializationException', true),
             (44, 4, 'cascade = CascadeType.ALL / PERSIST / REMOVE…; orphanRemoval = true deletes removed children',
              false),
             (45, 0, 'Use for derived or cached values', false),
             (45, 1, 'Not the same as Java''s transient keyword, which affects serialization', true),
             (46, 0, 'Without it an update/delete @Query fails, because Spring Data runs it as a select', true),
             (46, 1, 'Needs a transaction: @Transactional on the repository method or the calling service', false),
             (46, 2, 'Return int (rows affected) or void', false),
             (46, 3,
              'Bypasses the persistence context: set clearAutomatically = true so stale entities are not returned afterwards',
              true),
             (47, 0, 'Spring Data annotation (org.springframework.data.repository.query.Param)', false),
             (47, 1, 'Optional when compiling with -parameters (on by default in Boot)', false),
             (47, 2, 'Alternative: positional parameters ?1, ?2', false),
             (48, 0, 'Conversion done by HttpMessageConverters (Jackson for JSON) based on the Accept header', false),
             (48, 1, 'Return ResponseEntity<T> for full control of status and headers', false),
             (49, 0, 'Attributes: path/value, method, params, headers, consumes, produces', false),
             (49, 1, 'Class-level path is a prefix for all methods', false),
             (49, 2, 'Shortcuts: @GetMapping, @PostMapping, @PutMapping, @DeleteMapping, @PatchMapping', false),
             (50, 0,
              'GET: read (safe, idempotent); POST: create (not idempotent); PUT: replace (idempotent); PATCH: partial update; DELETE: remove (idempotent)',
              false),
             (50, 1, 'Typical POST response: 201 Created with a Location header', false),
             (51, 0,
              'Name can be omitted if it matches the parameter name (with -parameters compiler flag, on by default in Boot)',
              false),
             (51, 1, 'Type conversion is automatic (String → long, etc.)', false),
             (52, 0, 'required = true by default: a missing parameter gives 400 Bad Request', true),
             (52, 1, 'defaultValue implies required = false', false),
             (52, 2, 'Optional<T> is also allowed', false),
             (53, 0, 'Chosen by the Content-Type header', false),
             (53, 1, 'Combine with @Valid to trigger Bean Validation (400 on failure)', false),
             (54, 0, 'Implied on every method of a @RestController', false),
             (54, 1, 'Uses an HttpMessageConverter chosen by the Accept header', false),
             (55, 0, 'On a method: status for a successful return (e.g. 201, 204)', false),
             (55, 1, 'On an exception class: status when it propagates out of a controller', false),
             (56, 0, 'Both are required by default, like @RequestParam', false),
             (57, 0, 'Inside a controller: applies to that controller only', false),
             (57, 1, 'Inside a @ControllerAdvice class: applies globally', false),
             (57, 2, 'Pair with @ResponseStatus or return a ResponseEntity', false),
             (58, 0, '@RestControllerAdvice = @ControllerAdvice + @ResponseBody', false),
             (58, 1, 'Scope with basePackages, assignableTypes or annotations', false),
             (59, 0, 'On a parameter: populates the object from form/query parameters', false),
             (59, 1, 'On a method: runs before every handler in that controller to add model data', false),
             (60, 0,
              'In Spring Boot it switches off MVC auto-configuration; implement WebMvcConfigurer instead to customise',
              true),
             (61, 0, 'On a @RequestBody: failure gives 400 Bad Request (MethodArgumentNotValidException)', false),
             (61, 1, 'On a @ModelAttribute: errors go into a BindingResult parameter declared right after it', false),
             (61, 2, 'On a field: validates the nested object too', false),
             (61, 3,
              'Needs a provider on the classpath: spring-boot-starter-validation (no longer part of starter-web since Boot 2.3)',
              true),
             (61, 4, 'No validation groups: use Spring''s @Validated for that', false),
             (62, 0, '@NotNull: not null · @NotEmpty: not null and not empty · @NotBlank: contains non-whitespace text',
              false),
             (62, 1, '@Size(min, max) for strings and collections; @Min / @Max for numbers; @Email for addresses',
              false),
             (62, 2, 'The message attribute customises the error text', false),
             (62, 3, 'Constraints do nothing on their own: something must trigger validation (@Valid, @Validated)',
              true),
             (62, 4, 'Package javax.validation.constraints (Boot 2) / jakarta.validation.constraints (Boot 3)', false),
             (63, 0,
              'Runs before binding on each request to that controller (or to all controllers, inside @ControllerAdvice)',
              false),
             (63, 1, 'The method takes a WebDataBinder', false),
             (63, 2, 'setAllowedFields / setDisallowedFields protect against mass assignment', false),
             (64, 0, 'Auto-applied by Spring Boot when spring-boot-starter-security is present', false),
             (64, 1, 'Configure with a SecurityFilterChain bean (WebSecurityConfigurerAdapter is deprecated since 5.7)',
              false),
             (64, 2, 'Order matters: more specific matchers first, anyRequest() last', true),
             (64, 3,
              'Security 6: use authorizeHttpRequests() + requestMatchers(); mvcMatchers()/antMatchers() were removed in 6.0',
              false),
             (65, 0,
              'prePostEnabled is true by default, so a bare @EnableMethodSecurity already activates @PreAuthorize / @PostAuthorize / @PreFilter / @PostFilter',
              true),
             (65, 1, 'securedEnabled = true → @Secured; jsr250Enabled = true → @RolesAllowed (both off by default)',
              false),
             (65, 2,
              'Built on AuthorizationManager rather than AccessDecisionManager + voters, which makes custom rules simpler',
              false),
             (65, 3, 'mode = AdviceMode.ASPECTJ switches from proxies to AspectJ weaving', false),
             (65, 4, 'Same proxy caveats as other AOP: self-invocation is not secured', false),
             (66, 0,
              'prePostEnabled = true → @PreAuthorize / @PostAuthorize (off by default, unlike @EnableMethodSecurity)',
              true),
             (66, 1, 'securedEnabled = true → @Secured', false),
             (66, 2, 'jsr250Enabled = true → @RolesAllowed', false),
             (66, 3, 'Still what most 2V0-72.22 course material (Security 5.x) uses', false),
             (67, 0,
              'Expressions: hasRole(''ADMIN''), hasAnyRole(...), hasAuthority(...), isAuthenticated(), permitAll',
              false),
             (67, 1, 'Can reference arguments: #username == authentication.name', false),
             (67, 2, '@PostAuthorize can check returnObject', false),
             (67, 3, 'hasRole(''ADMIN'') checks authority ROLE_ADMIN (prefix added automatically)', true),
             (68, 0, 'No SpEL support', false),
             (68, 1, '@Secured needs the full name "ROLE_ADMIN"', true),
             (69, 0, 'Defaults: username "user", password "password", role USER', false),
             (69, 1, 'Attributes: username, roles, authorities', false),
             (69, 2, 'Comes from spring-security-test', false),
             (70, 0, 'filterObject refers to the current element', false),
             (70, 1, '@PostFilter removes elements the caller may not see from the returned collection', false),
             (70, 2, 'Enabled by prePostEnabled (on by default with @EnableMethodSecurity)', false),
             (70, 3, 'Filtering happens in memory after loading: for large data sets filter in the query instead',
              true),
             (71, 0, 'Loads an ApplicationContext for an integration test (plain Spring, no Boot)', false),
             (71, 1, 'The context is cached and reused across test classes with the same config', false),
             (72, 0, 'Already included in @SpringBootTest, @WebMvcTest, @DataJpaTest and @SpringJUnitConfig', false),
             (72, 1, 'JUnit 4 equivalent: @RunWith(SpringRunner.class)', false),
             (73, 0, 'classes = {...} or locations = "classpath:...xml"', false),
             (73, 1, 'With no attribute, looks for a static nested @Configuration class', false),
             (74, 0, 'Different profiles mean a different cached context', false),
             (75, 0, 'properties = "key=value" or locations = "classpath:test.properties"', false),
             (75, 1, 'Overrides OS env, system properties and @PropertySource values', false),
             (76, 0, 'Use when a test changes singleton state', false),
             (76, 1, 'Expensive: slows the suite because the context cannot be reused', true),
             (77, 0, '@Commit = @Rollback(false)', false),
             (77, 1, 'Applies to tests annotated with @Transactional', false),
             (78, 0, 'Finds the @SpringBootConfiguration by searching up the package tree', false),
             (78, 1, 'webEnvironment: MOCK (default, mock servlet), RANDOM_PORT, DEFINED_PORT, NONE', false),
             (78, 2, 'With RANDOM_PORT: inject TestRestTemplate (or WebTestClient); get port with @LocalServerPort',
              false),
             (78, 3, 'Add @AutoConfigureMockMvc to get a MockMvc bean in MOCK mode', false),
             (79, 0, 'Limit to one controller: @WebMvcTest(AccountController.class)', false),
             (79, 1, 'Services and repositories are not loaded; provide them with @MockBean', true),
             (79, 2, 'Security is auto-configured, so combine with @WithMockUser', false),
             (80, 0, 'Each test is @Transactional and rolls back by default', true),
             (80, 1,
              'Replaces the DataSource with an embedded DB; keep yours with @AutoConfigureTestDatabase(replace = NONE)',
              false),
             (80, 2, 'Does not load @Service / @Component beans', false),
             (81, 0,
              'Different from Mockito''s @Mock: @MockBean lives in the ApplicationContext and is injected into other beans',
              true),
             (81, 1, 'Mocks reset after each test', false),
             (81, 2, 'Each different set of @MockBeans creates a new cached context', false),
             (81, 3, 'Boot 3.4+: replaced by @MockitoBean / @MockitoSpyBean from Spring Framework 6.2', false),
             (82, 0,
              'Lives in spring-test (org.springframework.test.context.bean.override.mockito), so it also works without Spring Boot',
              false),
             (82, 1, 'Built on the Bean Override mechanism, which also powers @TestBean', false),
             (82, 2, 'Mocks and spies are reset after each test by default (reset = MockReset.AFTER)', false),
             (82, 3, 'Declared on fields of the test class, not in @Configuration classes (which @MockBean allowed)',
              true),
             (82, 4, 'Not part of 2V0-72.22 (Spring 5.3 / Boot 2.x): answer exam questions with @MockBean', true),
             (83, 0, 'Tests the full stack without starting a real server', false),
             (84, 0, 'A top-level @TestConfiguration class is not component-scanned: @Import it', true),
             (84, 1, 'A static nested @TestConfiguration is picked up automatically', false),
             (85, 0, 'Shortcut for @Value("${local.server.port}")', false),
             (86, 0, 'SpringRunner (Spring 4.3) is an alias for SpringJUnit4ClassRunner', false),
             (86, 1,
              'JUnit 5 ignores @RunWith: use @ExtendWith(SpringExtension.class), already included in @SpringBootTest and @SpringJUnitConfig',
              true),
             (86, 2, 'Boot 2.2+ test starters default to JUnit 5', false),
             (87, 0, 'replace = ANY (default, applied by @DataJpaTest): use an embedded H2 / HSQLDB / Derby', false),
             (87, 1, 'replace = NONE keeps the real configured DataSource (e.g. Testcontainers)', true),
             (87, 2, 'replace = AUTO_CONFIGURED: only replaces an auto-configured DataSource', false),
             (88, 0, 'Activate with @ExtendWith(MockitoExtension.class) on JUnit 5', false),
             (88, 1,
              'Unit tests: nothing is loaded from Spring, unlike @MockBean / @MockitoBean, which live in the ApplicationContext',
              true),
             (88, 2, '@InjectMocks tries constructor injection, then setters, then fields', false),
             (88, 3, '@Spy wraps a real object; unstubbed calls hit the real methods', false),
             (89, 0, 'By default the factory is a static method in the test class named after the field', false),
             (89, 1, 'Sibling of @MockitoBean / @MockitoSpyBean (same Bean Override mechanism)', false),
             (89, 2, 'Not part of 2V0-72.22 (Spring 5.3)', true),
             (90, 0, 'Put it on the main class in the root package, so scanning covers everything below', false),
             (90, 1, 'exclude / excludeName disable specific auto-configurations', false),
             (90, 2, 'SpringApplication.run(App.class, args) starts the app', false),
             (91, 0,
              'Candidates listed in META-INF/spring.factories (Boot 2) or META-INF/spring/…AutoConfiguration.imports (2.7+)',
              false),
             (91, 1, 'Each auto-config is guarded by @Conditional… annotations', false),
             (91, 2, 'Your own beans win: auto-config usually backs off via @ConditionalOnMissingBean', true),
             (91, 3, 'Debug with --debug or debug=true to print the conditions evaluation report', false),
             (92, 0, 'How starters switch features on: adding a jar activates its auto-config', false),
             (93, 0, '@ConditionalOnMissingBean is what lets your own definition override Boot''s default', false),
             (93, 1,
              'Evaluated in order of registration, so best used in auto-configuration classes, not your own config',
              true),
             (94, 0, 'Attributes: prefix, name, havingValue, matchIfMissing', false),
             (95, 0,
              'Attributes: value (classes) or name (fully qualified class names, for classes that may not be on the classpath)',
              false),
             (95, 1,
              'Typical use: run after DataSourceAutoConfiguration so @ConditionalOnBean(DataSource.class) can see the DataSource',
              false),
             (95, 2,
              'Only applies to auto-configuration classes (registered in the …AutoConfiguration.imports file), not to @Configuration classes found by component scanning',
              true),
             (95, 3, 'Before/after rules take priority over @AutoConfigureOrder', true),
             (95, 4, 'Since Boot 2.7: @AutoConfiguration(after = …, before = …) does the same thing', false),
             (96, 0, 'Lower value = applied earlier; default is 0 (Ordered.HIGHEST_PRECEDENCE runs first)', false),
             (96, 1,
              'Auto-configurations are sorted by class name, then by @AutoConfigureOrder, then by @AutoConfigureAfter/Before',
              false),
             (96, 2,
              'It does not affect your own @Configuration classes, and @Order has no effect on auto-configuration ordering',
              true),
             (96, 3, 'Use it for ordering in general; use @AutoConfigureAfter/Before to depend on a specific class',
              false),
             (97, 0, 'Relaxed binding: rewards.db-url, rewards.dbUrl, REWARDS_DBURL all map to dbUrl', false),
             (97, 1,
              'Register with @EnableConfigurationProperties(X.class), @ConfigurationPropertiesScan, or by making it a @Component',
              false),
             (97, 2, 'Immutable binding via constructor (needs @ConstructorBinding in Boot 2.2–2.7)', false),
             (97, 3, 'Supports JSR-303 validation with @Validated', false),
             (97, 4, 'Unlike @Value, it does not evaluate SpEL', true),
             (98, 0, 'Alternative: @ConfigurationPropertiesScan on the main class', false),
             (99, 0,
              'Operations: @ReadOperation (GET), @WriteOperation (POST), @DeleteOperation (DELETE); @Selector binds a path segment',
              false),
             (99, 1, 'Web-only: @WebEndpoint; JMX-only: @JmxEndpoint', false),
             (99, 2,
              'Over HTTP only health is exposed by default (Boot 2.5+); use management.endpoints.web.exposure.include',
              true),
             (99, 3, 'Custom health: implement HealthIndicator (or extend AbstractHealthIndicator) as a bean', false),
             (99, 4, 'Custom info: InfoContributor bean or info.* properties', false),
             (100, 0, '@SpringBootTest and the test slices search up the package tree for it', false),
             (100, 1, 'Only one per application, or the test configuration lookup becomes ambiguous', true),
             (101, 0, 'Defaults to the package of the annotated class', false),
             (101, 1, 'Alternative to listing each class in @EnableConfigurationProperties', false),
             (101, 2,
              'Not included in @SpringBootApplication (briefly was in 2.2.0, removed in 2.2.1): add it to the main class yourself',
              true),
             (102, 0, 'Boot 2.2–2.7: required on the class or constructor to switch to constructor binding', false),
             (102, 1,
              'Boot 3.0+: not needed when there is a single constructor; only used to pick one of several. It also moved to org.springframework.boot.context.properties.bind',
              true),
             (102, 2, 'Java records fit constructor binding naturally', false),
             (103, 0, 'Over HTTP: @ReadOperation → GET, @WriteOperation → POST, @DeleteOperation → DELETE', false),
             (103, 1, 'Simple parameters come from query parameters (read) or the JSON body (write)', false),
             (103, 2, 'A read returning null gives 404; a write/delete returning nothing gives 204', false),
             (103, 3, 'Use @Selector to bind path segments', false),
             (104, 0, '/actuator/release-notes/1.2 → @Selector String version = "1.2"', false),
             (104, 1, 'match = Match.ALL_REMAINING captures all remaining segments into a String[]', false),
             (105, 0, 'Use the same operations (@ReadOperation, …) as @Endpoint', false),
             (105, 1, 'Still subject to management.endpoints.web.exposure / management.endpoints.jmx.exposure', false),
             (106, 0,
              'Pulls in: spring-boot, spring-boot-autoconfigure, spring-boot-starter-logging, spring-core, jakarta.annotation-api, snakeyaml',
              false),
             (106, 1, 'spring-boot-autoconfigure is what makes @EnableAutoConfiguration work', false),
             (106, 2, 'snakeyaml is why application.yml works out of the box', false),
             (106, 3,
              'Starters have no version in your POM: the version comes from the spring-boot-dependencies BOM (via the parent)',
              true),
             (107, 0, 'Sets java.version (1.8 in 2.7), UTF-8 source encoding and maven.compiler source/target', false),
             (107, 1,
              'Resource filtering on application*.properties / application*.yml using @…@ delimiters (not ${…})',
              false),
             (107, 2,
              'Pre-configures (pluginManagement only) spring-boot-maven-plugin''s repackage goal, compiler -parameters, failsafe, jar/war manifest',
              false),
             (107, 3,
              'It is not required: without it, import spring-boot-dependencies with <scope>import</scope> in <dependencyManagement>',
              true),
             (107, 4, 'Override a managed version with a property, e.g. <jackson-bom.version>', false),
             (108, 0,
              'Pulls in: spring-boot-starter, spring-boot-starter-json, spring-boot-starter-tomcat, spring-web, spring-webmvc',
              false),
             (108, 1,
              'Auto-configures DispatcherServlet, Jackson HttpMessageConverters, error handling (/error) and the embedded server on port 8080',
              false),
             (108, 2,
              'Since Boot 2.3 it no longer includes spring-boot-starter-validation: @Valid does nothing until you add it',
              true),
             (108, 3,
              'Switch server: exclude spring-boot-starter-tomcat and add spring-boot-starter-jetty or -undertow',
              false),
             (109, 0,
              'Pulls in: spring-boot-starter, hibernate-validator, tomcat-embed-el (expression language for messages)',
              false),
             (109, 1, 'Split out of the web and webflux starters in Boot 2.3: add it yourself', true),
             (109, 2, 'Enables @Valid on @RequestBody and @Validated method validation', false),
             (110, 0,
              'Pulls in: spring-boot-starter, spring-web, jackson-databind, jackson-datatype-jdk8, jackson-datatype-jsr310, jackson-module-parameter-names',
              false),
             (110, 1, 'jsr310 module: java.time types (LocalDate…) serialize correctly', false),
             (110, 2, 'Boot auto-configures one ObjectMapper bean; tune it with spring.jackson.* properties', false),
             (111, 0,
              'Pulls in: spring-boot-starter, spring-boot-starter-json, spring-boot-starter-reactor-netty, spring-web, spring-webflux',
              false),
             (111, 1, 'Default server is Reactor Netty (not Tomcat)', false),
             (111, 2, 'Provides WebClient, the non-blocking alternative to RestTemplate', false),
             (111, 3, 'Test slice: @WebFluxTest with WebTestClient', false),
             (112, 0, 'Pulls in: spring-boot-starter, HikariCP, spring-jdbc', false),
             (112, 1,
              'Auto-configures DataSource (HikariCP is the default pool), JdbcTemplate, NamedParameterJdbcTemplate and a DataSourceTransactionManager',
              false),
             (112, 2,
              'No JDBC driver included: add one (h2, postgresql…). With only an embedded driver (H2/HSQL/Derby) and no URL, Boot creates an embedded database',
              true),
             (112, 3, 'Runs schema.sql / data.sql (embedded databases only by default)', false),
             (113, 0,
              'Pulls in: spring-boot-starter-aop, spring-boot-starter-jdbc, hibernate-core, spring-data-jpa, spring-aspects, jakarta.persistence-api, jakarta.transaction-api',
              false),
             (113, 1, 'So it includes everything from starter-jdbc (HikariCP, JdbcTemplate) and starter-aop', false),
             (113, 2,
              'Auto-configures EntityManagerFactory, JpaTransactionManager and repository scanning from the main class package',
              false),
             (113, 3, 'No JDBC driver included: add one', true),
             (113, 4, 'javax.persistence in Boot 2.x (jakarta.persistence-api 2.2 still uses the javax.* package)',
              true),
             (114, 0, 'Pulls in: spring-boot-starter, spring-aop, aspectjweaver', false),
             (114, 1, 'Auto-configuration enables @AspectJ support: no @EnableAspectJAutoProxy needed', false),
             (114, 2,
              'Boot uses CGLIB (class-based) proxies by default; set spring.aop.proxy-target-class=false for JDK interface proxies',
              true),
             (115, 0, 'Pulls in: spring-boot-starter, spring-aop, spring-security-config, spring-security-web', false),
             (115, 1, 'As soon as it is on the classpath, every endpoint (including Actuator) requires authentication',
              true),
             (115, 2,
              'Default user is "user" with a random password printed at WARN level at startup ("Using generated security password: …")',
              true),
             (115, 3, 'Form login or HTTP Basic, chosen by the request''s Accept header', false),
             (115, 4, 'Defining your own SecurityFilterChain bean switches off the default web security', false),
             (116, 0,
              'Pulls in: spring-boot-starter, spring-security-config, spring-security-core, spring-security-oauth2-resource-server, spring-security-oauth2-jose',
              false),
             (116, 1, 'jose = JWT support (validating bearer tokens)', false),
             (116, 2, 'Configure the issuer with spring.security.oauth2.resourceserver.jwt.issuer-uri', false),
             (117, 0,
              'Pulls in: spring-test, spring-boot-test, spring-boot-test-autoconfigure, junit-jupiter, mockito-core, mockito-junit-jupiter, assertj-core, hamcrest, json-path, jsonassert, xmlunit-core',
              false),
             (117, 1,
              'Since Boot 2.4 the JUnit 5 vintage engine is removed: JUnit 4 tests need org.junit.vintage:junit-vintage-engine',
              true),
             (117, 2, 'Declare with <scope>test</scope>', false),
             (117, 3, 'spring-boot-test-autoconfigure provides the slices: @WebMvcTest, @DataJpaTest…', false),
             (118, 0, 'Pulls in: spring-boot-starter, spring-boot-actuator-autoconfigure, micrometer-core', false),
             (118, 1, 'Endpoints under /actuator; only /actuator/health is exposed over HTTP by default', false),
             (118, 2, 'micrometer-core supplies the MeterRegistry behind /actuator/metrics', false),
             (119, 0, 'starter-logging (the default): logback-classic, log4j-to-slf4j, jul-to-slf4j', false),
             (119, 1,
              'starter-tomcat (default server for starter-web): tomcat-embed-core, tomcat-embed-el, tomcat-embed-websocket',
              false),
             (119, 2, 'Alternatives: spring-boot-starter-jetty, -undertow, -log4j2, -reactor-netty', false),
             (119, 3, 'To swap: exclude the default starter, then add the alternative', true),
             (120, 0,
              'Follows normal precedence: --spring.profiles.active=prod beats the value in application.properties',
              false),
             (120, 1, 'If none is active, the "default" profile is used (change with spring.profiles.default)', false),
             (120, 2, 'Activating a profile loads application-{profile}.properties on top of application.properties',
              false),
             (120, 3,
              'Can only be set in non-profile-specific documents (not in application-dev.properties or under spring.config.activate.on-profile)',
              true),
             (121, 0,
              'spring.profiles.group.production=proddb,prodmq → activating production also activates proddb and prodmq',
              false),
             (121, 1, 'include can only be used in non-profile-specific documents', true),
             (122, 0,
              'Imported files are treated as documents inserted immediately below the importing one, so their values win over the importing file',
              false),
             (122, 1, 'Each location is imported only once', false),
             (122, 2,
              'A missing file fails startup (ConfigDataLocationNotFoundException) unless prefixed with optional:',
              true),
             (123, 0,
              'Default locations (later wins): classpath:/, classpath:/config/, file:./, file:./config/, file:./config/*/',
              false),
             (123, 1, 'spring.config.location REPLACES the defaults; spring.config.additional-location ADDS to them',
              true),
             (123, 2,
              'Read very early: set as environment property, system property or command-line argument, not in application.properties',
              false),
             (123, 3, 'spring.config.name changes the base name (default "application")', false),
             (124, 0, 'true makes every bean lazy: created when first needed instead of at startup', false),
             (124, 1, 'Faster startup, but configuration errors surface later (at first use)', false),
             (124, 2, 'Opt a single bean out with @Lazy(false)', false),
             (125, 0,
              'debug=true (or --debug) prints the CONDITIONS EVALUATION REPORT: which auto-configurations matched and why',
              false),
             (125, 1, 'It does not set your own loggers to DEBUG: use logging.level.* for that', true),
             (125, 2, 'The same report is available at runtime via /actuator/conditions', false),
             (126, 0, 'Levels: TRACE, DEBUG, INFO, WARN, ERROR, FATAL, OFF', false),
             (126, 1, 'logging.level.root sets the root logger', false),
             (126, 2, 'Can be changed at runtime with POST /actuator/loggers/{name}', false),
             (127, 0, 'server.port=0 picks a free random port', false),
             (127, 1, 'server.port=-1 switches HTTP off but still creates a WebApplicationContext', false),
             (127, 2, 'In tests use webEnvironment = RANDOM_PORT and inject @LocalServerPort', false),
             (128, 0, 'server.servlet.context-path=/bank → GET /bank/accounts', false),
             (128, 1, 'A trailing slash is stripped', false),
             (129, 0,
              'If no URL is set and an embedded driver (H2, HSQL, Derby) is on the classpath, Boot creates an embedded database',
              false),
             (129, 1, 'The driver class is usually deduced from the URL', false),
             (129, 2, 'spring.datasource.hikari.* tunes the default HikariCP pool', false),
             (130, 0,
              'Scripts loaded by default: optional:classpath*:schema.sql and data.sql (plus schema-${platform}.sql)',
              false),
             (130, 1,
              'Default embedded: scripts run only against an in-memory embedded database; set always for a real DB',
              true),
             (130, 2, 'Fails fast on script errors by default (spring.sql.init.continue-on-error=false)', false),
             (130, 3,
              'Runs before JPA''s EntityManagerFactory by default; see spring.jpa.defer-datasource-initialization',
              false),
             (130, 4, 'Replaced spring.datasource.initialization-mode in Boot 2.5', false),
             (131, 0,
              'Default: create-drop for an embedded database (H2, HSQL, Derby) when no schema manager (Flyway/Liquibase) is detected; none otherwise',
              true),
             (131, 1, 'import.sql on the classpath is run when ddl-auto is create or create-drop', false),
             (131, 2, 'validate checks entities against the schema without changing it', false),
             (132, 0, '@DataJpaTest sets it to true by default (disable with @DataJpaTest(showSql = false))', false),
             (132, 1, 'Prints to stdout; for real logging use logging.level.org.hibernate.SQL=DEBUG', false),
             (133, 0, 'On by default in web apps; Boot logs a warning at startup unless you set it explicitly', true),
             (133, 1,
              'Lets lazy associations load during view rendering, but keeps a DB connection for the whole request',
              false),
             (133, 2, 'Set false to turn it off', false),
             (134, 0, 'Needed when data.sql inserts into tables that Hibernate creates via ddl-auto', false),
             (134, 1, 'By default scripts run BEFORE Hibernate, so data.sql fails if the table does not exist yet',
              true),
             (135, 0, '* exposes all (quote it in YAML: "*")', false),
             (135, 1, 'exclude wins over include', false),
             (135, 2, 'JMX has its own pair: management.endpoints.jmx.exposure.include defaults to *', false),
             (135, 3, 'Exposed is not the same as enabled: all endpoints except shutdown are enabled by default', true),
             (136, 0, 'when-authorized uses management.endpoint.health.roles', false),
             (136, 1, 'With the default (never), /actuator/health only returns {"status":"UP"}', true),
             (137, 0, 'management.server.port defaults to the main server port', false),
             (137, 1, 'management.server.port=-1 disables HTTP endpoints', false),
             (137, 2, 'Example: base-path=/manage → /manage/health', false),
             (138, 0,
              'In Boot 2.7 the env contributor (which publishes info.*) is disabled by default; set management.info.env.enabled=true',
              true),
             (138, 1,
              'build and git contributors are on by default (when build-info.properties / git.properties exist); env, java and os are off',
              false),
             (139, 0, 'Only used by Boot''s auto-configured in-memory UserDetailsService', false),
             (139, 1,
              'Ignored once you define your own UserDetailsService, AuthenticationProvider or AuthenticationManager bean',
              true),
             (140, 0, 'Plain Spring defaults to JDK proxies when an interface exists; Spring Boot defaults to CGLIB',
              true),
             (140, 1, 'Affects AOP and @Transactional proxies', false),
             (141, 0, 'AnnotationConfigApplicationContext: standalone Java config', false),
             (141, 1, 'ClassPathXmlApplicationContext / FileSystemXmlApplicationContext: XML', false),
             (141, 2,
              'Boot uses AnnotationConfigServletWebServerApplicationContext for servlet web apps, AnnotationConfigApplicationContext otherwise',
              false),
             (141, 3, 'Singletons are created eagerly at refresh(); close() runs destroy callbacks', false),
             (142, 0, 'Method: postProcessBeanFactory(ConfigurableListableBeanFactory)', false),
             (142, 1, 'Example: PropertySourcesPlaceholderConfigurer resolves ${…} placeholders', false),
             (142, 2,
              'Declare as a static @Bean method, so it is created without instantiating its @Configuration class',
              true),
             (142, 3, 'Calling getBean() inside one causes premature bean instantiation', true),
             (143, 0, 'postProcessBeforeInitialization: before @PostConstruct / afterPropertiesSet / init-method',
              false),
             (143, 1,
              'postProcessAfterInitialization: after them; may return a wrapper. This is where AOP proxies are created',
              false),
             (143, 2,
              'Examples: AutowiredAnnotationBeanPostProcessor, CommonAnnotationBeanPostProcessor (@PostConstruct)',
              false),
             (143, 3,
              'Return type of the @Bean method should be the implementation or BeanPostProcessor so the container detects it early',
              true),
             (144, 0,
              'The docs recommend NOT using them (they couple code to Spring): prefer @PostConstruct / @PreDestroy or @Bean(initMethod, destroyMethod)',
              true),
             (144, 1, 'Order with all three: @PostConstruct → afterPropertiesSet() → custom init-method', false),
             (144, 2, 'Destroy order: @PreDestroy → destroy() → custom destroy-method', false),
             (145, 0, 'Methods: getObject(), getObjectType(), isSingleton()', false),
             (145, 1,
              'getBean("myFactory") returns the produced object; getBean("&myFactory") returns the FactoryBean itself',
              true),
             (145, 2, 'Useful for complex construction logic that does not fit Java config', false),
             (146, 0, 'getProperty(key), getProperty(key, type, default), getRequiredProperty(key)', false),
             (146, 1, 'getActiveProfiles(), acceptsProfiles(Profiles.of("prod"))', false),
             (146, 2,
              'Properties come from an ordered set of PropertySources; in StandardEnvironment, JVM system properties win over OS environment variables',
              false),
             (146, 3, '@PropertySource adds a file to it', false),
             (147, 0, 'CommandLineRunner.run(String... args): raw arguments', false),
             (147, 1, 'ApplicationRunner.run(ApplicationArguments args): parsed options (--name=value)', false),
             (147, 2, 'Order several runners with @Order or Ordered', false),
             (148, 0,
              'queryForObject(sql, Class, args…): single value; queryForObject(sql, RowMapper, args…): single object',
              false),
             (148, 1,
              'queryForObject / queryForMap throw IncorrectResultSizeDataAccessException unless exactly one row (EmptyResultDataAccessException for zero)',
              true),
             (148, 2, 'queryForList(sql): List<Map<String,Object>>, one map per row keyed by column name', false),
             (148, 3, 'queryForMap(sql): one row as a Map', false),
             (148, 4, 'query(sql, RowMapper | RowCallbackHandler | ResultSetExtractor, args…)', false),
             (148, 5, 'update(sql, args…): insert / update / delete, returns rows affected; execute(sql): DDL', false),
             (148, 6, 'Translates SQLException into unchecked DataAccessException', false),
             (149, 0,
              'None of them should call rs.next() per row: JdbcTemplate iterates (except ResultSetExtractor, which gets the whole ResultSet)',
              true),
             (150, 0, 'Parameter sources: Map, MapSqlParameterSource, BeanPropertySqlParameterSource', false),
             (150, 1, 'getJdbcOperations() exposes the wrapped JdbcTemplate', false),
             (150, 2, 'Auto-configured by Boot alongside JdbcTemplate', false),
             (151, 0, 'SQLException and JPA/Hibernate exceptions are translated and wrapped (original kept as cause)',
              false),
             (151, 1,
              'EmptyResultDataAccessException: expected at least one row, got zero (extends IncorrectResultSizeDataAccessException)',
              false),
             (151, 2, 'DataIntegrityViolationException: insert/update violates a constraint', false),
             (151, 3, 'JDBC translation uses SQLErrorCodeSQLExceptionTranslator (vendor codes in sql-error-codes.xml)',
              false),
             (151, 4, '@Repository enables translation for JPA / Hibernate DAOs', false),
             (152, 0,
              'Implementations: DataSourceTransactionManager (JDBC), JpaTransactionManager, JtaTransactionManager',
              false),
             (152, 1, 'TransactionException is unchecked', false),
             (152, 2, '@EnableTransactionManagement looks for a bean of this type (Boot auto-configures one)', false),
             (153, 0, 'execute(status -> {...}) returns a value; executeWithoutResult(status -> {...})', false),
             (153, 1, 'Roll back by calling status.setRollbackOnly() (or throwing a RuntimeException)', false),
             (153, 2,
              'Thread-safe, but holds settings (propagation, isolation, timeout): use separate instances for different settings',
              false),
             (154, 0,
              'CrudRepository: save, saveAll, findById (Optional), findAll (Iterable), count, existsById, deleteById, delete',
              false),
             (154, 1, 'PagingAndSortingRepository: findAll(Sort), findAll(Pageable) → Page', false),
             (154, 2,
              'JpaRepository (also QueryByExampleExecutor): findAll returns List, flush, saveAndFlush, deleteAllInBatch, getReferenceById',
              false),
             (154, 3, 'getOne and getById are deprecated in Spring Data JPA 2.7: use getReferenceById', true),
             (154, 4, 'Implementations are generated at runtime as proxies; no class to write', false),
             (155, 0, 'Builders: ok(body), created(uri), noContent(), notFound(), badRequest(), status(…)', false),
             (155, 1, 'Body written by an HttpMessageConverter (Jackson for JSON)', false),
             (155, 2, 'Typical for POST: 201 Created with a Location header', false),
             (156, 0,
              'getForObject / getForEntity, postForObject / postForEntity / postForLocation, put, delete, exchange (any method, full control)',
              false),
             (156, 1, 'Throws HttpClientErrorException / HttpServerErrorException on 4xx / 5xx', false),
             (156, 2, 'In maintenance mode since 5.0: WebClient is recommended for new code', true),
             (156, 3, 'In Boot, build it with the auto-configured RestTemplateBuilder', false),
             (157, 0, 'perform(get("/x")).andExpect(status().isOk()).andExpect(jsonPath("$.name").value("Kate"))',
              false),
             (157, 1, 'Auto-configured by @WebMvcTest, or by @SpringBootTest + @AutoConfigureMockMvc', false),
             (157, 2, 'MockMvcBuilders.standaloneSetup(controller) or webAppContextSetup(ctx) without Boot', false),
             (158, 0,
              'Auto-configured with @SpringBootTest(webEnvironment = RANDOM_PORT or DEFINED_PORT); relative URLs go to the running server',
              false),
             (158, 1, 'Does NOT throw on 4xx / 5xx: check the ResponseEntity status instead', true),
             (158, 2, 'withBasicAuth(user, pwd) for secured endpoints', false),
             (159, 0,
              'DelegatingFilterProxy: a plain servlet Filter that looks up a bean (springSecurityFilterChain) and calls it',
              false),
             (159, 1, 'FilterChainProxy: that bean; delegates to the matching SecurityFilterChain', false),
             (159, 2, 'Also clears the SecurityContext after the request and applies the HttpFirewall', false),
             (160, 0, 'Only the first SecurityFilterChain that matches is invoked', true),
             (160, 1,
              'Declaring a SecurityFilterChain @Bean replaces Boot''s default (WebSecurityConfigurerAdapter is deprecated in 5.7+)',
              false),
             (160, 2,
              'authorizeHttpRequests (AuthorizationFilter) supersedes authorizeRequests (FilterSecurityInterceptor)',
              false),
             (161, 0, 'Default strategy: ThreadLocal (alternatives MODE_INHERITABLETHREADLOCAL, MODE_GLOBAL)', true),
             (161, 1,
              'Authentication: principal (often UserDetails), credentials (often the password, erased after login), authorities (GrantedAuthority, e.g. ROLE_ADMIN)',
              false),
             (161, 2,
              'Before login, an Authentication is the input to AuthenticationManager; afterwards it is the current user',
              false),
             (162, 0,
              'Each AuthenticationProvider handles one kind of authentication (DaoAuthenticationProvider = username/password via UserDetailsService)',
              false),
             (162, 1, 'If no provider supports the Authentication type: ProviderNotFoundException', false),
             (162, 2, 'ProviderManager can have a parent AuthenticationManager and erases credentials by default',
              false),
             (163, 0, 'UserDetailsService.loadUserByUsername(String) throws UsernameNotFoundException', false),
             (163, 1,
              'UserDetails: getUsername, getPassword, getAuthorities, isEnabled, isAccountNonExpired, isAccountNonLocked, isCredentialsNonExpired',
              false),
             (163, 2,
              'Built-ins: InMemoryUserDetailsManager, JdbcUserDetailsManager (default users / authorities tables)',
              false),
             (163, 3, 'Declaring one as a bean disables Boot''s default user', false),
             (164, 0, 'Stored format: {id}encodedPassword, e.g. {bcrypt}$2a$10$…, {noop}password', false),
             (164, 1, 'PasswordEncoderFactories.createDelegatingPasswordEncoder() encodes with bcrypt by default',
              false),
             (164, 2,
              'A password without a prefix fails: IllegalArgumentException: There is no PasswordEncoder mapped for the id "null"',
              true),
             (164, 3, '{noop} = plain text (NoOpPasswordEncoder), for demos only', false),
             (165, 0, 'The entry name is the bean name minus "HealthIndicator" (MyHealthIndicator → "my")', false),
             (165, 1, 'Built-ins are auto-configured: db, diskSpace, ping…', false),
             (165, 2, 'Overall status: DOWN > OUT_OF_SERVICE > UP > UNKNOWN (the most severe wins)', false),
             (165, 3, 'HTTP status: DOWN and OUT_OF_SERVICE → 503; UP and unmapped statuses → 200', false),
             (166, 0, 'Built-in: build, git (on by default when their files exist), env, java, os (off by default)',
              false),
             (167, 0, 'Inject it to register custom metrics', false),
             (167, 1, 'Exposed via /actuator/metrics/{name}', false),
             (167, 2, 'Micrometer is a vendor-neutral facade (Prometheus, Datadog…)', false),
             (168, 0, 'Format: execution(modifiers? ret-type declaring-type?name(params) throws?)', false),
             (168, 1, '* = any return type / any name part; .. in package = any subpackage', false),
             (168, 2,
              '() = no params, (..) = any number, (*) = exactly one of any type, (*,String) = two, second a String',
              false),
             (168, 3, 'Combine with &&, || and !', false),
             (168, 4, 'Spring AOP only supports method execution join points (no field access, no constructor calls)',
              true),
             (169, 0, 'within(com.bank.service..*): any join point in that package', false),
             (169, 1, 'this(Type): the proxy implements Type; target(Type): the target object is a Type', false),
             (169, 2, 'args(Long,..): the arguments at runtime', false),
             (169, 3, '@annotation(Audited): the method carries @Audited; @within / @target: the type carries it',
              false),
             (169, 4, 'bean(*Service): Spring-only, matches by bean name', false),
             (169, 5, 'Unsupported AspectJ designators (call, get, set, cflow…) throw IllegalArgumentException', true),
             (170, 0, '${db.url:jdbc:h2:mem:x}: text after : is the default', false),
             (170, 1, '#{…} can call methods, do maths, reference beans by name: #{accountService.limit * 2}', false),
             (170, 2, 'Predefined in SpEL: systemProperties, systemEnvironment, environment (no # needed)', false),
             (170, 3, 'Combine them: #{''${app.name}''.toUpperCase()}', false),
             (170, 4,
              'Without a PropertySourcesPlaceholderConfigurer, an unresolved ${…} is injected as the literal text (Boot configures one for you)',
              true),
             (171, 0, 'hasRole(''ADMIN''), hasAnyRole(…), hasAuthority(''ROLE_ADMIN''), hasAnyAuthority(…)', false),
             (171, 1,
              'hasRole adds the ROLE_ prefix automatically; hasAuthority does not: hasRole(''ADMIN'') = hasAuthority(''ROLE_ADMIN'')',
              true),
             (171, 2, 'permitAll / denyAll: always true / false', false),
             (171, 3,
              'isAnonymous(), isRememberMe(), isAuthenticated() (not anonymous), isFullyAuthenticated() (not anonymous and not remember-me)',
              false),
             (171, 4, 'principal, authentication: the current user', false),
             (171, 5, 'hasPermission(target, permission): delegates to a PermissionEvaluator', false),
             (172, 0,
              '#paramName: any method argument, by name (needs -parameters, debug info, @P or Spring Data @Param)',
              false),
             (172, 1, 'returnObject: the return value, in @PostAuthorize', false),
             (172, 2, 'filterObject: the current element, in @PreFilter / @PostFilter', false),
             (172, 3, 'filterTarget: which argument @PreFilter filters when there are several collections', false),
             (173, 0, 'Put the most specific matchers first and anyRequest() last', true),
             (173, 1, 'A broad rule like /** declared first hides everything after it', false),
             (173, 2, 'In 5.8: requestMatchers(…) is the new style; antMatchers / mvcMatchers are the older ones',
              false),
             (174, 0, 'The first By separates subject and criteria: findByEmailAddressAndLastname', false),
             (174, 1,
              'Keywords: And, Or, Between, LessThan, GreaterThan, Like, Containing, IgnoreCase, OrderBy…Asc/Desc, Distinct',
              false),
             (174, 2, 'Top / First limit results: findFirstByOrderByLastnameAsc, findTop10By…', false),
             (174, 3,
              'A single-entity return type with more than one result throws IncorrectResultSizeDataAccessException',
              true),
             (174, 4, 'Nested properties: findByAddressZipCode traverses address.zipCode', false),
             (175, 0, 'Only health is exposed over HTTP by default; over JMX everything enabled is exposed', true),
             (175, 1, 'All endpoints except shutdown are enabled by default', true),
             (175, 2,
              'With Spring Security on the classpath, POST endpoints (loggers, shutdown) get 403 unless CSRF is handled',
              false),
             (176, 0, 'The only endpoint exposed over HTTP by default', false),
             (176, 1,
              'Aggregates all HealthIndicator beans; overall status is the most severe (DOWN > OUT_OF_SERVICE > UP > UNKNOWN)',
              false),
             (176, 2, 'Returns 503 for DOWN / OUT_OF_SERVICE, 200 otherwise', false),
             (176, 3, 'Details hidden by default (show-details=never)', false),
             (177, 0, 'Not exposed over HTTP by default', true),
             (177, 1,
              'info.* properties only show if management.info.env.enabled=true (env contributor is off by default in 2.7)',
              true),
             (177, 2, 'build and git info appear when META-INF/build-info.properties / git.properties exist', false),
             (178, 0, '/actuator/metrics lists metric names; /actuator/metrics/{name} shows one', false),
             (178, 1, 'Drill down by tag: ?tag=KEY:VALUE', false),
             (178, 2, 'Not exposed over HTTP by default', false),
             (179, 0, 'GET /actuator/loggers/{name} shows configured and effective level', false),
             (179, 1, 'POST {"configuredLevel":"DEBUG"} changes the level at runtime; null resets it', false),
             (179, 2, 'With default Spring Security config, the POST gets 403 (CSRF)', true),
             (180, 0, 'None exposed over HTTP by default', false),
             (180, 1, 'env and configprops mask sensitive values (password, secret, key…)', false),
             (180, 2, 'mappings is handy for checking which controller handles a URL', false),
             (181, 0, 'Runtime version of the --debug conditions evaluation report', false),
             (181, 1, 'Use it to find out why an auto-configuration backed off', false),
             (182, 0, 'The only endpoint disabled by default: management.endpoint.shutdown.enabled=true', true),
             (182, 1, 'Must also be exposed: management.endpoints.web.exposure.include=shutdown', false),
             (183, 0, '1. Bean definitions loaded (@Configuration, scanning, XML)', false),
             (183, 1, '2. BeanFactoryPostProcessors modify definitions (e.g. resolve ${…})', false),
             (183, 2, '3. Beans instantiated (singletons eagerly), dependencies injected', false),
             (183, 3,
              '4. BeanPostProcessor before-init → @PostConstruct → afterPropertiesSet() → init-method → BeanPostProcessor after-init (proxies)',
              false),
             (183, 4, '5. On close(): @PreDestroy → destroy() → destroy-method', false),
             (183, 5, 'Init callbacks run on the raw bean, before AOP proxies are applied', true),
             (184, 0, 'Singletons are created eagerly at startup (unless @Lazy)', false),
             (184, 1, 'Spring does not manage the complete lifecycle of a prototype: destroy callbacks are NOT called',
              true),
             (184, 2,
              'A prototype injected into a singleton is created once: use ObjectProvider, @Lookup or a scoped proxy for a new one each time',
              true),
             (184, 3, 'Web scopes: request, session, application', false),
             (185, 0, 'Plain Spring: JDK proxy if the target implements at least one interface, otherwise CGLIB',
              false),
             (185, 1, 'Spring Boot: CGLIB by default (spring.aop.proxy-target-class=true)', false),
             (185, 2, 'Self-invocation (this.otherMethod()) bypasses the proxy: no advice, no transaction', true),
             (185, 3, 'CGLIB cannot advise final methods or classes; JDK proxies only intercept interface methods',
              true),
             (185, 4, 'Inject by interface type when JDK proxies are used: the proxy is not the implementation class',
              true),
             (186, 0,
              'Between aspects: @Order / Ordered; lower value = higher precedence (runs first on the way in, last on the way out)',
              false),
             (186, 1, 'Within one aspect (since 5.2.7): @Around, @Before, @After, @AfterReturning, @AfterThrowing',
              false),
             (186, 2, 'Two advice of the same type in one aspect have undefined order: merge them or split the aspect',
              true),
             (187, 0, 'REQUIRES_NEW suspends the outer transaction and can exhaust the connection pool', true),
             (187, 1, 'NESTED only works with JDBC savepoints (e.g. DataSourceTransactionManager)', true),
             (187, 2, 'Only applies to calls through the proxy: self-invocation ignores it', true),
             (188, 0, 'Only applies with REQUIRED or REQUIRES_NEW (when a new transaction starts)', false),
             (188, 1, 'Higher isolation = fewer anomalies, less concurrency', false),
             (189, 0, 'Default: RuntimeException and Error roll back; checked exceptions COMMIT', true),
             (189, 1,
              'rollbackFor / rollbackForClassName add exceptions; noRollbackFor / noRollbackForClassName exclude them',
              false),
             (189, 2, 'The strongest (most specific) matching rule wins', false),
             (189, 3, 'Catching the exception inside the method means no rollback', true),
             (189, 4, 'In tests, @Transactional test methods roll back by default (@Commit to keep)', false),
             (190, 0, '1. Default properties (SpringApplication.setDefaultProperties)', false),
             (190, 1, '2. @PropertySource on @Configuration classes', false),
             (190, 2, '3. Config data files (application.properties / .yml)', false),
             (190, 3, '4. RandomValuePropertySource (random.*)', false),
             (190, 4, '5. OS environment variables', false),
             (190, 5, '6. Java system properties (-D)', false),
             (190, 6, '7–9. JNDI, ServletContext / ServletConfig init params', false),
             (190, 7, '10. SPRING_APPLICATION_JSON', false),
             (190, 8, '11. Command-line arguments (--key=value)', false),
             (190, 9, '12–14. Tests: properties attribute, @DynamicPropertySource, @TestPropertySource (highest)',
              false),
             (190, 10, '@PropertySource is near the bottom and is too late for logging.* or spring.main.*', true),
             (191, 0, '1. application.properties inside the jar', false),
             (191, 1, '2. application-{profile}.properties inside the jar', false),
             (191, 2, '3. application.properties outside the jar', false),
             (191, 3, '4. application-{profile}.properties outside the jar', false),
             (191, 4, '.properties beats .yml in the same location', true),
             (191, 5, 'With several active profiles, the last one wins', false),
             (192, 0,
              'Listed in META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports (2.7; spring.factories before)',
              false),
             (192, 1,
              'Typical guards: @ConditionalOnClass (library present) + @ConditionalOnMissingBean (you did not define one)',
              false),
             (192, 2, 'Your own bean wins: define a DataSource and DataSourceAutoConfiguration backs off', true),
             (192, 3, 'Auto-configurations are processed after your own configuration', false),
             (192, 4, 'See what happened: --debug or /actuator/conditions', false),
             (193, 0, 'By default @SpringBootTest does NOT start a server', true),
             (194, 0, 'Slices do not scan regular @Component / @Service beans: mock them with @MockBean', true),
             (194, 1, '@DataJpaTest and @JdbcTest are transactional and roll back after each test', false),
             (194, 2,
              '@DataJpaTest replaces the DataSource with an embedded one (override with @AutoConfigureTestDatabase)',
              false),
             (195, 0, '1. HandlerMapping finds the handler (controller method) plus interceptors', false),
             (195, 1, '2. HandlerAdapter invokes it, resolving arguments (@PathVariable, @RequestBody…)', false),
             (195, 2, '3. @ResponseBody / @RestController: return value written by an HttpMessageConverter', false),
             (195, 3, '4. Otherwise a ViewResolver turns the view name into a View, and the model is rendered', false),
             (195, 4, '5. Exceptions go to HandlerExceptionResolvers (@ExceptionHandler, @ResponseStatus)', false),
             (195, 5, 'Boot auto-configures DispatcherServlet mapped to /', false),
             (196, 0, '1. DelegatingFilterProxy → FilterChainProxy → first matching SecurityFilterChain', false),
             (196, 1,
              '2. An authentication filter (form, Basic…) builds an Authentication and calls AuthenticationManager',
              false),
             (196, 2, '3. On success the Authentication is stored in the SecurityContextHolder', false),
             (196, 3, '4. The authorization filter checks URL rules; method security checks @PreAuthorize via AOP',
              false),
             (196, 4,
              '5. ExceptionTranslationFilter: not authenticated → start authentication (401 / login page); authenticated but not allowed → 403',
              false),
             (197, 0, 'All endpoints secured, including Actuator', false),
             (197, 1,
              'One in-memory user "user" with a random password logged at WARN ("Using generated security password")',
              false),
             (197, 2, 'Form login or HTTP Basic depending on the Accept header', false),
             (197, 3, 'Your own SecurityFilterChain bean replaces the web part', false),
             (197, 4,
              'Your own UserDetailsService / AuthenticationProvider / AuthenticationManager bean removes the default user',
              true)) AS v(card_id, position, text, important)
WHERE NOT EXISTS (SELECT 1 FROM card_fact f WHERE f.card_id = v.card_id AND f.position = v.position);

INSERT INTO card_related (card_id, related_card_id, position)
SELECT v.card_id, v.related_card_id, v.position
FROM (VALUES (106, 90, 0),
             (106, 91, 1),
             (106, 107, 2),
             (107, 106, 0),
             (108, 48, 0),
             (108, 109, 1),
             (108, 127, 2),
             (109, 61, 0),
             (109, 24, 1),
             (109, 62, 2),
             (110, 108, 0),
             (110, 53, 1),
             (111, 156, 0),
             (111, 108, 1),
             (112, 148, 0),
             (112, 129, 1),
             (112, 130, 2),
             (113, 39, 0),
             (113, 154, 1),
             (113, 131, 2),
             (114, 26, 0),
             (114, 27, 1),
             (114, 185, 2),
             (115, 197, 0),
             (115, 160, 1),
             (115, 139, 2),
             (116, 115, 0),
             (117, 78, 0),
             (117, 194, 1),
             (117, 81, 2),
             (118, 175, 0),
             (118, 135, 1),
             (118, 99, 2),
             (119, 108, 0),
             (119, 126, 1),
             (120, 13, 0),
             (120, 74, 1),
             (120, 121, 2),
             (121, 120, 0),
             (122, 123, 0),
             (122, 190, 1),
             (123, 191, 0),
             (123, 122, 1),
             (124, 15, 0),
             (124, 3, 1),
             (125, 91, 0),
             (125, 181, 1),
             (125, 126, 2),
             (126, 179, 0),
             (126, 125, 1),
             (127, 85, 0),
             (127, 193, 1),
             (127, 128, 2),
             (128, 127, 0),
             (129, 112, 0),
             (129, 130, 1),
             (130, 36, 0),
             (130, 134, 1),
             (131, 113, 0),
             (131, 39, 1),
             (132, 80, 0),
             (133, 44, 0),
             (134, 130, 0),
             (134, 131, 1),
             (135, 175, 0),
             (135, 136, 1),
             (136, 176, 0),
             (136, 165, 1),
             (137, 135, 0),
             (138, 177, 0),
             (138, 166, 1),
             (139, 197, 0),
             (139, 163, 1),
             (140, 185, 0),
             (140, 114, 1),
             (141, 1, 0),
             (141, 183, 1),
             (142, 143, 0),
             (142, 11, 1),
             (142, 183, 2),
             (143, 142, 0),
             (143, 183, 1),
             (143, 185, 2),
             (144, 17, 0),
             (144, 183, 1),
             (145, 2, 0),
             (146, 11, 0),
             (146, 12, 1),
             (146, 190, 2),
             (147, 90, 0),
             (148, 149, 0),
             (148, 151, 1),
             (148, 150, 2),
             (149, 148, 0),
             (150, 148, 0),
             (151, 6, 0),
             (151, 148, 1),
             (152, 34, 0),
             (152, 35, 1),
             (152, 153, 2),
             (153, 152, 0),
             (153, 34, 1),
             (154, 174, 0),
             (154, 40, 1),
             (154, 41, 2),
             (155, 55, 0),
             (155, 54, 1),
             (155, 48, 2),
             (156, 158, 0),
             (156, 155, 1),
             (157, 79, 0),
             (157, 83, 1),
             (157, 158, 2),
             (158, 193, 0),
             (158, 156, 1),
             (158, 157, 2),
             (159, 160, 0),
             (159, 196, 1),
             (160, 64, 0),
             (160, 173, 1),
             (160, 159, 2),
             (161, 162, 0),
             (162, 163, 0),
             (162, 161, 1),
             (163, 164, 0),
             (163, 139, 1),
             (164, 163, 0),
             (165, 176, 0),
             (165, 136, 1),
             (166, 177, 0),
             (166, 138, 1),
             (167, 178, 0),
             (168, 28, 0),
             (168, 169, 1),
             (168, 33, 2),
             (169, 168, 0),
             (169, 29, 1),
             (170, 11, 0),
             (170, 146, 1),
             (170, 142, 2),
             (171, 67, 0),
             (171, 172, 1),
             (172, 70, 0),
             (172, 171, 1),
             (173, 160, 0),
             (173, 171, 1),
             (174, 154, 0),
             (174, 41, 1),
             (175, 135, 0),
             (175, 118, 1),
             (176, 165, 0),
             (176, 136, 1),
             (177, 166, 0),
             (177, 138, 1),
             (178, 167, 0),
             (179, 126, 0),
             (180, 146, 0),
             (180, 97, 1),
             (180, 49, 2),
             (181, 125, 0),
             (181, 192, 1),
             (182, 175, 0),
             (183, 142, 0),
             (183, 143, 1),
             (183, 17, 2),
             (183, 144, 3),
             (184, 14, 0),
             (184, 15, 1),
             (185, 27, 0),
             (185, 140, 1),
             (185, 34, 2),
             (186, 26, 0),
             (186, 33, 1),
             (187, 34, 0),
             (187, 188, 1),
             (187, 189, 2),
             (188, 187, 0),
             (188, 34, 1),
             (189, 34, 0),
             (189, 77, 1),
             (189, 187, 2),
             (190, 191, 0),
             (190, 12, 1),
             (190, 75, 2),
             (191, 190, 0),
             (191, 123, 1),
             (191, 120, 2),
             (192, 91, 0),
             (192, 93, 1),
             (192, 92, 2),
             (192, 181, 3),
             (193, 78, 0),
             (193, 158, 1),
             (193, 157, 2),
             (194, 79, 0),
             (194, 80, 1),
             (194, 81, 2),
             (194, 193, 3),
             (195, 48, 0),
             (195, 57, 1),
             (195, 155, 2),
             (196, 159, 0),
             (196, 162, 1),
             (196, 161, 2),
             (197, 115, 0),
             (197, 139, 1),
             (197, 160, 2)) AS v(card_id, related_card_id, position)
WHERE NOT EXISTS (SELECT 1 FROM card_related r WHERE r.card_id = v.card_id AND r.position = v.position);

SELECT setval(pg_get_serial_sequence('card_category', 'id'), (SELECT max(id) FROM card_category));
SELECT setval(pg_get_serial_sequence('card_kind', 'id'), (SELECT max(id) FROM card_kind));
SELECT setval(pg_get_serial_sequence('card', 'id'), (SELECT max(id) FROM card));