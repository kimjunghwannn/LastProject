import SwiftUI

struct OneRoomView: View {
    var room: OneRoom
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(room.name)
                .font(.headline)
            Text(room.dong)
            Text(room.jibun)
            Text(formatRent(room.mothly_rent))
        }
    }
    
    private func formatRent(_ rent: Int) -> String {
        if rent == 0 {
            return "전세"
        } else {
            return "\(rent) 만원"
        }
    }
}

// 뷰를 사용하는 예시
struct ContentView: View {
    @ObservedObject private var viewModel = OneRoomViewModel()
    var text: String // ContentView에 추가된 매개변수
    var dismissAction: (() -> Void)? // ViewController로 돌아가는 액션 클로저
    init(text: String, dismissAction: @escaping (() -> Void)) {
           self.text = text
           self.dismissAction = dismissAction // 클로저 설정
       }

    // 매개변수에 해당하는 지역 이름과 코드를 저장하는 딕셔너리
      let regionMap: [String: String] = [
          "종로구": "11110",
          "중구": "11140",
          "용산구": "11170",
          "성동구": "11200",
          "광진구": "11215",
          "동대문구": "11230",
          "중랑구": "11260",
          "성북구": "11290",
          "강북구": "11305",
          "도봉구": "11320",
          "노원구": "11350",
          "은평구": "11380",
          "서대문구": "11410",
          "마포구": "11440",
          "양천구": "11470",
          "강서구": "11500",
          "구로구": "11530",
          "금천구": "11545",
          "영등포구": "11560",
          "동작구": "11590",
          "관악구": "11620",
          "서초구": "11650",
          "강남구": "11680",
          "송파구": "11710",
          "강동구": "11740"
      ]
      var body: some View {
          let lawdCd = regionMap[text] ?? ""
          VStack {
                  // 버튼 추가
                  Button("Return to Map") {
                      dismissAction?()
                  }
                  
                  // 리스트 추가
                  List(viewModel.rooms) { room in
                      OneRoomView(room: room)
                  }
                  .onAppear {
                      viewModel.fetchRooms(lawdCd: lawdCd)
                  }
              }
    }
}
