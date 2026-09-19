---
name: annotate-django-models
description: >-
  Add schema annotations to Django models: a class docstring with a Schema
  block, field help_text, and index/FK notes. Use when creating or editing
  Django models, adding data models, documenting schema, or when the user
  asks to annotate, comment, or document models.
---

# Annotate Django models

Do **not** install `django-annotate` or any schema-comment generator. Write comments by hand to match existing Sona models.

Canonical examples: `backend/accounts/models.py`, `backend/chat/models.py`.

## When

- New `models.Model` / `AbstractUser` subclass
- New or renamed fields, FKs, indexes, or `Meta.ordering`
- User asks to annotate, comment, or document data models

## What to add

1. **Class docstring** — one-line purpose, then a `Schema:` block, then behavior that is not obvious from field names (defaults, cascade, indexes, reserved values).
2. **`help_text`** on fields that need intent (FKs, unique business keys, UI-facing names). Skip trivial `created_at` / `updated_at` unless they have special meaning.
3. **Manager docstring** if the manager has non-obvious rules (e.g. `password=None` → unusable password).

`help_text` is not a database change; do not create a migration for comments only.

## Schema block

Align columns. Use DB names for FKs (`user_id`, not `user`). Note PK, unique, null, cascade, and choices.

```python
class Example(models.Model):
    """One-line purpose.

    Schema:
        id           UUID PK
        owner_id     FK → User, cascade delete
        name         unique per owner
        created_at   set on insert

    Indexed on (owner, -created_at).
    """

    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="examples",
        help_text="Owner. Deleting the user removes these rows.",
    )
    name = models.CharField(
        max_length=200,
        help_text="Shown in the UI. Unique together with owner.",
    )
```

## Rules

- Explain **why / how it behaves**, not “email is the email”.
- Keep comments in sync when fields change; do not leave a stale Schema block.
- Do not duplicate the entire `AbstractUser` column list; name inherited fields that matter (password, staff, permissions) in one line.
- Do not emit `# == Schema Information` Rails-style comment fences.
