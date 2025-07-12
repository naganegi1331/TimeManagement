# CLAUDE.md

## Coding rules
1. First, think through the problem, read the codebase for relevant files, and write a plan to `tasks/todo.md`.
2. The plan should have a list of todo items that you can check off as you complete them.
3. Before you begin working, check in with me and I will verify the plan.
4. Then, begin working on the todo items, marking them as complete as you go.
5. Please every step of the way just give me a high-level explanation of what changes you made.
6. Make every task and code change you do as simple as possible. We want to avoid making any massive or complex changes. Every change should impact as little code as possible. Everything is about simplicity.
7. Finally, add a review section to the `todo.md` file with a summary of the changes you made and any other relevant information.





This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TimeManagement is a SwiftUI-based iOS time tracking application that helps users track their daily activities and analyze time management patterns. The app includes device usage monitoring capabilities using Apple's DeviceActivity framework.

## Build and Development Commands

### Building the Project
- **Build main app**: Open `TimeManagement.xcodeproj` in Xcode and use ⌘+B or Product → Build
- **Build extension**: Select "MyActivityReportExtension" scheme in Xcode and build
- **Clean build**: Product → Clean Build Folder (⌘+Shift+K)

### Running the App
- **iOS Simulator**: Select "TimeManagement" scheme and run (⌘+R)
- **Physical Device**: Requires developer provisioning profile for Family Controls entitlements
- **Extension Testing**: Build and run the main app first, then the extension will be available

### No Automated Testing
This project does not currently have unit tests or UI tests configured. Testing is done manually through the iOS simulator or device.

## Architecture and Code Structure

### Data Layer
- **SwiftData**: Modern Apple data persistence framework
- **ActivityLog.swift**: Core data model for activity tracking with start/end times, categories, and priority matrix
- **Enums.swift**: Activity categories (work, learning, exercise, hobby, life, sleep) and priority matrix definitions

### UI Architecture
- **SwiftUI**: Declarative UI framework with MVVM pattern
- **Navigation**: NavigationStack-based navigation between main screens
- **Modular Components**: All views split into focused, single-responsibility components under 400 lines

### Main Views Structure
```
Views/
├── Timeline/           # Activity tracking and timeline display
│   ├── TimelineView.swift        # Main timeline screen
│   ├── ActivityRowView.swift     # Individual activity display
│   ├── TimelineEmptyStateView.swift
│   ├── DeviceUsageTimelineView.swift
│   └── ViewExtensions.swift
├── ActivityEdit/       # Activity creation and editing
│   ├── ActivityEditView.swift    # Activity form screen
│   ├── SectionHeaderView.swift
│   └── TimePickerComponents.swift # 15-minute increment time pickers
└── Analytics/         # Data analysis and visualization
    ├── AnalyticsView.swift       # Main analytics screen
    ├── CategoryPieChartView.swift # Quadrant-colored pie charts
    ├── MatrixChartView.swift     # Priority matrix visualization
    ├── DeviceUsageDetailView.swift
    ├── AppUsageReportView.swift
    └── [Various component files]
```

### Key Features
- **Activity Tracking**: Manual time tracking with categories and priority matrix
- **15-Minute Time Increments**: Specialized time picker for efficient time entry
- **Priority Matrix Analysis**: Covey's 4-quadrant system (Important/Urgent matrix)
- **Device Usage Integration**: Apple DeviceActivity framework for screen time data
- **Visual Analytics**: Pie charts with quadrant-based color coding, matrix charts

### Family Controls Integration
- **Entitlements**: Family Controls capability enabled in TimeManagement.entitlements
- **Authorization**: Uses AuthorizationCenter for requesting screen time access
- **Extension**: MyActivityReportExtension.appex provides device usage reports
- **Troubleshooting**: See TROUBLESHOOTING.md for common Family Controls authentication issues

### App Extension
- **MyActivityReportExtension**: Provides DeviceActivityReport views for screen time data
- **Group Container**: Shared app group "group.com.kashihara" for data sharing
- **Context Types**: totalActivity, appUsage, categoryUsage report contexts

## Development Guidelines

### Code Organization
- All view files are kept under 400 lines through component extraction
- SwiftUI views follow single-responsibility principle
- Material design backgrounds used throughout for visual consistency
- Accessibility support with proper labels and VoiceOver compatibility

### Data Management
- SwiftData @Model for data persistence
- @Query for reactive data fetching in SwiftUI views
- Manual activity data combined with system device usage data

### UI/UX Patterns
- Apple Design Guidelines compliance
- Material backgrounds (.regularMaterial) for depth
- Smooth animations with withAnimation
- Picker-style controls for category and priority selection
- NavigationLink-based screen transitions

### Time Management
- 15-minute increment time pickers for efficient data entry
- Automatic time rounding functions (roundToNearestFifteenMinutes)
- Date filtering for daily activity views
- Duration calculations in minutes for analysis

## Technical Notes

### Frameworks Used
- SwiftUI (UI framework)
- SwiftData (data persistence)
- DeviceActivity (system usage monitoring)
- FamilyControls (screen time authorization)

### Device Requirements
- iOS 16+ (for SwiftData)
- Family Controls requires iOS 15+
- Device usage features require proper entitlements and user authorization

### Known Limitations
- DeviceActivity reports may require specific authorization flows
- Family Controls features work differently on simulator vs device
- Screen time data availability depends on user privacy settings