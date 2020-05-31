//
//    MapViewControllerExtension.swift
//     RecycleProject
//

import Foundation
import YandexMapKit
import CoreLocation
import FloatingPanel

//MARK: - Location manager delegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.first != nil else {
            return
        }
        setupMapFocus()
        locationManager.stopUpdatingLocation()
    }
}

//MARK: - Work with Yandex MapKit

extension MapViewController: YMKUserLocationObjectListener, YMKMapObjectTapListener {
    internal func addStationsOnMap() {
        mapObjects.clear()
        for station in stations {
            let pointCoordinate = YMKPoint(latitude: station.value.location.latitude,
                                           longitude: station.value.location.longitude)
            
            let viewRect = CGRect(x: station.value.location.latitude, y: station.value.location.longitude, width: 30, height: 30)
            let view = PlacemarkView(frame: viewRect)
            view.setSegmentedCircle(colors: station.value.colors)
            guard let placemarkImage = view.convertToImage() else { return }
            mapObjects
                .addPlacemark(with: pointCoordinate, image: placemarkImage)
                .addTapListener(with: placemarkTapListener)
        }
    }
    
    internal func configureUserLocation() {
        userLocation = mapkit.createUserLocationLayer(with: mapView.mapWindow)
        userLocation.setVisibleWithOn(true)
        userLocation.setObjectListenerWith(self)
    }
    
    func setupMapFocus() {
        var focusPoint = YMKPoint()
        if let userCoordinate = locationManager.location?.coordinate {
            focusPoint = YMKPoint(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        } else {
            focusPoint = YMKPoint(latitude: 59.950749, longitude: 30.316751) // city coordinates
        }
        mapView.mapWindow.map.move(with: YMKCameraPosition(target: focusPoint, zoom: 12, azimuth: 0, tilt: 0))
    }
        
    func onObjectAdded(with view: YMKUserLocationView) {
        view.arrow.setIconWith(UIImage(named: "userLocation")!)
        let pinPlacemark = view.pin
        pinPlacemark.setIconWith(UIImage(named: "userLocation")!)
        view.accuracyCircle.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    }
    
    func onObjectRemoved(with view: YMKUserLocationView) {}
    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {}
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let placemark = mapObject as? YMKPlacemarkMapObject else { return false }
        let geometry = placemark.geometry
        let currentCoordinate = CLLocationCoordinate2D(latitude: geometry.latitude, longitude: geometry.longitude)
        guard let currentStation = stations[currentCoordinate] else { return false }
        fillFloatingPanel(with: currentStation)
        return true
    }
}

//MARK: - Work with Floating Panel

extension MapViewController: FloatingPanelControllerDelegate {
    
    func fillFloatingPanel(with recycleStation: RecycleStation) {
        contentVC.configureView(with: recycleStation)
        if self.presentedViewController == nil {
            // Present over tab bar
//             self.present(recycleStationVC, animated: true, completion: nil)
            // Present behind tab bar
            recycleStationVC.addPanel(toParent: self, animated: true)
        }
    }
    
    func configureFloatingPanel() {
        recycleStationVC = FloatingPanelController()
        contentVC = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "RecycleStationVC") as? RecycleStationViewController
        
        recycleStationVC.surfaceView.cornerRadius = 15
        recycleStationVC.surfaceView.grabberHandle.isHidden = true
        
        recycleStationVC.set(contentViewController: contentVC)
        recycleStationVC.isRemovalInteractionEnabled = true
    }
}