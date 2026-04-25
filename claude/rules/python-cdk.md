---
paths:
  - "infra/**/*.py"
  - "**/*_stack.py"
  - "**/cdk/**/*.py"
  - "**/stacks/**/*.py"
---

# Python AWS CDK Conventions and Best Practices

Follow AWS CDK best practices and Python standards when writing infrastructure code.

These instructions are based on [AWS CDK Best Practices](https://docs.aws.amazon.com/cdk/v2/guide/best-practices.html), [CDK Developer Guide](https://docs.aws.amazon.com/cdk/v2/guide/home.html), and Python community standards.

## General Instructions

-   Prioritize readability, maintainability, and infrastructure reliability
-   Use strong typing with type hints for all function parameters and return values
-   Break down complex stacks into smaller, focused stacks with clear responsibilities
-   Keep infrastructure code deterministic and idempotent
-   All deployed resources must be tagged with deployment date, repository source, and git commit hash
-   Infrastructure should follow AWS Well-Architected Framework principles

## Stack Organization

-   Create separate stacks for different lifecycle components (secrets, networking, application)
-   Use stack dependencies (`add_dependency()`) to establish clear deployment order
-   Pass resources between stacks using properties, not CloudFormation exports (when possible)
-   Keep stacks focused on a single logical unit or service
-   Name stacks descriptively using pattern: `<Service><Purpose>Stack`
-   Only create resources in stack classes, never in `app.py` entry points
-   Expose resources that other stacks need as public readonly properties

## Python Conventions

### Type Safety

-   Always use type hints for all functions, methods, and class properties
-   Define typed props dataclasses with `@dataclass` decorator
-   Use `from __future__ import annotations` for forward references
-   Import types: `from aws_cdk import Stack, aws_lambda as lambda_`
-   Never use `Any` type unless absolutely necessary

### Code Organization

1.  Imports (grouped: standard library, third-party, aws_cdk, local)
2.  Constants and configuration
3.  Dataclass definitions for props
4.  Stack class definition:
    -   `__init__` method
    -   Private helper methods (prefixed with `_`):
        -   `_tag_resources()`
        -   `_load_config()`
        -   `_create_resources()`
        -   `_setup_integrations()`
        -   `_create_outputs()`

### Naming Conventions

-   Use `snake_case` for variables, functions, and methods
-   Use `PascalCase` for class names and construct IDs
-   Use `UPPER_SNAKE_CASE` for constants
-   Private methods: prefix with single underscore `_`
-   Module-level "private" variables: prefix with single underscore `_`

## Resource Naming

### Construct IDs (Logical IDs)

-   Use PascalCase for construct IDs
-   Be descriptive and specific
-   Include service name to avoid conflicts
-   Never change logical IDs of stateful resources (causes resource replacement)

### Resource Names

-   Use lowercase with hyphens for actual resource names
-   Include environment/stage/location when managing multiple environments
-   Keep names consistent across related resources

### Constants

-   Define constants at module level in UPPER_SNAKE_CASE
-   Group related constants in dataclasses or enums when appropriate
-   Use `Final` type hint for constants: `from typing import Final`

## Configuration Management

-   Use CDK context for environment-specific configuration
-   Access context with defaults: `self.node.try_get_context("key") or default_value`
-   Encapsulate configuration loading in private helper methods
-   Use CloudFormation parameters for deployment-time values
-   Type all configuration with dataclasses or TypedDict

## Secrets and Parameters

### Secrets Manager

-   Store all sensitive data (API tokens, passwords, keys) in Secrets Manager
-   Always use `RemovalPolicy.RETAIN` for secrets
-   Grant runtime access using `.grant_read()` methods
-   Pass secret ARNs to Lambda as environment variables, not values
-   Use `no_echo=True` for sensitive CloudFormation parameters

### SSM Parameter Store

-   Store non-sensitive configuration in SSM Parameter Store
-   Apply `RemovalPolicy.RETAIN` to preserve parameters

### Never Store Secrets In

-   Source code
-   CloudFormation outputs
-   SSM StringParameter
-   Lambda environment variables directly

## IAM Permissions

-   Always use `.grant_*()` methods for least-privilege permissions
-   Avoid wildcard (`*`) permissions unless justified
-   Grant only the minimum required actions and resources
-   Prefer `.grant_read()`, `.grant_write()`, `.grant_read_write_data()` over manual policies

## Cross-Stack References

-   Prefer passing resources via constructor props over CloudFormation exports
-   Use CloudFormation exports only for shared infrastructure
-   Import existing resources using `.from_*()` methods with explicit attributes
-   Always establish dependencies using `add_dependency()` when referencing other stacks

## Removal Policies

-   Use `RemovalPolicy.RETAIN` for production data, secrets, and configuration
-   Use `RemovalPolicy.DESTROY` only for development/test resources
-   Stateless resources (Lambda, IAM roles) use default `DESTROY`
-   Always explicitly set removal policy for stateful resources

## Tagging

-   Tag all stacks with:
    -   `ManagedBy: "cdk"`
    -   `Service: "<service-name>"`
    -   `Repository: "<org>/<repo>"`
    -   `GitSha: "<commit-hash>"`
    -   `DeployedAt: "<ISO-timestamp>"`
-   Apply tags in constructor using `Tags.of(self).add()` before creating resources

## CloudFormation Outputs

-   Output user-facing URLs and identifiers using `CfnOutput`
-   Include descriptive labels and descriptions
-   Only use `export_name` when value is needed by other stacks
-   Never change output names (breaks references)
-   Never output sensitive values

## Python-Specific Patterns

### Props Dataclasses

```python
from dataclasses import dataclass
from aws_cdk import Stack, StackProps

@dataclass
class MyStackProps(StackProps):
    """Props for MyStack."""
    vpc_id: str
    database_name: str
    api_key_secret_arn: str
    retention_days: int = 30  # Default value
```

### Stack Implementation

```python
from __future__ import annotations
from typing import Final
from aws_cdk import (
    Stack,
    aws_lambda as lambda_,
    aws_dynamodb as dynamodb,
    RemovalPolicy,
    Duration,
    Tags,
)
from constructs import Construct

# Constants
DEFAULT_TIMEOUT: Final = Duration.seconds(30)
DEFAULT_MEMORY: Final = 512

class MyStack(Stack):
    """Stack for my service."""

    def __init__(
        self,
        scope: Construct,
        id: str,
        props: MyStackProps,
        **kwargs,
    ) -> None:
        """Initialize MyStack.

        Args:
            scope: CDK scope
            id: Stack ID
            props: Stack properties
            **kwargs: Additional stack properties
        """
        super().__init__(scope, id, **kwargs)

        # Apply tags early
        self._tag_resources()

        # Create resources
        self._table = self._create_table(props)
        self._function = self._create_function(props)

        # Create outputs
        self._create_outputs()

    def _tag_resources(self) -> None:
        """Apply tags to all resources in this stack."""
        Tags.of(self).add("ManagedBy", "cdk")
        Tags.of(self).add("Service", "my-service")

    def _create_table(self, props: MyStackProps) -> dynamodb.Table:
        """Create DynamoDB table."""
        return dynamodb.Table(
            self,
            "MyTable",
            partition_key=dynamodb.Attribute(
                name="id",
                type=dynamodb.AttributeType.STRING,
            ),
            billing_mode=dynamodb.BillingMode.PAY_PER_REQUEST,
            removal_policy=RemovalPolicy.RETAIN,
        )

    def _create_function(self, props: MyStackProps) -> lambda_.Function:
        """Create Lambda function."""
        fn = lambda_.Function(
            self,
            "MyFunction",
            runtime=lambda_.Runtime.PYTHON_3_12,
            handler="index.handler",
            code=lambda_.Code.from_asset("lambda"),
            timeout=DEFAULT_TIMEOUT,
            memory_size=DEFAULT_MEMORY,
            environment={
                "TABLE_NAME": self._table.table_name,
                "SECRET_ARN": props.api_key_secret_arn,
            },
        )

        # Grant permissions
        self._table.grant_read_write_data(fn)

        return fn

    def _create_outputs(self) -> None:
        """Create CloudFormation outputs."""
        CfnOutput(
            self,
            "FunctionArn",
            value=self._function.function_arn,
            description="Lambda function ARN",
        )

    @property
    def function(self) -> lambda_.Function:
        """Public readonly property for function."""
        return self._function
```

### Context Managers

-   Use context managers for resources that need cleanup
-   Useful for custom constructs that manage lifecycle

### Error Handling

-   Validate props in `__init__` before creating resources
-   Raise `ValueError` for invalid configuration
-   Use type hints to catch errors at development time

## Patterns to Follow

-   Break down complex constructors using private helper methods
-   Use `pathlib.Path` for cross-platform path resolution
-   Handle git command failures gracefully (return None)
-   Use specific Lambda function constructs when available
-   Prefer typed CDK properties over `Fn.get_att()`
-   Write unit tests using CDK assertions library
-   Run `cdk synth` and `cdk diff` before every deployment

## Patterns to Avoid

-   Don't hardcode account IDs or regions (use `self.account`, `self.region`)
-   Don't use escape hatches (`add_override`, `add_property_override`) unless absolutely necessary
-   Don't create circular dependencies between stacks
-   Don't use mutable state in constructs
-   Don't mix application code with infrastructure code
-   Don't change logical IDs of stateful resources
-   Don't use `Fn.get_att()` when typed properties exist
-   Don't use bare `except:` clauses

## Documentation

-   Document all classes, methods, and functions with docstrings
-   Use Google-style docstrings for consistency
-   Explain non-obvious configuration decisions
-   Document stack dependencies and why they exist
-   Include AWS documentation references for complex resources
-   Document why specific patterns are used (e.g., removal policies)

### Docstring Format

```python
def create_bucket(
    self,
    bucket_name: str,
    retention_days: int = 30,
) -> s3.Bucket:
    """
    Create an S3 bucket with lifecycle policies.

    Args:
        bucket_name:
            The name of the S3 bucket.

        retention_days:
            Number of days to retain objects before deletion.

    Returns:
        The created S3 bucket construct.
    """
```

## Testing

-   Write snapshot tests for all stacks using `Template.from_stack()`
-   Use `Template.resource_count_is()` to verify resource counts
-   Use `Template.has_resource_properties()` with `Match` for fine-grained assertions
-   Test that sensitive parameters use `no_echo=True`
-   Verify IAM policies follow least privilege
-   Use `pytest` as the testing framework
-   Use fixtures for common test setup

### Test Example

```python
import aws_cdk as cdk
from aws_cdk.assertions import Template, Match

def test_stack_creates_lambda():
    """Test that stack creates Lambda function."""
    app = cdk.App()
    stack = MyStack(
        app,
        "TestStack",
        props=MyStackProps(
            vpc_id="vpc-123",
            database_name="test-db",
            api_key_secret_arn="arn:aws:secretsmanager:us-east-1:123456789012:secret:test",
        ),
    )

    template = Template.from_stack(stack)

    template.resource_count_is("AWS::Lambda::Function", 1)
    template.has_resource_properties(
        "AWS::Lambda::Function",
        {
            "Runtime": "python3.12",
            "MemorySize": 512,
        },
    )
```

## Lambda Functions

### Python Lambda Best Practices

-   Use specific runtime versions: `lambda_.Runtime.PYTHON_3_12`
-   Set appropriate timeout (default is 3 seconds, often too short)
-   Set appropriate memory size (minimum 128 MB, consider performance needs)
-   Use `lambda_.Code.from_asset()` for local code
-   Use layers for shared dependencies
-   Use environment variables for configuration, not secrets
-   Grant permissions using `.grant_*()` methods

### Lambda Layers

```python
layer = lambda_.LayerVersion(
    self,
    "DependenciesLayer",
    code=lambda_.Code.from_asset("lambda/layers/dependencies"),
    compatible_runtimes=[lambda_.Runtime.PYTHON_3_12],
    description="Common dependencies for Lambda functions",
)

fn = lambda_.Function(
    self,
    "MyFunction",
    runtime=lambda_.Runtime.PYTHON_3_12,
    handler="index.handler",
    code=lambda_.Code.from_asset("lambda"),
    layers=[layer],
)
```

## Common Anti-Patterns

### Bad Patterns

```python
# ❌ Don't hardcode account/region
bucket_arn = "arn:aws:s3:::my-bucket-123456789012"

# ❌ Don't use bare except
try:
    result = some_operation()
except:
    pass

# ❌ Don't create resources in app.py
app = cdk.App()
bucket = s3.Bucket(app, "MyBucket")  # Wrong!

# ❌ Don't use mutable default arguments
def __init__(self, tags: dict = {}):
    pass

# ❌ Don't mix application and infrastructure code
def __init__(self, scope, id, **kwargs):
    super().__init__(scope, id, **kwargs)
    # Don't call external APIs here
    response = requests.get("https://api.example.com")
```

### Good Patterns

```python
# ✅ Use CDK properties
bucket_arn = bucket.bucket_arn

# ✅ Use specific exceptions
try:
    result = some_operation()
except ValueError as e:
    logger.error("Invalid value: %s", e)

# ✅ Create resources in stacks
app = cdk.App()
stack = MyStack(app, "MyStack")

# ✅ Use immutable defaults
def __init__(self, tags: dict | None = None):
    self.tags = tags or {}

# ✅ Keep infrastructure separate
def __init__(self, scope, id, api_url: str, **kwargs):
    super().__init__(scope, id, **kwargs)
    # Pass API URL as config, don't fetch it here
    self._api_url = api_url
```

## Code Style

-   Use `ruff` for linting and formatting
-   Follow PEP 8 style guidelines
-   Maximum line length: 88 characters (Black default)
-   Use f-strings for string formatting
-   Use list/dict comprehensions when they improve readability
-   Use context managers (`with` statements) for resource management

## Type Hints

-   Use `from __future__ import annotations` for forward references
-   Use `|` for union types (Python 3.10+): `str | None`
-   Use `list[str]` instead of `List[str]` (Python 3.9+)
-   Use `dict[str, int]` instead of `Dict[str, int]` (Python 3.9+)
-   Use `Final` for constants
-   Use `Protocol` for structural subtyping when needed

## App Entry Point

```python
#!/usr/bin/env python3
"""CDK app entry point."""
from __future__ import annotations

import aws_cdk as cdk
from stacks.my_stack import MyStack, MyStackProps

app = cdk.App()

# Get configuration from context
env = cdk.Environment(
    account=app.node.try_get_context("account"),
    region=app.node.try_get_context("region"),
)

# Create stacks
my_stack = MyStack(
    app,
    "MyStack",
    props=MyStackProps(
        vpc_id="vpc-123",
        database_name="my-db",
        api_key_secret_arn="arn:aws:secretsmanager:...",
    ),
    env=env,
)

app.synth()
```
