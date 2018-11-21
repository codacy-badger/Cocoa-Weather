//
//  WeatherAPI.swift
//  Cocoa Weather
//
//  Created by zhs852 on 2018/9/22.
//  Copyright © 2018 zhs852. All rights reserved.
//

import Foundation

struct Weather: CustomStringConvertible {
    var city: String
    var currentTemp: Float
    var conditions: String
    var icon: String
    var tempUnit: String
    var lastRefresh: String
    
    var description: String {
        return "\(city): \(currentTemp)\(tempUnit), \(conditions)"
    }
}

class WeatherAPI {
    
    let BASE_URL = "http://api.openweathermap.org/data/2.5/weather"

    func weatherFromJSONData(_ data: Data) -> Weather? {
        typealias JSONDict = [String: AnyObject]
        let json: JSONDict
        do {
            json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDict
        } catch {
            return nil
        }
        var mainDict = json["main"] as! JSONDict
        var weatherList = json["weather"] as! [JSONDict]
        var weatherDict = weatherList[0]
        let time = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let weather = Weather(
            city: json["name"] as! String,
            currentTemp: mainDict["temp"] as! Float,
            conditions: weatherDict["main"] as! String,
            icon: weatherDict["icon"] as! String,
            tempUnit: UserDefaults.standard.string(forKey: "tempUnit") ?? "°C",
            lastRefresh: timeFormatter.string(from: time)
        )
    
        return weather
    }
    
    func fetchWeather(city: String, apiKey:String, unit:String, success: @escaping (Weather) -> Void) {
        UserDefaults.standard.setValue(0, forKey:"responseCode")
        let session = URLSession.shared
        let cityProcessed = city.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: "\(BASE_URL)?APPID=\(apiKey)&units=\(unit)&q=\(cityProcessed!)")
        let task = session.dataTask(with: url!) { data, response, err in
            if let httpResponse = response as? HTTPURLResponse {
                let responseCode = httpResponse.statusCode
                UserDefaults.standard.setValue(responseCode, forKey:"responseCode")
                if httpResponse.statusCode == 200 {
                    if let weather = self.weatherFromJSONData(data!) {
                        success(weather)
                    }
                }
            }
        }
        task.resume()
    }
    
}
