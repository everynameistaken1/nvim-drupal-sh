local T = {}

T.ContainerFactoryPluginInterface = {
  " implements ContainerFactoryPluginInterface",
}

T.UseContainerFactoryPluginInterface = {
  "use Drupal\\Core\\Plugin\\ContainerFactoryPluginInterface;",
}

T.UseContainerInterface = {
  "use Symfony\\Component\\DependencyInjection\\ContainerInterface;",
}

T.BlockStaticCreate = {
  "",
  "/**",
  "* {@inheritdoc}",
  "*/",
  "public static function create(ContainerInterface $container, array $configuration, $plugin_id, $plugin_definition): self {",
  "return new static(",
  "$configuration,",
  "$plugin_id,",
  "$plugin_definition,",
  ");",
  "}",
}

T.ControllerOrFormStaticCreate = {
  "",
  "/**",
  "* {@inheritdoc}",
  "*/",
  "public static function create(ContainerInterface $container): self {",
  "return new static(",
  ");",
  "}",
  "",
}

T.BlockConstructor = {
  "/**",
  "* {@inheritdoc}",
  "*/",
  "public function __construct(",
  "array $configuration,",
  "$plugin_id,",
  "$plugin_definition,",
  ") {",
  "parent::__construct($configuration, $plugin_id, $plugin_definition);",
  "}",
}

T.ServiceAndFormConstructor = {
  "/**",
  "* {@inheritdoc}",
  "*/",
  "public function __construct(",
  ") {}"
}

return T
