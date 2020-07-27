//
//  MapViewController.swift
//  Landmark
//
//  Created by Tantia, Himanshu on 26/7/20.
//  Copyright © 2020 Himanshu Tantia. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    public var notes = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAnnotations()
        mapView.setUserTrackingMode(.follow, animated: true)
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
