//
//  MapViewRepresentable.swift
//  LastProject
//
//  Created by mac040 on 6/13/24.
//

import SwiftUI
import UIKit
import MapKit

struct ViewRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }

}
