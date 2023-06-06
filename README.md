# MeloMeter App(*iOS 15.0)
# 멜로미터 - 커플 위치 공유 서비스


### 📌 사용

---

- MVC 패턴
- Swift: 스토리보드를 삭제하고, 코드만을 사용하여 개발합니다.
- Firebase: 외부 서버의 역할로 사용합니다.
- NaverMaps: 메인화면에 사용되는 지도 API 입니다.
- Figma: UI/UX 디자이너와의 협업 도구로 사용합니다.
- Jira: 진행 일정 관리 도구로 사용합니다.

### 📌 서비스 이름

---

- 한글: 멜로미터
- 영문: MeloMeter

멜로미터라는 이름은 연인 간의 사랑에 관한 감정을 나타내는 멜로 와 길이를 나타내는 미터 를 합쳐 만든 합성어입니다. 

연인 간의 실시간 위치를 보여주고 백문백답을 통해 마음을 교류할 수 있는 이 앱의 정체성을 잘 나타내는 이름입니다.

### 📌 팀원 구성

---

- iOS Developer[2]
- UI/UX Designer [2]

### 📌 멜로미터 서비스 설명

---

‘멜로미터’ 는 커플들을 위한 위치 공유 앱입니다.

**✅ 서로의 위치를 실시간으로 확인하며**

**✅ 디데이를 설정하고 기념일을 기억하며**

**✅ 채팅으로 서로의 마음을 표현하며**

**✅ 백문백답으로 서로의 관심을 확인하며**

서로의 위치를 실시간으로 공유하면서, 함께 있는 시간을 더욱 소중하게 만들어보세요. 
커플들의 중요한 기념일을 기억하고, 디데이를 설정해 놓으면 더욱 특별한 날을 기억할 수 있습니다. 
또한, 채팅과 백문백답으로 서로의 생각을 주고받으며 더욱 더 가까워질 수 있습니다.

### 📌 UI/UX

---

<img width="616" alt="image" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/1a06ced1-8e49-4438-b23f-2e62889e0a4a">

<img width="616" alt="image" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/67e797c6-2da5-4ba3-81c3-71918dae1e8a">

<img width="616" alt="image" src="https://github.com/TeamMeloMeter/MeloMeter/assets/111224287/d4e80684-6266-438a-b690-0185ea0c00fa">

### 📌 주요 기능

---

- **사용자 인증**
    
    전화번호 인증을 통해 서비스를 사용할 수 있습니다.
    
    앱 서비스에 필요한 정보를 받습니다.
    
    [추가 정보]
    
    이름, 생년월일, 프로필 사진
    
- **커플 등록**
    
    사용자에게 발급되는 커플 등록 코드로 상대방과 커플 등록을 할 수 있습니다.
    
    커플 등록 코드는 고유하며 24시간의 유효기간을 갖습니다.
    
    한 쪽 기기에서 커플 등록 시 상대방 기기에서 커플 등록이 동기화됩니다.
    
- **위치 공유**
    
     기본 기능 
    
    지도에서 서로의 위치를 실시간 확인할 수 있습니다. 
    
    - 사용자의 위치는 일정 주기를 간격으로 서버에 전송됩니다.
    - 일정 주기를 간격으로 서버에 상대방의 위치 정보를 요청합니다.
    
     추가 예정 기능 
    
    - 연결된 사용자의 이동 경로를 확인할 수 있습니다.
    - 즐겨찾기 장소를 등록하고, 연결된 사용자의 진입과 이탈을 확인할 수 있습니다.
    
- **채팅**
    
     기본 기능  
    
    서로 텍스트를 실시간으로 주고받을 수 있습니다.
    
    - 상단에 공지 형식으로 하루 1번 백문 백답 질문을 받아볼 수 있습니다.
    
     추가 예정 기능
    
    - 귀엽고 특별한 이모티콘을 사용할 수 있습니다.
   
    
- **백문 백답**
    
     기본 기능  
    
    커플들에게 공통된 질문을 하루에 1개씩 제공합니다.
    
    - 질문지 데이터는 서버에 저장됩니다.
    - 커플 2명 모두 답변을 해야 다음 질문에 답변할 수 있습니다.
    답변하지 않은 질문 이후 날짜의 질문은 2개까지 누적됩니다.
    
- **디데이**
    
     기본 기능 
    
    커플의 기념일을 설정하고 기념일로부터 몇 일이 경과하였는지 디데이를 표기합니다.
    
    그 외 특별한 기념일을 추가할 수 있고, 날짜를 자동으로 계산하여 제공합니다.
    
- **푸쉬 알림**
    
     기본 기능 
    
    백문 백답 질문 제공 알림
    
    디데이 기념일 미리 알림
    
    추가 예정 기능 
    
    위치 공유의 즐겨찾기 장소 진입, 이탈 시 알림
    


