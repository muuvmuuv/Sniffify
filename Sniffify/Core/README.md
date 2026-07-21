# Core Layer

This folder contains domain logic, services, and persistence.

## Structure

- `Persistence/` - SwiftData models and stores
- `Logger.swift` - OSLog wrapper

## Adding New Services

Create subfolders for each service area:
- `Auth/` - Authentication services
- `Network/` - API clients
- `Player/` - Media playback (if needed)

## Threading Guidelines

- Use `actor` for background services
- Use `@MainActor` for UI-related singletons and stores
- Always configure services in the main App's `.task` modifier
