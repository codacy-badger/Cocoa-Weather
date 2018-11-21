//
//  StatusMenuController.swift
//  Cocoa Weather
//
//  Created by zhs852 on 2018/9/22.
//  Copyright © 2018 zhs852. All rights reserved.
//

import Cocoa

let DEFAULT_CITY = "California"

class StatusMenuController: NSObject, PreferencesWindowDelegate {
    
    func preferencesDidUpdate() {
        updateWeather()
    }
   
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var weatherView: WeatherView!
    @IBOutlet weak var titleMenuItem: NSMenuItem!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var weatherMenuItem: NSMenuItem!
    var preferencesWindow: PreferencesWindow!
    
    @IBAction func refreshClicked(_ sender: Any) {
        updateWeather()
    }
    
    @IBAction func preferencesClicked(_ sender: Any) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @objc func updateWeather() {
        statusItem.title = "Cocoa Weather"
        statusItem.image = NSImage()
        let defaults = UserDefaults.standard
        let city = defaults.string(forKey: "city") ?? DEFAULT_CITY
        let apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? "2a50037d2d60b806c1f2d87ee6e1f29b"
        let unit = UserDefaults.standard.string(forKey: "requestUnit") ?? "metric"
        weatherAPI.fetchWeather(city: city, apiKey: apiKey, unit: unit) { weather in
            let menuTempStatus = UserDefaults.standard.integer(forKey: "menuTemp")
            let pushNotification = UserDefaults.standard.integer(forKey: "pushNotification")
            DispatchQueue.main.async {
                let icon = NSImage(named: NSImage.Name(rawValue: weather.icon))
                icon?.isTemplate = true
                self.statusItem.image = icon
                switch menuTempStatus {
                case 1:
                    self.statusItem.title = "\(Int(weather.currentTemp))\(weather.tempUnit)"
                default:
                    self.statusItem.title = ""
                }
                if pushNotification == 1 {
                    let notification = NSUserNotification()
                    notification.title = NSLocalizedString("Weather Refreshed", comment: "Weather Refreshed")
                    notification.subtitle = "\(Int(weather.currentTemp))\(weather.tempUnit), \(weather.conditions)"
                    NSUserNotificationCenter.default.deliver(notification)
                }
            }
            self.weatherView.update(weather)
        }
    }
    
    func refreshTimer() {
        let refreshFrequency = UserDefaults.standard.integer(forKey: "refreshFrequency")
        let timer = Timer.scheduledTimer(timeInterval: TimeInterval(refreshFrequency), target: self, selector: #selector(self.updateWeather), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    var weatherAPI: WeatherAPI!
    
    override func awakeFromNib() {
        statusItem.title = "Cocoa Weather"
        statusItem.menu = statusMenu
        titleMenuItem.title = "Cocoa Weather"
        weatherAPI = WeatherAPI()
        weatherMenuItem = statusMenu.item(withTitle: "Weather")
        weatherMenuItem.view = weatherView
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        if UserDefaults.standard.bool(forKey: "firstRun") == false {
            UserDefaults.standard.setValue(1800, forKey: "refreshFrequency")
            UserDefaults.standard.setValue(true, forKey: "firstRun")
        }
        updateWeather()
        refreshTimer()
    }

}
