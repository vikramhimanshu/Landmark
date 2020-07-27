//
//  MapViewController.swift
//  Landmark
//
//  Created by Tantia, Himanshu on 26/7/20.
//  Copyright © 2020 Himanshu Tantia. All rights reserved.
//

import UIKit
import MapKit

public extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
    
    func centerToCoordinate(_ coordinate: CLLocationCoordinate2D, radius:CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: coordinate,
                                                  latitudinalMeters: radius,
                                                  longitudinalMeters: radius)
        setRegion(coordinateRegion, animated: true)
    }
}

class MapViewController: UIViewController {
    
    public var notes = [Note]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var locationManager = LocationManager()
    private var errorViewPresenter: ErrorViewPresenter?
    
    @IBAction func doneButtonAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorViewPresenter = ErrorViewPresenter(withController: self)
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        addAnnotations()
        locationManager.requestAuthorizationIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.requestLocation { res in
            switch res {
            case .success(let locs):
                if let loc = locs.last {
                    self.mapView.setCenter(loc.coordinate, animated: true)
                    self.mapView.centerToLocation(loc)
                }
            case .failure(let err):
                switch err {
                case .denied(let err):
                    self.errorViewPresenter?.showAlterView(withViewModel: err)
                case .fail(let err):
                    self.errorViewPresenter?.showAlterView(withViewModel: err)
                case .needsAuthorization:
                    self.locationManager.requestAuthorizationIfNeeded()
                case .restricted(let err):
                    self.errorViewPresenter?.showAlterView(withViewModel: err)
                case .unavailable(let err):
                    self.errorViewPresenter?.showAlterView(withViewModel: err)
                case .unknown(let err):
                    self.errorViewPresenter?.showAlterView(withViewModel: err)
                }
            }
        }
    }
    
    func addAnnotations() {
        var annotations = [NoteAnnotation]()
        
        for n in notes {
            if n.cordinates == nil {
                continue
            }
            let noteAnnotation = NoteAnnotation(withNote: n)
            annotations.append(noteAnnotation)
        }
        mapView.addAnnotations(annotations)
    }
}
