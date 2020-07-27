//
//  LocationManager.swift
//  Landmark
//
//  Created by Tantia, Himanshu on 27/7/20.
//  Copyright © 2020 Himanshu Tantia. All rights reserved.
//

import Foundation
import MapKit

class LocationManager: NSObject {
    
    enum Accuracy : CLLocationAccuracy {
        case kCLLocationAccuracyBestForNavigation
        case kCLLocationAccuracyBest
        case kCLLocationAccuracyNearestTenMeters
        case kCLLocationAccuracyHundredMeters
        case kCLLocationAccuracyKilometer
        case kCLLocationAccuracyThreeKilometers
    }
    
    enum LocationError : Error {
        case denied(ErrorViewEntity)
        case unavailable(ErrorViewEntity)
        case restricted(ErrorViewEntity)
        case fail(ErrorViewEntity)
        case unknown(ErrorViewEntity)
        case needsAuthorization(CLAuthorizationStatus)
    }
    
    private var locationManager: CLLocationManager?
    private var userLocation: CLLocation?
    fileprivate var handler: ((Result<[CLLocation], LocationError>) -> Void)?
    
    private var status : CLAuthorizationStatus
    
    init(withAuthorizationStatus status : CLAuthorizationStatus = .authorizedWhenInUse, accuracy: Accuracy = .kCLLocationAccuracyBest) {
        self.status = status
        super.init()
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = accuracy.rawValue
        locationManager?.delegate = self
    }
    
    public var isLocationServicesAvailable : Bool {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .denied:
                return false
            case .restricted:
                return false
            case .notDetermined:
                return true
            case .authorizedWhenInUse:
                return true
            case .authorizedAlways:
                return true
            default:
                return false
            }
        } else {
            return false
        }
    }
    
    func requestAuthorizationIfNeeded() {
        self.requestAuthorizationIfNeeded(forCLAuthorizationStatus: status)
    }
    
    func requestAuthorizationIfNeeded(forCLAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            locationManager?.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            locationManager?.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func requestLocation(_ handler: @escaping (Result<[CLLocation], LocationError>) -> Void) {
        self.handler = handler
        if isLocationServicesAvailable {
            locationManager?.requestLocation()
        } else {
            let evm = ErrorViewEntity(title: "Location Unavailable", message: "Eiher the location services for this app are denied.\nOr the location services are turned off for the device in Settings.\nOr Location services are unavailable because the device is in Airplane mode.")
            handler(.failure(.unavailable(evm)))
        }
    }
    
    
}

extension LocationManager : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let completion = self.handler else { return }
        
        switch status {
        case .denied:
            let evm = ErrorViewEntity(title: "Location Denied", message: "Eiher the location permissions for this app are denied.\nOr the location services are turned off for the device in Settings.\nOr Location services are unavailable because the device is in Airplane mode.")
            completion(.failure(.denied(evm)))
        case .notDetermined:
            completion(.failure(.needsAuthorization(.notDetermined)))
        case .restricted:
            let evm = ErrorViewEntity(title: "Location Restricted", message: "The app is not authorized to use location services, possibly due to active restrictions such as parental controls being in place.")
            completion(.failure(.restricted(evm)))
        case .authorizedWhenInUse:
            requestLocation(completion)
//            completion(.failure(.needsAuthorization(.authorizedWhenInUse)))
        case .authorizedAlways:
            requestLocation(completion)
//            completion(.failure(.needsAuthorization(.authorizedAlways)))
        default:
            let evm = ErrorViewEntity(title: "Location Unavailable", message: "Users can enable or disable location services by toggling the Location Services switch in Settings > Privacy.")
            completion(.failure(.unknown(evm)))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let evm = ErrorViewEntity(title: "Location Request Failed", message: error.localizedDescription)
        if let completion = self.handler {
            completion(.failure(.fail(evm)))
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = locations.last
        if let completion = self.handler {
            completion(.success(locations))
        }
    }
}
