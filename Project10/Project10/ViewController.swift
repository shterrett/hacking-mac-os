//
//  ViewController.swift
//  Project10
//
//  Created by Stuart Terrett on 12/15/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa
import MapKit

class ViewController: NSViewController {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var apiKey: NSTextField!
    @IBOutlet var statusBarOption: NSPopUpButton!
    @IBOutlet var units: NSSegmentedControl!

    @IBAction func showPoweredBy(_ sender: NSButton) {
        NSWorkspace.shared().open(URL(string: "https://darksky.net/poweredby")!)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        let defaults = UserDefaults.standard

        if let mapPin = mapView.annotations.first {
            defaults.set(mapPin.coordinate.latitude, forKey: "latitude")
            defaults.set(mapPin.coordinate.longitude, forKey: "longitude")
        }

        defaults.set(apiKey.stringValue, forKey: "apiKey")
        defaults.set(units.selectedSegment, forKey: "units")

        if let selectedStatus = (statusBarOption.menu!.items.filter() {
                $0.state == NSOnState
            }.first) {
            defaults.set(selectedStatus.tag, forKey: "statusBar")
        }

        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("SettingsChanged"), object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let userDefaults = UserDefaults.standard
        let latitude = userDefaults.double(forKey: "latitude")
        let longitude = userDefaults.double(forKey: "longitude")
        let savedApiKey = userDefaults.string(forKey: "apiKey") ?? ""
        let savedStatusBar = userDefaults.integer(forKey: "statusBar")
        let savedUnits = userDefaults.integer(forKey: "units")

        apiKey.stringValue = savedApiKey
        units.selectedSegment = savedUnits

        if let selectedOption = (statusBarOption.menu!.items.filter() {
            $0.tag == savedStatusBar
            }.first) {
            statusBarOption.select(selectedOption)
        }

        let savedLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        addPin(at: savedLocation)
        mapView.centerCoordinate = savedLocation

        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(mapTapped))
        mapView.addGestureRecognizer(recognizer)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func addPin(at coordinates: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = "Your Location"
        mapView.addAnnotation(annotation)
    }

    func mapTapped(recognizer: NSGestureRecognizer) {
        mapView.removeAnnotations(mapView.annotations)
        let location = recognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        addPin(at: coordinate)
    }
}

