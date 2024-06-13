import SwiftUI

struct OneRoomView: View {
    var room: OneRoom

    var body: some View {
        VStack(alignment: .leading) {
            Text(room.name)
                .font(.headline)
            Text(room.dong)
            Text(room.jibun)
            Text("\(room.mothly_rent) 원")
        }
    }
}

// 뷰를 사용하는 예시
struct ContentView: View {
    @ObservedObject private var viewModel = OneRoomViewModel()

    var body: some View {
        List(viewModel.rooms) { room in
            OneRoomView(room: room)
        }
        .onAppear {
            viewModel.fetchRooms()
        }
    }
}
