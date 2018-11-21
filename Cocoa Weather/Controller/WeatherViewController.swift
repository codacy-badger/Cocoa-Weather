//
//  WeatherView.swift
//  Cocoa Weather
//
//  Created by zhs852 on 2018/9/23.
//  Copyright © 2018 zhs852. All rights reserved.
//

import Cocoa

class WeatherView: NSView {

    @IBOutlet weak var cityTextField: NSTextField!
    @IBOutlet weak var currentConditionsTextField: NSTextField!
    @IBOutlet weak var lastRefreshTimeTextField: NSTextField!
    
    func update(_ weather: Weather) {
        DispatchQueue.main.async {
            self.cityTextField.stringValue = weather.city
            self.currentConditionsTextField.stringValue = "\(Int(weather.currentTemp))\(weather.tempUnit), \(weather.conditions)"
            self.lastRefreshTimeTextField.stringValue = weather.lastRefresh
        }
    }
    
}
