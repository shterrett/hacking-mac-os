//
//  Pin.swift
//  Project5
//
//  Created by Stuart Terrett on 11/30/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa
import MapKit

class Pin: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var color: NSColor
    
    init(title: String, coordinate: CLLocationCoordinate2D, color: NSColor = NSColor.green) {
        self.title = title
        self.coordinate = coordinate
        self.color = color
    }
    
}
