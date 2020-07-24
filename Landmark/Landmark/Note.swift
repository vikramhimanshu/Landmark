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
    let text: String
    let username: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
}

extension Note {
    var cordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
