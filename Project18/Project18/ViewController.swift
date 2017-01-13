//
//  ViewController.swift
//  Project18
//
//  Created by Stuart Terrett on 1/12/17.
//  Copyright © 2017 Stuart Terrett. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    dynamic var temperatureF: Double = 64
    dynamic var temperatureC: Double = 18 {
        didSet {
            updateFahrenheit()
        }
    }

    dynamic var icon: String {
        switch temperatureC {
        case let temp where temp < 0:
            return "⛄"
        case 0...10:
            return "❄️"
        case 10...20:
            return "☁️"
        case 20...30:
            return "🌤"
        case 30...40:
            return "☀️"
        case 40...50:
            return "🔥"
        default:
            return "💀"
        }
    }

    class func keyPathsForValuesAffectingIcon() -> Set<String> {
        return Set(["temperatureC"])
    }


    @IBAction func reset(_ sender: NSButton) {
        temperatureC = -40
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        updateFahrenheit()
    }

    override func setNilValueForKey(_ key: String) {
        if key == "temperatureC" {
            temperatureC = 0
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func updateFahrenheit() {
        let celsius = Measurement(value: temperatureC, unit: UnitTemperature.celsius)
        temperatureF = round(celsius.converted(to: UnitTemperature.fahrenheit).value)

    }
}

