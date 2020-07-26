//
//  CreateNoteViewController.swift
//  Landmark
//
//  Created by Tantia, Himanshu on 23/7/20.
//  Copyright © 2020 Himanshu Tantia. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseAuth
import FirebaseDatabase

extension CreateNoteViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            fallthrough
        case .restricted:
            self.updateLocationToggleState(.dissable)
        case .notDetermined:
            self.requestLocationAuthorization()
        case .authorizedWhenInUse:
            manager.requestLocation()
            self.requestLocationInformation()
        case .authorizedAlways:
            self.requestLocationInformation()
        @unknown default:
            fatalError("Unknown case exception in locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) -- \(self)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let evm = ErrorViewEntity(title: "Location Request Failed", message: error.localizedDescription)
        DispatchQueue.main.async {
            self.errorViewPresenter?.showAlterView(withViewModel: evm)
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = (locations.last)?.coordinate
    }
}

class CreateNoteViewController: UITableViewController {
    enum LocationServicesState {
        case available
        case availableButNeedsAuthorization
    }
    
    enum LocationServicesError : Error {
        case denied(ErrorViewEntity)
        case unavailable(ErrorViewEntity)
        case restricted(ErrorViewEntity)
        case unknown(ErrorViewEntity)
    }
    
    enum LocationToggle : Int {
        case enable = 0
        case dissable = 1
    }
    
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var locationToggle: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    public var currentUser: User?
    
    private var locationToggleStatus: LocationToggle = .dissable
    private var locationManager: CLLocationManager?
    private var userLocation: CLLocationCoordinate2D?
    private var errorViewPresenter: ErrorViewPresenter?
    
    private var databaseRef: DatabaseReference = Database.database().reference(withPath: "landmark-notes")
    
    override func viewDidLoad() {
        errorViewPresenter = ErrorViewPresenter(withController: self)
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.delegate = self
        updateLocationToggleState(.enable)
        updateLocationToggleView(.enable)
        currentUser = FirebaseAuth.Auth.auth().currentUser
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.canRequestLocationServices { result in
            switch result {
            case .success(let state):
                if state == .availableButNeedsAuthorization {
                    self.locationManager?.requestWhenInUseAuthorization()
                }
            case .failure(let err):
                switch err {
                case .denied(let err):
                    fallthrough
                case .restricted(let err):
                    fallthrough
                case .unavailable(let err):
                    fallthrough
                case .unknown(let err):
                    self.errorViewPresenter?.showAlterView(withViewModel: err)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.requestLocationInformation()
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        
        guard let email = currentUser?.email else {
            return
        }
        
        var note: Note?
        
        switch locationToggleStatus {
        case .enable:
            guard let loc = userLocation else {
                return
            }
            note = Note(timestamp: Date().description, body: textArea.text, username: email, latitude: loc.latitude, longitude: loc.longitude)
        case .dissable:
            note = Note(timestamp: Date().description, body: textArea.text, username: email)
        }

        var json: Any? = nil
        let jsonData = try! JSONEncoder().encode(note)
        do {
            json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
        } catch let error {
            print(error)
        }
        
//        let jsonString = String(data: jsonData, encoding: .utf8)!
//        print(jsonString)

        guard let jsonValue = json else {
            return
        }
        let ref = databaseRef.child(note!.timestamp.description)
        ref.setValue(jsonValue) { (err, dref) in
            if let error = err {
                let evm = ErrorViewEntity(title: "Database Error", message: error.localizedDescription)
                DispatchQueue.main.async {
                    self.errorViewPresenter?.showAlterView(withViewModel: evm)
                }
            } else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        
                    }
                }
            }
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func locationToggleAction(_ sender: UISegmentedControl) {
        guard let s = LocationToggle(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        updateLocationToggleState(s)
    }
    
    private func updateLocationToggleState(_ status: LocationToggle) {
        locationToggleStatus = status
    }
    
    private func updateLocationToggleView(_ selectedIndex: LocationToggle) {
        locationToggle.setEnabled(true, forSegmentAt: selectedIndex.rawValue)
    }
    
    func requestLocationInformation() {
        locationManager?.requestLocation()
    }
    
    func requestLocationAuthorization() {
        self.locationManager?.requestWhenInUseAuthorization()
    }
    
    func clearLocationInformation() {
        
    }
    
    func canRequestLocationServices(handler: @escaping (Result<LocationServicesState, LocationServicesError>) -> Void) {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .denied:
                let evm = ErrorViewEntity(title: "Location Denied", message: "Eiher the location permissions for this app are denied.\nOr the location services are turned off for the device in Settings.\nOr Location services are unavailable because the device is in Airplane mode.")
                handler(.failure(.unavailable(evm)))
            case .notDetermined:
                handler(.success(.availableButNeedsAuthorization))
            case .restricted:
                let evm = ErrorViewEntity(title: "Location Restricted", message: "The app is not authorized to use location services, possibly due to active restrictions such as parental controls being in place.")
                handler(.failure(.unavailable(evm)))
            case .authorizedWhenInUse:
                handler(.success(.available))
            default:
                let evm = ErrorViewEntity(title: "Location Unavailable", message: "Users can enable or disable location services by toggling the Location Services switch in Settings > Privacy.")
                handler(.failure(.unknown(evm)))
            }
        } else {
            let evm = ErrorViewEntity(title: "Location Unavailable", message: "Users can enable or disable location services by toggling the Location Services switch in Settings > Privacy.")
            handler(.failure(.unavailable(evm)))
        }
    }
}
