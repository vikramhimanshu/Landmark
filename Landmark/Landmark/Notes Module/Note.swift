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
    
    var displayTitle : String {
        let count = body.count
        let charsToDrop = Double(count) * 0.9
        let str = String(self.body.dropLast(Int(charsToDrop))) + "..." + String(self.body.dropFirst(Int(charsToDrop)))
        return str
    }
    
    
    var cordinates: CLLocationCoordinate2D? {
        guard let lat = latitude, let long = longitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}

class NoteAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var info: String
    
    init(withNote note: Note) {
        coordinate = note.cordinates!
        self.title = note.displayTitle
        self.info = note.body
    }
}
