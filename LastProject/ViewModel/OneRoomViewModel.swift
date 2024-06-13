//
//  OneRoomViewModel.swift
//  LastProject
//
//  Created by mac040 on 6/13/24.
//

import Foundation
import Combine
class OneRoomViewModel: ObservableObject {
    @Published var rooms: [OneRoom] = []
    private var cancellables = Set<AnyCancellable>()
    
    func fetchRooms() {
        let apiUrl = "http://openapi.molit.go.kr:8081/OpenAPI_ToolInstallPackage/service/rest/RTMSOBJSvc/getRTMSDataSvcRHRent"
        let serviceKey = "OFnJLWtAPRyGRjRKBV%2FKNzwcpO20mUhwbUsVZrALLP%2FXOHQxpztDN0womM7gXTn9XPFHkLB%2BYMZBWxoQLN9CKA%3D%3D"
        let lawdCd = "11110" // 예시로 LAWD_CD 값을 넣습니다.
        let dealYmd = "201512" // 예시로 DEAL_YMD 값을 넣습니다.
        
        let queryParams = "?serviceKey=\(serviceKey)&LAWD_CD=\(lawdCd)&DEAL_YMD=\(dealYmd)"
        
        guard let url = URL(string: apiUrl + queryParams) else {
            print("Invalid URL")
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .tryMap { data in
                do {
                    let decoder = XMLDecoder()
                    let response = try decoder.decode(ApiResponse.self, from: data)
                    return response
                } catch {
                    throw error
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching data: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { response in
                self.rooms = response.items.map {
                    OneRoom(id: UUID().uuidString, jibun: $0.jibun, mothly_rent: Int($0.monthlyRent) ?? 0, name: $0.name, dong: $0.dong)
                }
            })
            .store(in: &cancellables)
    }
}

struct ApiResponse: Codable {
    let items: [ApiItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "response.body.items.item"
    }
}

struct ApiItem: Codable {
    let jibun: String
    let monthlyRent: String
    let name: String
    let dong: String
    
    enum CodingKeys: String, CodingKey {
        case jibun = "jibun"
        case monthlyRent = "월세"
        case name = "이름"
        case dong = "동"
    }
}
