# Modification Design: UI Building Blocks & Dependencies

## Overview
This modification aims to establish a consistent Design System for the Gsports application by implementing core UI building blocks and updating necessary dependencies. This aligns with the "Functional Minimalism" design philosophy outlined in the UI/UX documentation.

## Goal
To replace basic, inconsistent UI elements with a standardized set of custom widgets (`buttons`, `text fields`, `colors`) and ensure the project has the required libraries for future features (`typography`, `svg`, `auth`).

## Analysis of the Goal
The current UI implementation is "basic" and lacks a unified visual identity. By creating reusable components now, we ensure consistency across all future screens and reduce code duplication.
- **Dependencies:** We need `google_fonts` for typography, `flutter_svg` for icons, `carousel_slider` for venue display, and `google_sign_in` for upcoming auth features. `intl` is needed for currency formatting.
- **Design System:** We need to define the color palette and core widgets (Buttons, TextFields) strictly following the Material 3 "Functional Minimalism" style (Black/White/Electric Blue).

## Alternatives Considered
- **Using a UI Library (e.g., GetWidget):** Rejected. The design requirement is very specific ("Stitch" inspired, minimalist), and using a heavy library might introduce unnecessary bloat or style conflicts. Custom widgets give us full control.
- **Modifying existing pages directly:** Rejected. It's better to build the components in isolation (`lib/core/presentation/widgets/`) first, then refactor existing pages to use them in subsequent steps. This minimizes breakage.

## Detailed Design

### 1. Dependencies Update (`pubspec.yaml`)
We will add/update the following packages:
- `google_fonts: ^6.3.3`
- `flutter_svg: ^2.2.3`
- `carousel_slider: ^5.1.1`
- `google_sign_in: ^7.2.0`
- `intl: ^0.20.2`

### 2. Color Palette (`lib/core/constants/app_colors.dart`)
We will create a centralized color constant file.

```dart
import 'dart:ui';

class AppColors {
  static const Color primary = Color(0xFF212121); // Jet Black
  static const Color accent = Color(0xFF2962FF);  // Electric Blue
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color border = Color(0xFFE0E0E0);  // Grey-300
  // Semantic colors will also be included as per UI/UX doc
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFC107);
}
```

### 3. Custom Buttons (`lib/core/presentation/widgets/custom_button.dart`)
We will create `PrimaryButton` and `SecondaryButton` widgets.

**PrimaryButton:**
- **Type:** `FilledButton` (or `ElevatedButton` with 0 elevation).
- **Style:**
    - Background: `AppColors.primary`
    - Text: `Colors.white`
    - Height: 48-50px
    - BorderRadius: 12px

**SecondaryButton:**
- **Type:** `OutlinedButton`
- **Style:**
    - Background: `Colors.white`
    - Border: `AppColors.primary` (width 1.5)
    - Text: `AppColors.primary`
    - Height: 48-50px
    - BorderRadius: 12px

### 4. Custom Text Field (`lib/core/presentation/widgets/custom_text_field.dart`)
We will create a `CustomTextField` widget.

- **Type:** Wrapper around `TextFormField`.
- **Properties:** `controller`, `label`, `hint`, `isPassword`, `validator`, `keyboardType`, etc.
- **Style:**
    - `filled`: true, `fillColor`: `Colors.transparent` (or white).
    - `enabledBorder`: `OutlineInputBorder(borderSide: BorderSide(color: AppColors.border))`
    - `focusedBorder`: `OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary))`
    - `errorBorder`: `OutlineInputBorder(borderSide: BorderSide(color: AppColors.error))`
- **Feature:**
    - `isPassword` toggle: Uses a local state to switch `obscureText` and the suffix icon (Eye/EyeOff).

## Summary
This modification lays the visual foundation of the app. By isolating these changes, we ensure a clean separation of concerns and prepare the codebase for a UI overhaul in the next steps without breaking existing functionality immediately.

## References
- [pub.dev/packages/google_fonts](https://pub.dev/packages/google_fonts)
- [pub.dev/packages/flutter_svg](https://pub.dev/packages/flutter_svg)
- [Material Design 3 Specs](https://m3.material.io/)