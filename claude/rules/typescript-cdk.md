---
paths:
  - "infra/**/*.ts"
  - "**/*-stack.ts"
  - "**/cdk/**/*.ts"
---

# TypeScript AWS CDK Conventions and Best Practices

Follow AWS CDK best practices and TypeScript standards when writing infrastructure code.

These instructions are based on [AWS CDK Best Practices](https://docs.aws.amazon.com/cdk/v2/guide/best-practices.html), [CDK Developer Guide](https://docs.aws.amazon.com/cdk/v2/guide/home.html), and TypeScript community standards.

## General Instructions

-   Prioritize readability, maintainability, and infrastructure reliability
-   Use strong typing and leverage TypeScript's type system for safety
-   Break down complex stacks into smaller, focused stacks with clear responsibilities
-   Keep infrastructure code deterministic and idempotent
-   All deployed resources must be tagged with deployment date, repository source, and git commit hash
-   Infrastructure should follow AWS Well-Architected Framework principles

## Stack Organization

-   Create separate stacks for different lifecycle components (secrets, networking, application)
-   Use stack dependencies (`addDependency()`) to establish clear deployment order
-   Pass resources between stacks using properties, not CloudFormation exports (when possible)
-   Keep stacks focused on a single logical unit or service
-   Name stacks descriptively using pattern: `<Service><Purpose>Stack`
-   Only create resources in stack classes in `lib/`, never in `bin/` entry points
-   Export resources that other stacks need as public readonly properties

## TypeScript Conventions

### Type Safety

-   Always define typed props interfaces extending `cdk.StackProps`
-   Use `readonly` for all public stack properties
-   Define interfaces for configuration objects
-   Use `as const` for string constant objects
-   Never use `any` type

### Method Organization

1.  Public readonly properties
2.  Constructor
3.  Private helper methods:
    -   Tag application
    -   Configuration loading
    -   Resource creation
    -   Integration setup
    -   Output generation

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

-   Export related string constants as const objects
-   Use descriptive constant names that indicate purpose

## Configuration Management

-   Use CDK context for environment-specific configuration
-   Access context with defaults: `this.node.tryGetContext("key") || defaultValue`
-   Encapsulate configuration loading in private helper methods
-   Use CloudFormation parameters for deployment-time values
-   Type all configuration objects with interfaces

## Secrets and Parameters

### Secrets Manager

-   Store all sensitive data (API tokens, passwords, keys) in Secrets Manager
-   Always use `RETAIN` removal policy for secrets
-   Grant runtime access using `.grantRead()` methods
-   Pass secret IDs to Lambda as environment variables, not values
-   Use `noEcho: true` for sensitive CloudFormation parameters

### SSM Parameter Store

-   Store non-sensitive configuration in SSM Parameter Store
-   Apply `RETAIN` removal policy to preserve parameters

### Never Store Secrets In

-   Source code
-   CloudFormation outputs
-   SSM StringParameter
-   Lambda environment variables directly

## IAM Permissions

-   Always use `.grant*()` methods for least-privilege permissions
-   Avoid the use wildcard (`*`) permissions, unless it is justified
-   Grant only the minimum required actions and resources
-   Prefer `.grantRead()`, `.grantWrite()`, `.grantReadWriteData()` over manual policies

## Cross-Stack References

-   Prefer passing resources via props over CloudFormation exports
-   Use CloudFormation exports only for shared infrastructure
-   Import existing resources using `.from*()` methods with explicit attributes
-   Always establish dependencies using `addDependency()` when referencing other stacks

## Removal Policies

-   Use `RETAIN` for production data, secrets, and configuration
-   Use `DESTROY` only for development/test resources
-   Stateless resources (Lambda, IAM roles) use default `DESTROY`
-   Always explicitly set removal policy for stateful resources

## Tagging

-   Tag all stacks with:
    -   `ManagedBy: "cdk"`
    -   `Service: "<service-name>"`
    -   `Repository: "<org>/<repo>"`
    -   `GitSha: "<commit-hash>"`
    -   `DeployedAt: "<ISO-timestamp>"`
-   Apply tags in constructor before creating resources

## CloudFormation Outputs

-   Output user-facing URLs and identifiers
-   Include descriptive labels and descriptions
-   Only use `exportName` when value is needed by other stacks
-   Never change output names (breaks references)
-   Never output sensitive values

## Patterns to Follow

-   Break down complex constructors using private helper methods
-   Use Node's `path.join()` for cross-platform path resolution
-   Handle git command failures gracefully (return undefined)
-   Use specific Lambda function constructs when available
-   Prefer typed CDK properties over `Fn.getAtt()`
-   Write unit tests using CDK assertions library
-   Run `cdk synth` and `cdk diff` before every deployment

## Patterns to Avoid

-   Don't hardcode account IDs or regions (use `cdk.Aws.ACCOUNT_ID`, `cdk.Aws.REGION`)
-   Don't use escape hatches (`addOverride`, `addPropertyOverride`) unless absolutely necessary
-   Don't create circular dependencies between stacks
-   Don't use mutable state in constructs
-   Don't mix application code with infrastructure code
-   Don't change logical IDs of stateful resources
-   Don't use `Fn.getAtt()` when typed properties exist

## Documentation

-   Document all public stack properties with JSDoc
-   Explain non-obvious configuration decisions
-   Document stack dependencies and why they exist
-   Include AWS documentation references for complex resources
-   Document why specific patterns are used (e.g., removal policies)

## Testing

-   Write snapshot tests for all stacks using `Template.fromStack()`
-   Use `Template.resourceCountIs()` to verify resource counts
-   Use `Template.hasResourceProperties()` with `Match` for fine-grained assertions
-   Test that sensitive parameters use `noEcho: true`
-   Verify IAM policies follow least privilege
