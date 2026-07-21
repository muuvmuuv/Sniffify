# Persistence Layer

This folder contains SwiftData models and stores.

## Structure

- `AppSchema.swift` - Schema definition with all models
- `Models/` - SwiftData model definitions
- Add stores here for CRUD operations (e.g., `ItemStore.swift`)

## Guidelines

- Models should be simple data containers
- Use stores (`@MainActor` singletons) for CRUD operations
- Keep models CloudKit-compatible (no unique constraints)
