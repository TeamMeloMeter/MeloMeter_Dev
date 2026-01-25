# Code Conventions

## Swift Style Guide

### General
- Use `PascalCase` for types and protocols.
- Use `camelCase` for variables and functions.
- Prefer `let` over `var`.
- Use `guard` for early exits.

### RxSwift
- DisposeBag should be at the top of the class or `setBindings` method.
- Use `[weak self]` in closures to prevent retain cycles.
- Use `Input` / `Output` structs in ViewModel for clarity.
- Suffix Observables with `Observable` is NOT required, but clarity is key.
- Events suffix: `TapEvent`, `DidScrollEvent`, etc.

### UIKit & SnapKit
- `viewDidLoad()`: Call `configure()`, `setAutoLayout()`, `setBindings()`.
- Place UI components definition at the top or bottom of the file (lazy var).
- `snp.makeConstraints` closure arguments: use `$0` or meaningful name.

### File Organization
1. Imports
2. Class Definition
3. Properties (UI, then Logic)
4. Initializers
5. Lifecycle (`viewDidLoad`)
6. Setup Methods (`configure`, `setAutoLayout`, `setBindings`)
7. Event Handlers / Methods
8. Extensions

## Git Conventions

### Commit Messages
Format: `[Tag] Description`

- `[Feat]`: New feature
- `[Fix]`: Bug fix
- `[Refactor]`: Code restructuring
- `[Design]`: UI/UX changes
- `[Docs]`: Documentation changes
- `[Chore]`: Build tasks, package manager configs
