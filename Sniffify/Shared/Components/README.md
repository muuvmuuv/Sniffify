# Components

Reusable UI components go here.

## Guidelines

- Keep components focused and single-purpose
- Use AppTheme values for colors, spacing, etc.
- Add previews for each component
- Prefer composition over configuration flags

## Example Component

```swift
struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppSpacing.cardPadding)
            .background(AppColors.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
            .cardShadow()
    }
}
```
