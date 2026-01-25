# MeloMeter Architecture

## Overview
MeloMeter follows **Clean Architecture** with **MVVM** pattern, implemented using **RxSwift** for data binding and **SnapKit** for UI layout. The project is modularized using **Tuist**.

## Layer Structure

### 1. Presentation Layer (`Projects/Presentation`)
- **Responsibility**: UI rendering and user interaction handling.
- **Components**:
  - `ViewController`: Manages view lifecycle and UI layout (SnapKit).
  - `ViewModel`: Transform Inputs to Outputs using RxSwift. Holds no UIKit references.
  - `Coordinator`: Handles navigation flow.
- **Dependencies**: Depends on `Domain`.

### 2. Domain Layer (`Projects/Domain`)
- **Responsibility**: Business logic and entities. **The Core**.
- **Components**:
  - `UseCase`: Encapsulates specific business rules.
  - `Entity`: Pure Swift data models.
  - `Repository Interface` (`Protocol`): Defines contracts for data access.
- **Dependencies**: Pure Swift, no dependencies on other layers.

### 3. Data Layer (`Projects/Data`)
- **Responsibility**: Data retrieval and storage.
- **Components**:
  - `Repository Implementation`: Implements interfaces defined in Domain.
  - `DTO (Data Transfer Object)`: Models for parsing network/DB data.
  - `DataSource`: Remote (Firebase) or Local (UserDefaults/CoreData) sources.
- **Dependencies**: Depends on `Domain`.

## Data Flow
1. **View** sends user action (Input) to **ViewModel**.
2. **ViewModel** calls **UseCase**.
3. **UseCase** requests data from **Repository Interface**.
4. **Repository Implementation** (in Data layer) fetches data from **DataSource**.
5. Data returns up the chain via **Observables/Singles**.
6. **ViewModel** emits data to **View** via Output.
7. **View** updates UI.

## Modularization (Tuist)
- `App`: Main application entry point.
- `Presentation`: Feature modules (Main, Chat, Profile, etc.).
- `Domain`: Business logic.
- `Data`: Implementation details.
- `Core`: Common utilities, extensions.
- `Shared`: Resources, Constants.
- `ThirdPartyLib`: External dependencies.
