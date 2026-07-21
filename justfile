# Sniffify iOS App - Development Commands

# Default recipe: list available commands
default:
    @just --list

# One-time after a fresh clone: strip DEVELOPMENT_TEAM from commits (see CLAUDE.md "Signing")
setup:
    git config filter.stripteam.clean "sed '/DEVELOPMENT_TEAM/d'"

# Format all Swift files
format:
    swift format --in-place --recursive Sniffify/

# Lint Swift files (check without modifying)
lint:
    swift format --lint --recursive Sniffify/

# Build for simulator (debug)
build:
    xcodebuild build -scheme Sniffify -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' | xcbeautify || xcodebuild build -scheme Sniffify -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Build for release
build-release:
    xcodebuild build -scheme Sniffify -configuration Release

# Clean build artifacts
clean:
    xcodebuild clean -scheme Sniffify

# Open project in Xcode
open:
    open Sniffify.xcodeproj

# Build SPM package for VS Code LSP support
lsp:
    swift build --sdk $(xcrun --sdk iphonesimulator --show-sdk-path) --triple arm64-apple-ios26.0-simulator

# Format and build
check: format build

# Show available simulators
simulators:
    xcrun simctl list devices available | grep -E "iPhone|iPad"
