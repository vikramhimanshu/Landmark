//
//  DetailViewController.swift
//  Landmark
//
//  Created by Tantia, Himanshu on 23/7/20.
//  Copyright © 2020 Himanshu Tantia. All rights reserved.
//

import UIKit
import MapKit

private extension MKMapView {
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

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var usernameLabel: UILabel!
    

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.body
            }
            if let label = usernameLabel {
                label.text = "User: " + detail.username
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
        addAnnotations()
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    func addAnnotations() {
        guard let note = detailItem else {
            return
        }
        if note.cordinates != nil {
            let noteAnnotation = NoteAnnotation(withNote: note)
            mapView.addAnnotation(noteAnnotation)
            mapView.setCenter(noteAnnotation.coordinate, animated: true)
            mapView.centerToCoordinate(noteAnnotation.coordinate)
        }
    }
    
    

    var detailItem: Note? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

