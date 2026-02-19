# MeloMeter 프로젝트 문서

> **MeloMeter**는 커플 위치 공유 서비스입니다.  
> 연인과의 실시간 위치 공유, 채팅, 기념일 관리, 백문백답 등을 제공하는 iOS 앱입니다.

## 📋 프로젝트 개요

- **플랫폼**: iOS 15.0+
- **언어**: Swift 5
- **아키텍처**: Clean Architecture + MVVM + Coordinator
- **반응형 프레임워크**: RxSwift
- **UI**: Programmatic UIKit + SnapKit
- **빌드 시스템**: Tuist
- **백엔드**: Firebase (Auth, Firestore, Storage)
- **AppStore**: https://apps.apple.com/kr/app/melometer/id6450677988

## 🗣️ 언어 규칙 (Language Rule)

**이 프로젝트에서 AI 에이전트와 대화할 때는 아래 규칙을 따르세요:**

### ✅ 기본 원칙
- **주 언어**: 한국어 (Korean)
- **보조 언어**: 영어 (기술 용어, 변수명, 라이브러리명에만 사용)
- **목표**: 명확하게 한국어로 소통하되, 정확한 기술 정의가 필요할 때만 영어 단어 사용

### 예시

#### ❌ 잘못된 예시 (영어로만 설명)
```
I need to implement a feature that allows users to share their location in real-time.
We should use RxSwift observables to handle the data stream.
```

#### ✅ 올바른 예시 (한국어 + 필요시 영어 단어)
```
실시간 위치 공유 기능을 구현해야 합니다.
RxSwift의 Observable을 사용해서 데이터 스트림을 처리하면 됩니다.
```

#### ✅ 올바른 예시 2 (코드는 영어, 설명은 한국어)
```
`MapViewModel`에서 위치 업데이트를 처리하는 `updateLocation()` 메서드를 추가했습니다.
Firebase Firestore의 실시간 리스너(listener)를 통해 상대방 위치가 변경되면 자동으로 갱신됩니다.
```

### 기술 용어 사용 가이드

| 상황 | 한국어 | 영어 병기 | 예시 |
|------|--------|-----------|------|
| 일반 설명 | ✅ | ❌ | "뷰모델에서 비즈니스 로직을 처리합니다" |
| 클래스/파일명 | ❌ | ✅ | "`SharedCalendarVC`를 생성했습니다" |
| 기술 개념 | ✅ | ✅ | "의존성 주입(Dependency Injection)을 사용합니다" |
| 라이브러리 | ❌ | ✅ | "RxSwift의 `flatMap` 연산자를 사용했습니다" |

## 📁 문서 구조

### Root
- `README.md` - 프로젝트 개요 및 주요 기능 설명
- `AGENTS.md` - 이 문서 (프로젝트 전체 가이드)

### OpenCode Configuration (`.opencode/`)

#### Agents (에이전트)
- `.opencode/agents/senior-ios-engineer.md` - iOS 개발 전문가 에이전트 (RxSwift/MVVM/UIKit)
- `.opencode/agents/requirements-analyzer.md` - 요구사항 분석 에이전트

#### Documentation (문서)
- `.opencode/docs/ARCHITECTURE.md` - 아키텍처 설계 및 패턴 (Clean Architecture)
- `.opencode/docs/CONVENTIONS.md` - 코드 컨벤션 및 스타일 가이드
- `.opencode/docs/MODULES.md` - 모듈 구조 및 의존성
- `.opencode/docs/REQUIREMENTS.md` - 기능 추적 및 요구사항

#### Skills (스킬)
- `.opencode/skills/sync-docs/SKILL.md` - 문서 동기화 스킬

## 🏗️ 주요 기술 스택

### 아키텍처
- **Clean Architecture**: Presentation - Domain - Data 레이어 분리
- **MVVM**: Input/Output 패턴으로 단방향 데이터 플로우 구현
- **Coordinator Pattern**: 화면 전환 및 의존성 주입 관리

### 반응형 프로그래밍
- **RxSwift**: 비동기 이벤트 처리, 데이터 바인딩
- **Driver/Signal**: UI 관련 스트림은 메인 스레드 보장

### UI
- **UIKit**: Programmatic UI (Storyboard 미사용)
- **SnapKit**: Auto Layout DSL

### 빌드 시스템
- **Tuist**: 모듈화된 프로젝트 구조 관리

### 백엔드
- **Firebase Authentication**: 전화번호 인증
- **Firebase Firestore**: 실시간 데이터 동기화 (채팅, 위치, 백문백답)
- **Firebase Storage**: 이미지 저장 (프로필, 채팅)

## 🎯 주요 기능

1. **실시간 위치 공유**: 커플 간 실시간 위치 추적 및 지도 표시
2. **채팅**: 1:1 실시간 채팅 (텍스트, 이미지)
3. **기념일 관리**: 기념일 등록 및 D-day 카운트
4. **백문백답**: 하루 한 번 질문/답변 공유
5. **프로필 관리**: 사용자 정보 및 커플 정보 수정
6. **공유 캘린더**: 데이트 일정 등록 및 관리 (최근 추가)

## 🚨 최근 주요 변경사항

### App Store 심사 대응 (2026-01-25)
- iPad 카메라/사진 크래시 수정 (`modalPresentationStyle = .fullScreen` 추가)
- 광고 배너로 인한 UI 가림 문제 해결 (`MyProfileVC` constraint 조정)
- Info.plist에 카메라/사진 권한 설명 추가

### 공유 캘린더 기능 추가 (2026-01-25)
- `SharedCalendarVC`, `SharedCalendarVM`, `AddScheduleVC` 신규 생성
- `UICalendarView`를 사용한 캘린더 UI 구현
- 기존 `DatePlanModel`, `DatePlanUseCase` 재사용
- Push navigation 방식으로 통합

## ⚠️ 주의사항

### 빌드 관련
- Tuist 프로젝트이므로 구조 변경 후 반드시 `tuist generate` 실행 필요
- DerivedData 삭제 후 패키지 재해결 필요할 수 있음

### 코드 작성 시
- **타입 에러 억제 금지**: `as any`, `@ts-ignore`, `@ts-expect-error` 사용 불가
- **Frontend UI 변경**: 스타일, 레이아웃, 애니메이션 등 시각적 변경사항은 `frontend-ui-ux-engineer` 에이전트에게 위임
- **커밋 전 검증**: `lsp_diagnostics`로 에러 확인 필수
- **기존 패턴 따르기**: 일관된 코드 스타일 유지 (CONVENTIONS.md 참고)

## 🔍 탐색 팁

### 코드베이스 탐색
- 내부 코드 검색: `explore` 에이전트 사용
- 외부 라이브러리 문서/예제: `librarian` 에이전트 사용
- LSP 기능: `lsp_goto_definition`, `lsp_find_references` 활용

### 문서 우선 참고
특정 작업 전에 관련 문서를 먼저 읽으세요:
- 아키텍처 이해: `ARCHITECTURE.md`
- 코딩 스타일: `CONVENTIONS.md`
- 모듈 구조: `MODULES.md`
- 기능 목록: `REQUIREMENTS.md`
