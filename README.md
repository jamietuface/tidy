# Tidy

An iOS app built with Flutter, designed to Apple Human Interface Guidelines.

**Target:** iPhone 15 · iOS 17+  
**Stack:** Flutter · Riverpod · go_router

## Setup

### Prerequisites
Run these once in your terminal:

```bash
# 1. Accept Xcode license
sudo xcodebuild -license accept

# 2. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Install Flutter
brew install --cask flutter

# 4. Install GitHub CLI
brew install gh

# 5. Configure Xcode command line tools
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# 6. Install CocoaPods
sudo gem install cocoapods
```

### First run
```bash
cd ~/Desktop/Tidy
flutter pub get
cd ios && pod install && cd ..
flutter run -d "iPhone 15"
```

### GitHub
```bash
gh auth login
gh repo create tidy --public --source=. --remote=origin --push
# GitHub profile: github.com/jamietuface
```

## Design System

Uses Apple system colors and typography via `AppColors` and `AppTheme`.
See `lib/theme/app_theme.dart` for the full token set.

## Documentation

All changes are documented in Notion. See CLAUDE.md for project conventions.
