# Kigali City Services Directory

A Flutter mobile application that serves as a directory for city services in Kigali. Users can explore, create, edit, and delete listings for various city services. The app integrates Google Maps for location viewing and Firebase for backend services.

## Features

*   **User Authentication Flow:** Secure sign-up, email verification, and login using Firebase Authentication.
*   **Listing Management:**
    *   Create new listings with details including name, category, address, contact, description, and geolocation.
    *   Edit existing listings created by the user.
    *   Delete listings created by the user.
*   **Search and Filter:** Easily search for listings by name or description, and filter them by category (e.g., Hospital, Police Station, Fire Department).
*   **Interactive List & Detail Views:** View a comprehensive directory of all services and click into a detailed page for more information.
*   **Embedded Map View:** View the location of all directory listings on an embedded Google Map.
*   **My Listings Dashboard:** A dedicated screen to view and manage only the listings authored by the current logged-in user.

## Architecture & Technologies

*   **Framework:** Flutter
*   **Backend:** Firebase (Authentication, Firestore)
*   **State Management:** Riverpod
*   **Maps API:** Google Maps Flutter

---

## 1. Firestore Database Structure

The application uses Cloud Firestore as its NoSQL database. 

### Collections

#### `listings`
This is the primary collection storing all city service entries. Each document represents a single `Listing`.

**Document Fields:**
*   `name` (String): The name of the service/business.
*   `category` (String): The type of service (e.g., "Hospital", "Police Station").
*   `address` (String): The physical address of the listing.
*   `contactNumber` (String): Phone number for the service.
*   `description` (String): A detailed description of the service.
*   `latitude` (Number/Double): The geographical latitude.
*   `longitude` (Number/Double): The geographical longitude.
*   `createdBy` (String): The Firebase Authentication `uid` of the user who created the listing. This is used for ownership verification (editing/deleting).
*   `timestamp` (Timestamp): The exact date and time the listing was created or last updated, used for sorting.

#### `users` *(Implicit via Authentication)*
While user data (UID, email) is managed securely by Firebase Authentication, the app structure references these UIDs (via the `createdBy` field) to maintain a relationship between users and their data.

---

## 2. State Management Approach (Riverpod)

To maintain a clean architectural structure and ensure reactive UI updates, this application utilizes **Riverpod** for state management. The app follows a strict separation of concerns utilizing the **Repository Pattern**.

### Key Providers

*   **Repositories:**
    *   `authRepositoryProvider`: Wraps `FirebaseAuth` to handle all sign-up, login, logout, and verification logic.
    *   `listingRepositoryProvider`: Wraps `FirebaseFirestore` to handle CRUD operations on the `listings` collection. Contains streams to listen to real-time database updates.
*   **State Providers (UI State):**
    *   `authStateProvider` (`StreamProvider`): Listens to user authentication state changes to dynamically route the user between the Login screen, Verification screen, and Main application.
    *   `navigationIndexProvider` (`StateProvider`): Manages the current selected index of the `BottomNavigationBar`.
    *   `listingSearchQueryProvider` & `listingCategoryFilterProvider` (`StateProvider`): Manage the current state of the search bar text and the category dropdown filter.
*   **Derived State (Business Logic):**
    *   `filteredListingsProvider`: A reactive provider that combines the real-time `listingsStreamProvider` with the current search query and category filter state to output a strictly filtered list of `Listing` objects for the UI to consume.
    *   `listingControllerProvider` (`StateNotifierProvider`): Manages the loading/data/error states specifically when a user is actively adding, updating, or deleting a listing.

By utilizing Riverpod Streams (`StreamProvider`), the application UI updates instantaneously and automatically whenever data is changed in the Firestore backend or from another device.
