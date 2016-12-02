//
//  ViewController.swift
//  Project5
//
//  Created by Stuart Terrett on 11/30/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa
import MapKit

class ViewController: NSViewController, MKMapViewDelegate {

    @IBOutlet var questionLabel: NSTextField!
    @IBOutlet var scoreLabel: NSTextField!
    @IBOutlet var mapView: MKMapView!
    
    var cities = [Pin]()
    var currentCity: Pin?
    
    var score = 0 {
        didSet {
            scoreLabel.stringValue = "Score: \(score)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(mapClicked))
        mapView.addGestureRecognizer(recognizer)
        
        startNewGame()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func mapClicked(recognizer: NSClickGestureRecognizer) {
        guard (currentCity != nil) else { return }
        if mapView.annotations.count == 0 {
            let location = recognizer.location(in: mapView)
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
            let turnScore = calculateScore(guessed: coordinates)
            addPins(at: coordinates, score: turnScore)
            score += turnScore
        } else {
            mapView.removeAnnotations(mapView.annotations)
            nextCity()
        }

    }

    func addPins(at coord: CLLocationCoordinate2D, score: Int) {
        guard let actual = currentCity else { return }
        actual.subtitle = "You scored \(score)"
        let guess = Pin(title: "Your guess", coordinate: coord, color: NSColor.red)
        mapView.addAnnotation(guess)
        mapView.addAnnotation(actual)
        mapView.selectAnnotation(actual, animated: true)
    }
    
    func calculateScore(guessed coords: CLLocationCoordinate2D) -> Int {
        let guessPoint = MKMapPointForCoordinate(coords)
        let actualPoint = MKMapPointForCoordinate(currentCity!.coordinate)
        return Int(max(0, 500 - (MKMetersBetweenMapPoints(guessPoint, actualPoint) / 1000)))
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let pin = annotation as? Pin else { return nil }
        let identifier = "guess"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView!.annotation = annotation
        }
        
        annotationView?.canShowCallout = true
        annotationView?.pinTintColor = pin.color
        
        return annotationView
    }
    
    func startNewGame() {
        cities.append(Pin(title: "London", coordinate:
            CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)))
        cities.append(Pin(title: "Oslo", coordinate:
            CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75)))
        cities.append(Pin(title: "Paris", coordinate:
            CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508)))
        cities.append(Pin(title: "Rome", coordinate:
            CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5)))
        cities.append(Pin(title: "Washington DC", coordinate:
            CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667)))
        
        nextCity()
    }
    
    func nextCity() {
        if let city = cities.popLast() {
            currentCity = city
            questionLabel.stringValue = "Where is \(city.title!)"
        } else {
            let alert = NSAlert()
            alert.messageText = "Final Score: \(score)"
            alert.runModal()
            
            startNewGame()
        }
    }
}

