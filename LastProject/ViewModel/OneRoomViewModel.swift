//
//  OneRoomViewModel.swift
//  LastProject
//
//  Created by mac040 on 6/13/24.
//

import Foundation
import Combine
import SWXMLHash
class OneRoomViewModel: ObservableObject {
    @Published var rooms: [OneRoom] = []
    private var cancellables = Set<AnyCancellable>()
    static let shared = OneRoomViewModel()
    func fetchRooms(lawdCd: String){
        let apiUrl = "http://openapi.molit.go.kr:8081/OpenAPI_ToolInstallPackage/service/rest/RTMSOBJSvc/getRTMSDataSvcRHRent"
        let serviceKey = "OFnJLWtAPRyGRjRKBV%2FKNzwcpO20mUhwbUsVZrALLP%2FXOHQxpztDN0womM7gXTn9XPFHkLB%2BYMZBWxoQLN9CKA%3D%3D"
        let dealYmd = "201512" // 예시로 DEAL_YMD 값을 넣습니다.
        
        let queryParams = "?serviceKey=\(serviceKey)&LAWD_CD=\(lawdCd)&DEAL_YMD=\(dealYmd)"
        
        guard let url = URL(string: apiUrl + queryParams) else {
            print("Invalid URL")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for errors
            if let error = error {
                print("Network request error: \(error)")
                return
            }

            // Check if data is available
            guard let data = data else {
                print("No data received")
                return
            }

            // Decode XML data into ApiResponse
            do {
                let xml = XMLHash.parse(data)
                let apiResponse = try xml["response"]["body"]["items"]["item"].all.map { item -> OneRoom in
                    return OneRoom(
                        id: UUID().uuidString,
                        jibun: item["지번"].element?.text ?? "",
                        mothly_rent: Int(item["월세금액"].element?.text ?? "") ?? 0,
                        name: item["연립다세대"].element?.text ?? "",
                        dong: item["법정동"].element?.text ?? ""
                    )
                }

                // Handle successfully decoded response
                self.rooms = apiResponse
            } catch {
                print("Error parsing XML: \(error)")
            }
        }.resume()
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
