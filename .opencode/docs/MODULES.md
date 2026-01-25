# Module Structure

MeloMeter uses **Tuist** for modularization.

## Core Modules

### `Core`
- **Purpose**: Low-level utilities, extensions, and common helpers.
- **Dependencies**: `ThirdPartyLib`

### `Domain`
- **Purpose**: Business logic, UseCases, Entities, Repository Interfaces.
- **Dependencies**: `Core`, `RxSwift`
- **Rule**: Pure Swift code only. No UIKit.

### `Data`
- **Purpose**: Data access implementation, DTOs, Networking (Firebase).
- **Dependencies**: `Domain`

### `Presentation`
- **Purpose**: UI implementation (ViewControllers, ViewModels).
- **Dependencies**: `Domain`
- **Frameworks**: UIKit, SnapKit, RxSwift

### `Shared`
- **Purpose**: Shared resources (Assets, Fonts, Constants).
- **Dependencies**: None

### `ThirdPartyLib`
- **Purpose**: External dependencies management.
- **Dependencies**: Alamofire, Firebase, SnapKit, RxSwift, etc.

## Dependency Graph
App -> Presentation -> Domain <- Data
       Presentation -> Shared
       Data -> Core
       Domain -> Core
