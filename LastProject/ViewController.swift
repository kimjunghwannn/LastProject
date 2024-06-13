import UIKit
import MapKit
import SwiftUI
class ViewController: UIViewController {
    var mapView: MKMapView!
    var contentView: UIHostingController<ContentView>?
    var button: UIButton!
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
        view.addSubview(button)        // 지도의 delegate를 설정합니다.
        mapView.delegate = self
    }
    func setupButton() {
        // 버튼 생성
        button = UIButton(type: .system)
        button.setTitle("Show ContentView", for: .normal)
        button.addTarget(self, action: #selector(showContentView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        // 버튼을 뷰에 추가
            view.addSubview(button)
                    // 버튼의 레이아웃 제약 설정
        NSLayoutConstraint.activate([
               button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100) // 수직으로 view의 가운데에서 100포인트 아래에 위치
           ])
    }
    
    @objc func showContentView() {
        // 버튼이 탭되었을 때 ContentView를 생성하고 화면에 추가합니다.
        if contentView == nil {
                let hostingController = UIHostingController(rootView: ContentView())
                addChild(hostingController)
                hostingController.view.frame = view.bounds
                view.addSubview(hostingController.view)
                hostingController.didMove(toParent: self)
                contentView = hostingController
            }   }
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
    }
}
