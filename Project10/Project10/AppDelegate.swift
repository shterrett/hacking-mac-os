//
//  AppDelegate.swift
//  Project10
//
//  Created by Stuart Terrett on 12/15/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa
import Argo
import Curry
import Runes

struct Forecast {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let currentTime: Int
    let summary: String
    let icon: String
    let nearestStormDistance: Float
    let nearestStormBearing: Float
    let precipIntensity: Float
    let precipProbability: Float
    let temperature: Float
    let cloudCover: Float
}

extension Forecast: Decodable {
    public static func decode(_ j: JSON) -> Decoded<Forecast> {
        return curry(Forecast.init)
            <^> j <| "latitude"
            <*> j <| "longitude"
            <*> j <| "timezone"
            <*> j <| ["currently", "time"]
            <*> j <| ["currently", "summary"]
            <*> j <| ["currently", "icon"]
            <*> j <| ["currently", "nearestStormDistance"]
            <*> j <| ["currently", "nearestStormBearing"]
            <*> j <| ["currently", "precipIntensity"]
            <*> j <| ["currently", "precipProbability"]
            <*> j <| ["currently", "temperature"]
            <*> j <| ["currently", "cloudCover"]
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    var currentForecast: Forecast?
    var displayMode = -1
    var updateTimer: Timer?
    var feedTimer: Timer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let defaultSettings = ["latitude": "42.355040",
                               "longitude": "-71.065580",
                               "apiKey": "",
                               "statusBar": "-1",
                               "units": "1"
                               ]
        UserDefaults.standard.register(defaults: defaultSettings)

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(loadSettings), name: Notification.Name("SettingsChanged"), object: nil)

        statusItem.button?.title = "Fetching..."
        statusItem.menu = NSMenu()
        addConfigurationMenuItem()
        loadSettings()
    }

    func updateDisplay() {
        statusItem.button?.title = displayText(mode: displayMode) ?? "Error"
    }

    func displayText(mode: Int) -> String? {
        if let forecast = currentForecast {
            switch mode {
            case 0:
                return forecast.summary
            case 1:
                return "\(forecast.temperature)°"
            case 2:
                return "Rain: \(forecast.precipProbability * 100)%"
            case 3:
                return "Cloud: \(forecast.cloudCover * 100)%"
            default:
                return nil
            }
        } else {
            return nil
        }
    }

    func changeDisplayMode() {
        displayMode = (displayMode + 1) % 4
        updateDisplay()
    }

    func configureUpdateDisplayTimer() {
        let statusBarMode = UserDefaults.standard.integer(forKey: "statusBar")

        if statusBarMode == -1 {
            displayMode = 0
            updateTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(changeDisplayMode), userInfo: nil, repeats: true)
        } else {
            updateTimer?.invalidate()
        }
    }

    func addConfigurationMenuItem() {
        let separator = NSMenuItem(title: "Settings", action: #selector(showSettings), keyEquivalent: "")
        statusItem.menu?.addItem(separator)
    }

    func loadSettings() {
        displayMode = UserDefaults.standard.integer(forKey: "statusBar")
        configureUpdateDisplayTimer()

        feedTimer = Timer.scheduledTimer(timeInterval: 60 * 5, target: self, selector: #selector(fetchFeed), userInfo: nil, repeats: true)
        feedTimer?.tolerance = 60
        
        fetchFeed()
    }

    func showSettings() {
        updateTimer?.invalidate()
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else { return }

        let popoverView = NSPopover()
        popoverView.contentViewController = vc
        popoverView.behavior = .transient
        popoverView.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY)
    }

    func fetchFeed() {
        let defaults = UserDefaults.standard
        guard let apiKey = defaults.string(forKey: "apiKey") else { return }
        guard !apiKey.isEmpty else {
            statusItem.button?.title = "No Api Key"
            return
        }

        DispatchQueue.global(qos: .utility).async { [unowned self] in
            let latitude = defaults.double(forKey: "latitude")
            let longitude = defaults.double(forKey: "longitude")
            var dataSource = "https://api.darksky.net/forecast/\(apiKey)/\(latitude),\(longitude)"
            if defaults.integer(forKey: "units") == 0 {
                dataSource += "?units=si"
            }

            guard let url = URL(string: dataSource) else { return }
            guard let data = try? Data(contentsOf: url) else {
                DispatchQueue.main.async() { [unowned self] in
                    self.statusItem.button?.title = "Bad Api Call"
                }

                return
            }

            let json: Any? = try? JSONSerialization.jsonObject(with: data, options: [])
            if let j: Any = json {
                DispatchQueue.main.async() { [unowned self] in
                    self.currentForecast = decode(j)
                    self.updateDisplay()
                }
            }
        }
    }
}
