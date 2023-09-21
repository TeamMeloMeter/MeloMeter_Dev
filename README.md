# <img width="40" alt="coord" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/5529e8cf-69f0-4562-a246-5b7730251e9a">  MeloMeter App(*iOS 15.0)
### 멜로미터 - 커플 위치 공유 서비스 

<img width="300" alt="coord" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/0681dc27-3bf8-4b84-bd92-475494aab429">

# 👨‍👩‍👧‍👦 팀 구성

- iOS Developer[2]
- UI/UX Designer [2]

# ❣️ 프로젝트 소개

 **우리가 사랑하는 방법 🩷, MeloMeter**
 
### 🥲 수많은 커플 앱 이용에 지치셨나요?

> MeloMeter 하나로 연인과 위치를 공유하고, 기념일을 챙기고, 채팅과 백문백답도 즐겨보세요!
> 

### 🫵 전화번호만 있다면 누구나 이용할 수 있습니다.

> 전화번호 인증을 통해 발급된 초대코드로, 상대방과 연결할 수 있습니다.
> 

# ✨ 주요 기능

---

### 📲 전화번호 인증과 초대코드 입력으로, 상대방과 연결 후 시작할 수 있어요! 내 초대코드를 상대방에게 카카오톡으로 공유할 수 있어요!
<img width="300" alt="coord" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/40985906-6c48-4cff-802a-6a5cf64076b4">
<img width="300" alt="coord" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/a8995d3b-a851-4fff-a44a-c9da10a3b64f">
<img width="300" alt="coord" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/652a5dd9-72d3-482b-b86f-de5cc6ad0161">


### 📍 상대방과 위치를 실시간으로 확인할 수 있어요. 　　　　　💬　상대와 둘만 있는 공간에서 채팅할 수 있어요.
　　　<img width="300" alt="coord" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/fe2294fd-a68b-4640-ac8d-6be0cce28f03">　　　　　　　　　　　　　
<img width="300" alt="coord" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/85dfd947-d852-4f19-8e81-26ecf5429ed3">

### 💌 하루 한번, 질문을 받고 답변을 상대방과 공유할 수 있어요.
<img width="300" alt="coord" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/3f466252-2a23-43b9-9192-00c69c6fd0f6">
<img width="300" alt="coord" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/20ad70de-24e3-4630-a907-ea2fbe222ac4">
<img width="300" alt="coord" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/81601fb2-53bf-427c-8e20-fbece417b4e4">

### 👀 기념일을 확인하고, 새로운 날짜를 추가할 수 있어요.
<img width="300" alt="coord" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/d32e7f1a-05b4-42d6-93b9-ef6fc298da8e">
<img width="300" alt="coord" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/8864cb64-9c75-4ebc-a767-2b9c54dc0030">

# 🛠️ 주요 사용 기술

## ➜ MVVM

### 도입 이유
- 초기 MVC 패턴 구조로 개발하던 중, 기능을 추가하며 컨트롤러 비중이 높아져 2천 줄 이상의 코드로 인해 가독성, 디버깅, 결합도 측면 문제가 발생했습니다. Extension을 사용해 코드를 분리하기 위해 노력했지만 부족했습니다.
- 사용자 입력 및 뷰의 로직과 비즈니스에 관련된 로직을 분리하고 싶었습니다.
- View의 Event로 부터 UI작업까지 단방향으로 관리할 수 있는 장점이 있었습니다.

### 성과
- Input, Output으로 나누어 ViewModel에 전달받을 값과, 전달할 값을 직관적으로 인식할 수 있었습니다.
- ViewController가 ViewModel의 프로퍼티를 참조하는 의존성을 해결하고, 비중을 효과적으로 줄일 수 있었습니다.
  
## ➜ Clean Architecture

### 도입 이유
- MVVM 구조를 도입하며 ViewModel이 모든 로직을 처리하는 것을 피하기 위해 적용하였습니다.
- 각각의 레이어를 역할에 따라 분리하여 방대한 양의 코드를 쉽게 파악할 수 있도록 하고 싶었습니다.
- 프로토콜로 각 레이어의 객체에 대한 추상화를 진행하여 수정에 닫혀 있는 코드를 작성하고 싶었습니다.
### 성과
- 프로토콜로 해당 클래스의 역할과 형태를 명시해서, 협업을 할 때 각 객체가 어떤 역할을 하는지 쉽게 파악할 수 있었습니다.
- 각 객체의 역할을 프로토콜로 정의하여 단위 테스트하기에 용이하도록 구현할 수 있었습니다.

## ➜ RxSwift

### 도입 이유
- Firebase를 사용하면서 중첩된 비동기 처리가 많아졌고, Completion Handler를 이용해 처리하던 중 코드 가독성이 저하됐고, 실수가 잦아진 문제를 해결하고자 했습니다.
- 대안으로 Combine이 있었지만, 출시일이 빠른 RxSwift가 더 넓은 범위 버전까지 지원하고 레퍼런스가 많아 선택했습니다.
### 성과
- Escaping Closure가 아닌 RxSwift의 Operator를 활용하여 코드 양이 감소해 깔끔해지고 실수를 방지할 수 있었습니다.
- 비동기 코드(DispatchQueue, OperationQueue)를 직접적으로 사용하지 않아 일관성 있는 비동기 코드로 작성할 수 있었습니다.

## ➜ Coordinator 패턴

### 도입 이유
- 코드 베이스로 UI를 작성하면서 StoryBoard로 UI를 작성할 때 보다 View들의 계층과 Flow를 파악하기가 힘들다는 문제가 있었습니다.
- ViewController의 화면 전환 및 의존성을 주입하는 역할을 분리하고, 한눈에 보기 위해 적용했습니다.
### 성과
- 동일한 인스턴스의 중복 생성을 막아 메모리 낭비를 막을 수 있었습니다.
- View의 계층과 Flow 및 의존성을 주입에 대한 정보를 한 눈에 파악할 수 있었습니다.

## ➜ Firebase

### 도입 이유
- 사용자 인증, 사용자 정보 저장, 실시간 채팅, 실시간 위치 공유, 백문백답, 기념일 등의 기능 구현을 위해 별도의 서버 구현없이 빠르게 개발하기 위해 사용하였습니다.

### 성과
- Firebase Authentication을 사용하여 전화번호 인증 로그인을 구현했습니다.
- Firebase Firestore를 사용하여 사용자 데이터, 채팅 정보, 위치 정보, 백문백답, 공지사항 등을 저장했습니다.
- Firebase Storage를 사용하여 프로필 사진, 채팅 이미지를 저장했습니다.
- FireStore의 채팅 데이터, 위치 데이터를 옵저빙하여 변경되는 데이터를 앱에서 실시간으로 업데이트 할 수 있었습니다.
