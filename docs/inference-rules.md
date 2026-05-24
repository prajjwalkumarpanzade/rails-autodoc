# Inference Rules

`rails-autodoc` builds OpenAPI operations from Rails conventions.

## Routes

Source: `Rails.application.routes`

Extracted data:

- HTTP verb
- Path template (`/users/:id` -> `/users/{id}`)
- Controller and action
- Path parameters
- Tags from controller namespace

## Strong params

Source: controller AST via `parser`

Supported patterns:

```ruby
params.require(:user).permit(:name, :email)
params.require(:user).permit(:name, address: [:street, :city])
params.require(:user).permit(tags: [])
```

Action mapping:

- Looks for `*_params` method calls inside the action
- Falls back to the first `*_params` method in the controller

## Database schema

Source: `db/schema.rb`

- Maps model attributes to OpenAPI types
- Applies types to request fields when names match model columns
- Generates `components.schemas` entries for ActiveRecord models

## Query params

Source: AST scan of action body

Detects:

- `params[:page]`
- `params.fetch(:filter)`

Defaults to optional string parameters.

## Responses

Source: AST scan of `render` and `head` calls

Examples:

- `render json: @user` -> model-based schema reference
- `render json: user, status: :created` -> HTTP 201
- `head :no_content` -> HTTP 204

Default status by verb when no render call is found:

| Verb | Status |
|------|--------|
| GET | 200 |
| POST | 201 |
| PUT/PATCH | 200 |
| DELETE | 204 |

## Serializers

If Alba, Blueprinter, or ActiveModel::Serializer is present, response schemas use serializer field definitions.
