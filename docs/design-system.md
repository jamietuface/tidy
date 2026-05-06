# Tidy — Design System

## Brand Identity
**Tagline**: "Your phone. Tidied."
**Voice**: Clean, direct, satisfying. Never patronising. Celebrate the win.
**Personality**: The app equivalent of a clear desk — calm, confident, efficient.

## Visual Language

### Apple HIG First
Tidy follows Apple Human Interface Guidelines as the foundation. Every component uses native iOS patterns so users feel instantly at home.

### Color Palette
All colors map to iOS system colors — they adapt automatically to dark mode.

```
Primary action:    systemBlue    #007AFF
Success / keep:    systemGreen   #34C759  
Delete / danger:   systemRed     #FF3B30
AI / smart:        systemIndigo  #5856D6
Warning:           systemOrange  #FF9500
Money / savings:   systemGreen   #34C759
Background:        systemGray6   #F2F2F7
Card surface:      white         #FFFFFF
```

### Typography
SF Pro Display — Apple's native typeface. Never load a custom font.

```
Hero titles:    34pt  Bold     (-0.5 tracking)
Section titles: 22pt  Semibold (-0.2 tracking)
Body:           17pt  Regular
Labels:         15pt  Medium
Captions:       13pt  Regular
Tags/chips:     11pt  Medium   (+0.5 tracking, ALL CAPS)
```

### Spacing (8pt grid)
```
xs:   4pt
sm:   8pt
md:   16pt
lg:   24pt
xl:   32pt
xxl:  48pt
```

### Radius
```
Cards:          12pt
Buttons:        14pt
Icon containers: 16–28pt (scale with icon size)
Sheet handles:  3pt
```

### Elevation
Tidy is flat-first. No shadows on cards — use background color contrast instead. Modals use system sheet presentation.

## Core Interaction — The Swipe

This is Tidy's signature. Get it right.

- **Right swipe** (keep): green overlay, checkmark icon, haptic: `.medium`
- **Left swipe** (delete): red overlay, trash icon, haptic: `.rigid`
- **Threshold**: 40pt drag before color appears, 120pt to commit
- **Snap animation**: spring(dampingFraction: 0.7, blendDuration: 0.1)
- **Card stack**: 3 cards visible, scale 0.95 / 0.90 behind active card

## Iconography
Use SF Symbols exclusively. Match weight to text weight in context.

```
Photos tab:     photo.on.rectangle
Delete:         trash
Keep:           checkmark.circle.fill  
AI/Smart:       sparkles
App tracker:    app.badge
Subscription:   creditcard
Settings:       gearshape
```

## Paywall Design Rules
1. Dark background (pure black) — premium feel
2. Annual plan always shown first and highlighted
3. One primary CTA button (blue, full-width)
4. Social proof line: "Join X,XXX people saving storage"
5. Never use the word "cheap" — use "save" or "best value"

## Onboarding Rules
- Max 3 screens
- Each screen = one idea
- CTA button copies: "Continue" → "Continue" → "Get Started"
- No email gate on onboarding — paywall comes after first value moment

## Accessibility
- All interactive elements: min 44×44pt tap target
- Dynamic Type: support up to xxxLarge
- Reduce Motion: disable swipe physics, use fade transitions
- VoiceOver labels on all custom controls
