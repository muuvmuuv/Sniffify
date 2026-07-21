# SwiftData Models

Place your SwiftData model definitions here.

## Example Model

```swift
import SwiftData

@Model
final class Item {
    var id: UUID
    var name: String
    var createdAt: Date

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
    }
}
```

## Guidelines

- Use `@Model` macro for SwiftData models
- Include `id` property for unique identification
- Keep models as simple data containers
- Avoid unique constraints for CloudKit compatibility
- Register models in `AppSchema.swift`
