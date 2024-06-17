import UIKit
import MapKit
import SwiftUI

class ViewController: UIViewController , UITextViewDelegate{
    var mapView: MKMapView!
    var contentView: UIHostingController<ContentView>?
    var button: UIButton!
    var textView: UITextView!
    var textViewLa: UITextView!
    var textViewS: UITextView!
    let placeholder = "구검색 예: 강동구"
    @ObservedObject private var viewModel = OneRoomViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapKitView()
        setupTextView()
        setupSerachTextView()
        setupButton()
    }
    func setupMapKitView() {
            mapView = MKMapView()
            mapView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(mapView)
            NSLayoutConstraint.activate([
                mapView.topAnchor.constraint(equalTo: view.topAnchor),
                mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5) // 화면 상단 절반 차지
            ])
            
            let initialLocation = CLLocation(latitude: 37.5665, longitude: 126.9780)
            let regionRadius: CLLocationDistance = 10000
            let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate,
                                                      latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
            mapView.showsUserLocation = true
            mapView.delegate = self
        }
    func setupTextView() {
        textViewLa = UITextView()
        textViewLa.translatesAutoresizingMaskIntoConstraints = false
           textViewLa.isEditable = false
    textViewLa.textColor = .black
           textViewLa.textAlignment = .center
           textViewLa.font = UIFont.systemFont(ofSize: 16)
    textViewLa.text = "위도와 경도값이 나옵니다." // 초기 값 설정
           
           view.addSubview(textViewLa)
           NSLayoutConstraint.activate([
               textViewLa.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20), // MapKit 뷰 아래에 위치
               textViewLa.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
               textViewLa.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
               textViewLa.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
           ])
       }
    func setupSerachTextView() {
           textViewS = UITextView()
           textViewS.translatesAutoresizingMaskIntoConstraints = false
           textViewS.delegate = self
           textViewS.textColor = .black
        textViewS.backgroundColor = .gray
           textViewS.textAlignment = .center
           textViewS.font = UIFont.systemFont(ofSize: 16)
           textViewS.text = placeholder
           
           view.addSubview(textViewS)
           NSLayoutConstraint.activate([
               textViewS.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 100), // MapKit 뷰 아래에 위치
               textViewS.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
               textViewS.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
               textViewS.heightAnchor.constraint(equalToConstant: 40)
           ])
        
        let searchButton = UIButton(type: .system)
          searchButton.setTitle("해당 구에 원룸 지도에 띄우기", for: .normal)
          searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
          searchButton.translatesAutoresizingMaskIntoConstraints = false
          
          view.addSubview(searchButton)
          NSLayoutConstraint.activate([
              searchButton.topAnchor.constraint(equalTo: textViewS.bottomAnchor, constant: 20),
              searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              searchButton.widthAnchor.constraint(equalToConstant: 240),
              searchButton.heightAnchor.constraint(equalToConstant: 40)
          ])       }
    @objc func searchButtonTapped() {
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
        let lawdCd = regionMap[textViewS.text] ?? ""
        viewModel.fetchRooms(lawdCd:lawdCd)
        addMarkersForRooms()
    }
    
    
        func setupButton() {
            // 버튼 생성
            button = UIButton(type: .system)
            button.setTitle("해당 구에 원룸 보기", for: .normal)
            button.addTarget(self, action: #selector(showContentView), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            // 텍스트뷰 생성
            textView = UITextView()
            textView.backgroundColor = .gray
            textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self // UITextViewDelegate 설정
               textView.text = placeholder // 플레이스홀더 텍스트 설정
        view.addSubview(button)
        view.addSubview(textView)
        NSLayoutConstraint.activate([
               button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20), // 아래로 이동
               textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               textView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -20), // 버튼 위에 위치하도록 설정
               textView.widthAnchor.constraint(equalTo: button.widthAnchor),
               textView.heightAnchor.constraint(equalTo: button.heightAnchor)
           ])
        }
    func textViewDidBeginEditing(_ textView: UITextView) {
          if textView.text == placeholder {
              textView.text = "" // 사용자가 입력하기 시작하면 플레이스홀더 텍스트 제거
              textView.textColor = UIColor.black // 사용자가 입력하기 시작하면 텍스트 색상 변경
          }
      }
      
      func textViewDidEndEditing(_ textView: UITextView) {
          if textView.text.isEmpty {
              textView.text = placeholder // 사용자가 입력을 마치면 플레이스홀더 텍스트 표시
              textView.textColor = UIColor.lightGray // 플레이스홀더 텍스트 색상 변경
          }
      }
    @objc func showContentView() {
        if contentView == nil {
            let contentView = ContentView(text: textView.text, dismissAction: { 
                self.contentView?.willMove(toParent: nil)
                self.contentView?.view.removeFromSuperview()
                self.contentView?.removeFromParent()
                self.contentView = nil
            })
            let hostingController = UIHostingController(rootView: contentView)
            addChild(hostingController)
            hostingController.view.frame = view.bounds
            view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
            self.contentView = hostingController
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // 지도가 이동할 때마다 중앙과 시작, 끝 지점의 위도를 출력합니다.
        printCenterAndStartEndLatitude(mapView)
    }
    
    func printCenterAndStartEndLatitude(_ mapView: MKMapView) {
        let centerLatitude = mapView.region.center.latitude
        let centerCoordinate = mapView.region.center.longitude
        // 위도와 경도 값을 텍스트뷰에 표시
          let latitudeText = String(format: "위도: %.6f", centerLatitude)
          let longitudeText = String(format: "경도: %.6f", centerCoordinate)
          textViewLa.text = "\(latitudeText)\n\(longitudeText)"
        
       
    }
    func addMarkersForRooms() {
        let geocoder = CLGeocoder()
        
        // DispatchGroup 생성
        let dispatchGroup = DispatchGroup()
        
        for room in viewModel.rooms {
            let address = "\(room.dong) \(room.jibun)"
            print(address)
            // DispatchGroup에 진입
            dispatchGroup.enter()
            
            geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
                guard let self = self else { return }
                defer {
                    // DispatchGroup에서 나옴
                    dispatchGroup.leave()
                }
                
                guard let placemark = placemarks?.first, let location = placemark.location else {
                    print("Location not found for address: \(address)")
                    return
                }
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                annotation.title = room.name
                annotation.subtitle = "Monthly Rent: \(room.mothly_rent) 만원"
                
                // DispatchQueue.main에서 지도 업데이트
                DispatchQueue.main.async {
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
        
        // 모든 비동기 작업 완료를 기다림
        dispatchGroup.notify(queue: .main) {
            // 모든 주소 출력
            for room in self.viewModel.rooms {
                let address = "\(room.dong) \(room.jibun)"
                print(address)
            }
            print("All annotations added")
        }
    }
}


