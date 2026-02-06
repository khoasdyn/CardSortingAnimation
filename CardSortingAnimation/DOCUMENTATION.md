# CardSortingAnimation

## Overview

CardSortingAnimation is a single-screen SwiftUI app that visualizes student test scores as a ranked list of colored cards. The app displays 5 students, each assigned a unique color, with scores across 10 different tests. A slider at the bottom lets the user switch between tests, and the cards re-sort themselves in descending order based on the scores for the selected test. The reordering is fully animated, so the cards visually slide into their new ranked positions each time the selected test changes. Each card is also tappable, revealing an expandable bar chart that shows that student's scores across all 10 tests.

The primary purpose of this project is to demonstrate SwiftUI animation techniques, specifically how `ForEach` over sorted `Identifiable` items produces automatic move animations, how `.contentTransition(.numericText())` animates number changes, and how conditional view insertion paired with `.transition()` creates expand/collapse effects.

## Project structure

The project contains two Swift files inside a single app target with no additional folders or packages.

**CardSortingAnimationApp.swift** is the standard `@main` entry point that launches a `WindowGroup` containing `ContentView`.

**ContentView.swift** contains all of the app's code: the `Student` data model, the main `ContentView`, and the extracted `StudentCardView`.

## Data model

`Student` is a struct conforming to `Identifiable`. Each student has an auto-generated `UUID` as its `id`, a `name` (String), a `color` (Color), and a `scores` array containing exactly 10 `Int` values, one for each test. The scores range from approximately 65 to 97. The student data is hardcoded directly inside `ContentView` as a `let` constant array with 5 entries: Alice (red), Bob (blue), Charlie (green), Diana (orange), and Eve (purple).

## State management

`ContentView` manages two `@State` properties.

`selectedTest: Int` tracks which test (1 through 10) is currently selected via the slider. This value drives the sorting order and determines which score is displayed on each card.

`expandedStudentID: UUID?` tracks which student card is currently expanded to show the full bar chart. It stores the `UUID` of the expanded student, or `nil` if all cards are collapsed. This design enforces a one-at-a-time expansion rule, because only one `UUID` can be stored at a time. Tapping an already-expanded card sets this to `nil` (collapsing it), and tapping a different card sets it to that card's id (which automatically collapses the previously expanded card since its id no longer matches).

## Sorting logic

A computed property `sortedStudents` returns the `students` array sorted in descending order by the score at index `selectedTest - 1`. Because this is a computed property, it recalculates every time `body` is re-evaluated, which happens whenever `selectedTest` changes. The `-1` offset exists because `selectedTest` is 1-indexed (matching the user-facing test numbers) while the `scores` array is 0-indexed.

## View structure

### ContentView

The main layout is a `VStack` containing three sections. At the top, a `Text` view displays the current test number ("Test 1", "Test 2", etc.) with `.contentTransition(.numericText())` so the digits animate smoothly when the number changes. In the middle, a `VStack` contains a `ForEach` over `sortedStudents`, rendering a `StudentCardView` for each student. Each card receives the student data, the currently selected test number, and a boolean indicating whether it is the expanded card. An `.onTapGesture` on each card toggles the expansion state using the `expandedStudentID` logic described above. At the bottom, a `Slider` with `step: 1` lets the user pick a test from 1 to 10, with manually created number labels in an `HStack` underneath since `Slider` does not provide built-in tick mark labels.

The slider uses a custom `Binding` to bridge the type mismatch between `Slider` (which requires `Double`) and `selectedTest` (which is `Int`). The `get` closure converts `Int` to `Double` for the slider to read, and the `set` closure converts the slider's `Double` back to `Int` for storage.

A single `.animation(.smooth, value: selectedTest)` modifier at the root of the `VStack` drives all animations related to test switching, including card reordering and score number changes.

### StudentCardView

This is an extracted child view that receives its data as plain `let` properties (no state of its own). The layout is a `VStack` with two sections. The top section is an `HStack` showing the student's name on the left and their score for the currently selected test on the right. This section is always visible.

The bottom section is conditionally shown with `if isExpanded` and displays 10 horizontal bar charts, one per test. Each bar uses `GeometryReader` to calculate its width proportionally based on the score divided by 100. The bar for the currently selected test is visually brighter (`0.9` opacity versus `0.5`) and has bold text so the user can identify which test is active. The entire expanded section uses `.transition(.offset(x: 0, y: 50))` to animate its appearance and disappearance.

The whole card is styled with the student's color as a background, white foreground text, and a `RoundedRectangle` clip shape with a corner radius of 12.

## Key techniques demonstrated

**Animated reordering via sorted Identifiable items.** Because `Student` conforms to `Identifiable` and the `ForEach` iterates over a sorted computed property, SwiftUI tracks each card by its stable `UUID`. When the sort order changes, SwiftUI knows which cards moved and animates them to their new positions automatically.

**Custom Binding for type bridging.** The `Binding(get:set:)` initializer creates a manual two-way connection that translates between `Int` state and the `Double` that `Slider` requires.

**Single UUID? for exclusive selection.** Instead of using a `Bool` per card, a single optional `UUID` ensures only one card can be expanded at any time, with no manual cleanup needed when switching between cards.

**Content transition for numeric text.** The `.contentTransition(.numericText())` modifier on score labels makes digit changes animate with a rolling number effect rather than abruptly swapping text.

**View transitions for conditional content.** The `.transition()` modifier on the expanded bar chart section controls how the content animates in and out when it is added to or removed from the view hierarchy via the `if isExpanded` conditional.

**GeometryReader for proportional sizing.** The bar chart bars use `GeometryReader` to read the available width and calculate each bar's width as a fraction of the total space based on the score value.
