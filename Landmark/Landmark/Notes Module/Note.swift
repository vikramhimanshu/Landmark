//
//  Note.swift
//  Landmark
//
//  Created by Tantia, Himanshu on 23/7/20.
//  Copyright © 2020 Himanshu Tantia. All rights reserved.
//

import Foundation
import MapKit

struct Note : Codable {
    let timestamp: String
    let body: String
    let username: String
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
}

extension Note {
    var cordinates: CLLocationCoordinate2D? {
        guard let lat = latitude, let long = longitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}
