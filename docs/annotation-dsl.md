# Annotation DSL

Use annotations when inference is incomplete.

## Basic usage

```ruby
class Api::V1::UsersController < ApplicationController
  swagger_doc action: :create do
    summary "Create a user"
    description "Creates a user with the provided attributes"
    tag "Users"
    deprecated false
  end
end
```

## Request overrides

```ruby
swagger_doc action: :create do
  body_param :role, :string, enum: %w[admin user]
  query_param :include, :string, required: false

  request_body type: :object, properties: {
    user: { type: :object }
  }
end
```

## Response overrides

```ruby
swagger_doc action: :create do
  response 201, ref: "User"
  response 422, ref: "ValidationError"
end
```

## Security

```ruby
swagger_doc action: :index do
  security :bearer_auth
end
```

## Exclude endpoints

```ruby
swagger_doc action: :debug do
  exclude true
end
```

Annotations always override inferred values for the same operation.
