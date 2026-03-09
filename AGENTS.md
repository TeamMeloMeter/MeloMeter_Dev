# MeloMeter AGENTS Guide

## 목적
- 이 문서는 MeloMeter 저장소에서 작업하는 에이전트용 실행 가이드입니다.
- 설명과 커뮤니케이션은 기본적으로 한국어로 작성합니다.
- 클래스명, 파일명, 라이브러리명, API명만 영어를 유지합니다.

## 저장소 구조
- `Projects/MeloMeter`: 앱 타깃, 앱 시작점, 앱 의존성 조립
- `Projects/Presentation`: 화면, ViewModel, Coordinator, UIKit UI
- `Projects/Domain`: 모델, 프로토콜, UseCase, 공용 비즈니스 규칙
- `Projects/Data`: Firebase 연동, DTO, Repository 구현체
- `Projects/Core`: 공용 유틸리티, 상수, 폰트, BLE/Meeting 기능
- `Projects/Shared`: 공유 리소스용 모듈
- `MeloMeterTests`: 루트 Xcode 프로젝트에 연결된 XCTest 타깃
- `Tuist/`: 패키지 및 프로젝트 생성 설정

## 외부 규칙 파일
- 확인 결과 `.cursor/rules/`, `.cursorrules`, `.github/copilot-instructions.md`는 현재 저장소에 없습니다.
- 따라서 이 문서와 코드베이스의 기존 패턴이 최우선 규칙입니다.

## 작업 전 체크
- 구조를 바꿨다면 먼저 `tuist generate`가 필요한지 판단합니다.
- 수정 대상이 `Projects/*/Derived` 아래라면 직접 수정하지 말고 생성 원인을 먼저 찾습니다.
- UIKit 화면은 Storyboard가 아니라 코드로 구성된다는 점을 유지합니다.
- 기존 Rx 흐름, Coordinator 흐름, Repository 경계를 먼저 읽고 수정합니다.

## 빌드 / 테스트 / 검증 명령어

### 의존성 및 프로젝트 생성
```bash
tuist generate
```
- Tuist 설정 변경 후 실행합니다.
- 워크스페이스와 각 모듈 프로젝트를 다시 생성합니다.

### 워크스페이스 빌드
```bash
xcodebuild -workspace "MeloMeter.xcworkspace" -scheme "MeloMeter-Workspace" -configuration Debug build
```
- 모듈 전체가 정상적으로 생성되고 연결되는지 확인할 때 사용합니다.
- `MeloMeter-Workspace` 스킴에는 테스트가 연결되어 있지 않습니다.

### 앱 타깃 빌드
```bash
xcodebuild -project "MeloMeter.xcodeproj" -scheme "MeloMeter" -configuration Debug build
```
- 루트 앱 프로젝트 기준 빌드입니다.
- 현재 XCTest 타깃도 이 프로젝트 스킴에 연결되어 있습니다.

### 정적 분석(사실상 lint 대체)
```bash
xcodebuild -project "MeloMeter.xcodeproj" -scheme "MeloMeter" -configuration Debug analyze
```
- 저장소에 전용 `SwiftLint`/`SwiftFormat` 설정 파일은 없습니다.
- 그래서 기본 검증은 `build`, `analyze`, 그리고 컴파일 경고 확인 중심으로 진행합니다.

### 전체 테스트
```bash
xcodebuild test -project "MeloMeter.xcodeproj" -scheme "MeloMeter" -destination 'platform=iOS Simulator,OS=18.5,name=iPhone 16'
```
- 테스트 전에 사용 가능한 시뮬레이터를 확인하려면 아래 명령을 사용합니다.

```bash
xcodebuild -showdestinations -project "MeloMeter.xcodeproj" -scheme "MeloMeter"
```

### 단일 테스트 클래스 실행
```bash
xcodebuild test -project "MeloMeter.xcodeproj" -scheme "MeloMeter" -destination 'platform=iOS Simulator,OS=18.5,name=iPhone 16' -only-testing:MeloMeterTests/MeloMeterTests
```

### 단일 테스트 메서드 실행
```bash
xcodebuild test -project "MeloMeter.xcodeproj" -scheme "MeloMeter" -destination 'platform=iOS Simulator,OS=18.5,name=iPhone 16' -only-testing:MeloMeterTests/MeloMeterTests/testCoupleCombined_WhenInput_ShouldReturnTrue
```
- 단일 XCTest 메서드 실행 시 가장 유용한 명령입니다.
- 테스트 메서드명은 실제 심볼명과 정확히 일치해야 합니다.

### 특정 모듈만 빌드
```bash
xcodebuild -project "Projects/Presentation/Presentation.xcodeproj" -scheme "Presentation" -configuration Debug build
```
- 모듈 단위 컴파일 확인이 필요할 때 사용합니다.
- 같은 패턴으로 `Data`, `Domain`, `Core`, `Shared`에도 적용할 수 있습니다.

## 테스트 현실
- 현재 `MeloMeterTests/MeloMeterTests.swift`는 기본 골격 수준입니다.
- 테스트가 부족한 영역은 대상 파일 빌드 결과와 수동 검증 포인트를 함께 남기고, Rx 변경 시 비동기 완료 시점과 메모리 해제를 함께 점검합니다.

## 코드 스타일

### 기본 포맷
- 앱 소스는 4-space indentation을 주로 사용합니다.
- Tuist 설정 파일은 2-space indentation 패턴이 섞여 있으므로 기존 파일 스타일을 그대로 따릅니다.
- 불필요한 공백 정렬은 하지 말고, 기존 파일의 줄바꿈 리듬을 존중합니다.

### import 규칙
- import는 파일 상단에 모읍니다.
- 보통 Apple 프레임워크 -> 서드파티 -> 내부 모듈 순서입니다.
- 내부 모듈 import는 `Data`, `Domain`, `Presentation`, `Core`, `Shared` 형태를 사용합니다.
- 사용하지 않는 import는 제거합니다.

### 네이밍 규칙
- ViewController는 `*VC`, ViewModel은 `*VM`, Coordinator는 `*Coordinator`를 사용합니다.
- Repository protocol은 `*RepositoryP`, UseCase protocol도 일부 `P` 접미사 패턴을 따릅니다.
- DTO는 `*DTO`, 도메인 모델은 `*Model`을 사용합니다.
- 테스트 메서드는 `test...` 접두사를 사용하고 시나리오를 문장처럼 드러냅니다.

### 타입과 접근 제어
- 모듈 경계를 넘는 타입은 `public`을 명시합니다.
- 상속 계획이 없다면 `final class`를 우선 고려합니다.
- 암시적 언래핑보다 `guard let`, `if let`, 명시적 기본값을 선호합니다.
- 다만 폰트/에셋처럼 프로젝트가 강하게 보장하는 리소스는 기존처럼 `!`를 제한적으로 사용합니다.

### 아키텍처 규칙
- Presentation은 UI, binding, navigation만 담당합니다.
- Domain은 프레임워크 의존을 최소화한 비즈니스 규칙과 프로토콜을 가집니다.
- Data는 Firebase/외부 SDK 상세 구현과 DTO 변환을 담당합니다.
- 화면 전환은 ViewController가 아니라 Coordinator에서 조립합니다.
- 의존성 생성은 `AppDependencies` 같은 composition root에서 수행합니다.

### MVVM / RxSwift 규칙
- ViewModel은 `Input`/`Output` struct 또는 `PublishSubject`, `BehaviorRelay` 패턴을 사용합니다.
- UI 이벤트는 `rx.tap`, `bind`, `subscribe`로 연결하고 `disposeBag`으로 수명 관리합니다.
- 클로저에서는 기본적으로 `[weak self]`를 우선 사용합니다.
- Rx 체인 안에서 side effect를 추가할 때는 데이터 흐름이 끊기지 않도록 위치를 신중히 선택합니다.

### UIKit 규칙
- UI는 Programmatic UIKit으로 작성합니다.
- `init(viewModel:)` 같은 의존성 주입 이니셜라이저를 선호합니다.
- `required init?(coder:)`는 기존처럼 `fatalError("init(coder:) has not been implemented")` 패턴을 유지합니다.
- 큰 ViewController는 `configure`, `setupAutoLayout`, `setBindings`처럼 역할별 메서드로 나눕니다.

### 레이아웃 규칙
- 새 화면은 가능하면 SnapKit 우선, 기존 파일이 NSLayoutConstraint라면 그 패턴을 유지합니다.
- 안전 영역 사용 여부를 기존 화면과 맞춥니다.
- 하드코딩 숫자를 늘리기보다 의미 있는 상수나 `Constants`로 정리합니다.

### 에러 처리
- 이 코드베이스는 `throw`보다 Rx의 `Single`, `Completable`, `Observable` 기반 에러 전파를 더 많이 사용합니다.
- 복구 가능한 실패는 `catchAndReturn`, `flatMap`, `guard`로 처리하는 기존 패턴을 우선 따릅니다.
- 사용자 영향이 있는 실패는 무시하지 말고 alert, fallback, 종료 흐름 중 하나를 명확히 선택합니다.
- 새 코드에서 단순 `print(error)`만 남기고 끝내지 말고, 최소한 호출자 반응 경로를 마련합니다.
- `NSError(domain: "", code: -1)` 같은 임시 에러보다 의미 있는 도메인 에러가 가능하면 개선합니다.

### 데이터 / 모델 변환
- Firebase 문서 -> DTO -> Domain Model 변환 단계를 유지합니다.
- 저장 포맷 문자열은 `Date.Format`과 `Date+` extension을 재사용합니다.
- 영속 값 접근이 많아지면 Repository 또는 store 타입으로 모으는 편을 우선 검토합니다.

### 생성 파일과 수정 금지 영역
- `Projects/*/Derived` 파일은 수동 수정하지 않습니다.
- `xcworkspace`, `xcodeproj`, `Package.resolved`는 의도적 변경일 때만 수정하고, 자동 생성 산출물은 원인 설정 파일을 수정한 뒤 재생성합니다.

## 에이전트 작업 원칙
- 먼저 관련 모듈과 인접 타입을 읽고, 기존 패턴을 복제한 뒤 필요한 부분만 바꿉니다.
- 대규모 리팩터링보다 국소적 변경을 우선합니다.
- 사용자 변경사항이 섞여 있을 수 있으므로 내가 만든 변경만 조심해서 수정합니다.
- 불명확하면 추측으로 새 패턴을 만들기보다 현재 파일 스타일을 따릅니다.
- 최종 답변에는 어떤 파일을 왜 바꿨는지, 어떤 명령으로 검증했는지 함께 남깁니다.
