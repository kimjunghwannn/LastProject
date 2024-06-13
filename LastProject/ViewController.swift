import UIKit
import MapKit
import SwiftUI

class ViewController: UIViewController , UITextViewDelegate{
    var mapView: MKMapView!
    var contentView: UIHostingController<ContentView>?
    var button: UIButton!
    var textView: UITextView!
    let placeholder = "구검색 예: 강동구"
    @ObservedObject private var viewModel = OneRoomViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()        // 지도를 생성합니다.
        mapView = MKMapView(frame: view.bounds)
        
       
        
        
        
        
        // 지도의 표시 영역을 설정합니다. (한국 기준)
        let initialLocation = CLLocation(latitude: 37.5665, longitude: 126.9780)
        let regionRadius: CLLocationDistance = 10000 // 10km 반경
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        // 현재 위치 표시를 활성화합니다.
        mapView.showsUserLocation = true
        
        // 지도를 화면에 추가합니다.
        view.addSubview(mapView)
        view.addSubview(button)
        view.addSubview(textView)
        // 지도의 delegate를 설정합니다.
        mapView.delegate = self
    }
    func setupButton() {
            // 버튼 생성
            button = UIButton(type: .system)
            button.setTitle("해당 구에 원룸 보기", for: .normal)
            button.addTarget(self, action: #selector(showContentView), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            // 텍스트뷰 생성
            textView = UITextView()
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
        let startLatitude = mapView.region.center.latitude - mapView.region.span.latitudeDelta / 2
        let endLatitude = mapView.region.center.latitude + mapView.region.span.latitudeDelta / 2
        let centerCoordinate = mapView.region.center.longitude
        let startCoordinate = centerCoordinate - mapView.region.span.longitudeDelta / 2
        let endCoordinate = centerCoordinate + mapView.region.span.longitudeDelta / 2
        print("Center Latitude: \(centerLatitude), Start Latitude: \(startLatitude), End Latitude: \(endLatitude), Cor: \(startCoordinate)  \(endCoordinate)")
        viewModel.fetchRooms(lawdCd: "11110")
        addMarkersForRooms()
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


