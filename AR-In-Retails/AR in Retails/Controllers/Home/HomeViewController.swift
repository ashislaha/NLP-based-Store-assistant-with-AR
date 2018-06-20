//
//  HomeViewController.swift
//  AR in Retails
//
//  Created by Ashis Laha on 6/14/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation
import GoogleMaps

let defaultZoomLabel : Float = 19.0

class HomeViewController: UIViewController {
    
    private var mapView : GMSMapView!
    private var isUserInsideStore = false
    private let storeModel = StoreModel.shared
    private var mapPath: [GMSPath] = []
    
    lazy var proceedView: ProceedView = {
        let view = ProceedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10.0
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.green.cgColor
        view.layer.borderWidth = 1.0
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Finding You"
    }
    
    private func addProceedView() {
        guard let mapView = mapView else { return }
        mapView.addSubview(proceedView)
        proceedView.delegate = self
        
        NSLayoutConstraint.activate([
            proceedView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 16),
            proceedView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            proceedView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -16),
            proceedView.heightAnchor.constraint(equalToConstant: 100)
            ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate  as? AppDelegate else { return }
        appDelegate.locationManager.delegate = self
        appDelegate.locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let appDelegate = UIApplication.shared.delegate  as? AppDelegate else { return }
        appDelegate.locationManager.stopUpdatingLocation()
    }
}

extension HomeViewController: ProceedTappedProtocol {
    func proceedTapped() {
        isUserInsideStore ? initialiseStoreMapViewController(): initialiseChatViewController()
    }
    
    private func initialiseStoreMapViewController() {
        guard let storeMapVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoreViewController") as? StoreViewController else { return }
        navigationController?.pushViewController(storeMapVC, animated: true)
    }
    
    private func initialiseChatViewController() {
        guard let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else { return }
        navigationController?.pushViewController(chatVC, animated: true)
        chatVC.isUserInsideStore = false
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if mapView == nil {
            handleGoogleMap()
            drawBoundary()
        }
        
        isUserInsideStore = isUserInsideStores(userLocation: locations.last)
        isUserInsideStore ? proceedView.updateText("You are inside the Store"): proceedView.updateText("You are not inside the store")
    }
    
    // MARK: Draw Boundary
    
    private func drawBoundary() {
        mapPath = []
        storeModel.storesBoundary.forEach { (key, value) in
            drawPath(map: mapView, pathArray: value)
        }
    }
    
    private func drawPath(map : GMSMapView, pathArray : [(Double, Double)]) {
        guard !pathArray.isEmpty else { return }
        
        let path = GMSMutablePath()
        for each in pathArray {
            path.add(CLLocationCoordinate2D(latitude: each.0, longitude: each.1))
        }
        path.add(CLLocationCoordinate2D(latitude: pathArray.first!.0, longitude: pathArray.first!.1))
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.blue
        polyline.strokeWidth = 1.0
        polyline.geodesic = true
        polyline.map = map
        mapPath.append(path)
    }
    
    // MARK: Is user inside the boundary
    
    private func isUserInsideStores(userLocation: CLLocation?) -> Bool {
        guard !mapPath.isEmpty, let userCoordinate = userLocation?.coordinate else { return false }
        var isInsideStore = false
        for path in mapPath {
            isInsideStore = isInsideStore || GMSGeometryContainsLocation(userCoordinate, path, true)
            if isInsideStore { break }
        }
        return isInsideStore
    }
    
    // MARK: location manager Delegates
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            // If authorized when in use
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            // If always authorized
            manager.startUpdatingLocation()
            break
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // If user denied your app access to Location Services, but can grant access from Settings.app
            break
        }
    }
    
    private func handleGoogleMap() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if let userLocation = appDelegate.locationManager.location?.coordinate {
            self.googleMapSetUp(location: userLocation)
        }
    }
    
    private func googleMapSetUp(location : CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: defaultZoomLabel)
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        mapView.isUserInteractionEnabled = true
        mapView.isMyLocationEnabled = true
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(mapView)
        addProceedView()
    }
}

