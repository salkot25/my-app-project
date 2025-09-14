# User List Screen Refactoring

This document explains the refactored user list screen architecture.

## Overview

The `UserListScreen` has been refactored from a monolithic single-file implementation to a modular widget-based architecture, similar to the profile screen structure.

## Widget Structure

```
lib/presentation/screens/user_list/
├── widgets/
│   ├── user_search_section.dart    # Search bar and filter chips
│   ├── user_stats_card.dart        # User statistics with status counts
│   ├── user_info_strip.dart        # User count and filter status
│   ├── user_card.dart              # Individual user card component
│   ├── user_dialogs.dart           # Role/status change and delete dialogs
│   └── user_list_states.dart       # Loading, empty, and error states
└── user_list_screen.dart           # Main screen coordinating all widgets
```

## Widget Responsibilities

### UserSearchSection (`user_search_section.dart`)

- **Purpose**: Provides search and filtering functionality
- **Features**:
  - Search bar with clear button and integrated role filter dropdown
  - Role filter dropdown inside search field (All Roles, Admin, Moderator, User)
  - Combined search and filter interface for better UX
  - Clean, space-efficient design
- **UI Components**: Dropdown with icons for each role, search field with clear button
- **Dependencies**: DSTokens, DSTypography, theme colors, UserRole enum

### UserStatsCard (`user_stats_card.dart`)

- **Purpose**: Displays user statistics with visual breakdown by status
- **Features**:
  - Total user count in header badge
  - Three status categories (Verified, Unverified, Suspended)
  - Color-coded statistics with icons
  - Percentage bars showing proportion of each status
  - Responsive layout with equal-width stat items
  - Modern card design with shadows and rounded corners
- **Calculations**: Automatically calculates statistics from user list
- **Visual Elements**: Progress bars, colored icons, percentage displays

### UserCard (`user_card.dart`)

- **Purpose**: Displays individual user information and actions
- **Features**:
  - User avatar (initials-based)
  - User name, email, and "You" badge for current user
  - Role and status badges with appropriate colors
  - Join date display
  - Action buttons (Edit, Change Role, Change Status, Delete)
  - Permission-based action visibility
- **Interactions**:
  - Callback functions for all user actions
  - Loading state support
  - Hover and press animations

### UserDialogs (`user_dialogs.dart`)

- **Purpose**: Handles all user management dialogs
- **Dialogs**:
  - **Role Selection**: Shows all available roles with descriptions
  - **Status Selection**: Shows all available statuses with descriptions
  - **Delete Confirmation**: Shows user info and deletion warning
- **Features**:
  - Current role/status highlighting
  - Descriptive text for each option
  - Consistent design system styling
  - Proper navigation and result handling

### UserListStates (`user_list_states.dart`)

- **Purpose**: Provides consistent state UI components
- **States**:
  - **Loading**: Spinner with loading text
  - **Empty**: Different messages for no users vs no filtered results
  - **Error**: Error display with retry button
  - **Permission Denied**: Specific UI for access denied scenarios
- **Features**:
  - Clear filters action for filtered empty states
  - Retry functionality for error states
  - Consistent iconography and styling

## Main Screen (`user_list_screen.dart`)

### Architecture

- **State Management**: Uses Riverpod for state management
- **Structure**: Column-based layout with search section and content area
- **Error Handling**: Comprehensive error handling with user-friendly messages

### Key Features

1. **Search and Filtering**: Real-time search and multiple filter support
2. **Permission System**: Role-based action visibility and availability
3. **User Management**: Complete CRUD operations for user management
4. **Responsive Design**: Adapts to different content states
5. **Loading States**: Proper loading indicators during operations

### State Management

- `authProvider`: Current user authentication state
- `userListProvider`: User list data and operations
- Local state for search/filters and UI state

## Design System Compliance

All widgets follow the established design system:

- **Tokens**: Uses DSTokens for consistent spacing and radius values
- **Typography**: Uses DSTypography hierarchy throughout
- **Colors**: Uses theme-aware colors via `ref.colors`
- **Animations**: Smooth transitions with consistent duration

## Benefits of Refactoring

1. **Modularity**: Each widget has a single responsibility
2. **Reusability**: Widgets can be reused in other contexts
3. **Maintainability**: Easier to modify individual components
4. **Testing**: Smaller components are easier to test
5. **Performance**: Better widget rebuilding optimization
6. **Consistency**: Follows the same pattern as profile screen

## Usage Example

```dart
// The main screen now simply composes the modular widgets
return Column(
  children: [
    UserSearchSection(
      searchController: _searchController,
      // ... other props
    ),
    Expanded(
      child: Column(
        children: [
          UserStatsCard(users: users),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return UserCard(
                  user: filteredUsers[index],
                  // ... other props
                );
              },
            ),
          ),
        ],
      ),
    ),
  ],
);
```

## Future Enhancements

- Add user creation dialog
- Implement bulk operations
- Add export functionality
- Enhanced filtering options
- User activity tracking
- Advanced search capabilities
