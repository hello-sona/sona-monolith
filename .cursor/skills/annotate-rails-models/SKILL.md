---
name: annotate-rails-models
description: >-
  Add schema annotations to Rails models: a leading class comment with a Schema
  block, plus notes on indexes, cascades, and reserved values. Use when creating
  or editing Active Record models, adding data models, documenting schema, or
  when the user asks to annotate, comment, or document models.
---

# Annotate Rails models

Do **not** install `annotate`, `annotaterb`, or any schema-comment generator. Write comments by hand to match the existing Sona models.

Canonical examples: `backend/app/models/user.rb`, `backend/app/models/conversation.rb`, `backend/app/models/message.rb`.

## When

- New `ApplicationRecord` subclass
- New or renamed columns, associations, indexes, or default scopes
- User asks to annotate, comment, or document data models

## What to add

1. **Leading class comment** — one line of purpose, then a `Schema:` block, then behavior that is not obvious from column names (defaults, cascade, indexes, reserved values).
2. **Inline comments** on validations, callbacks, or scopes whose intent is not self-evident (for example why a password may be absent).
3. Nothing for trivial `created_at` / `updated_at` unless they carry special meaning.

Comments are not a database change; do not create a migration for them.

## Schema block

Align columns. Use database names for foreign keys (`user_id`, not `user`). Note PK type, unique, null, cascade, and enum values.

```ruby
# One-line purpose.
#
# Schema:
#   id          bigint PK
#   owner_id    FK -> users, cascade delete
#   name        unique per owner
#   created_at  set on insert
#
# Indexed on (owner_id, created_at desc).
class Example < ApplicationRecord
  belongs_to :owner, class_name: "User"

  validates :name, presence: true, uniqueness: { scope: :owner_id }

  # Newest first for the sidebar; avoids a default_scope.
  scope :recent_first, -> { order(created_at: :desc) }
end
```

## Rules

- Explain **why / how it behaves**, not "email is the email".
- Keep comments in sync when columns change; do not leave a stale Schema block.
- Record the cascade behavior on both sides: `dependent:` in the model and `on_delete:` in the migration.
- Do not emit `# == Schema Information` comment fences.
