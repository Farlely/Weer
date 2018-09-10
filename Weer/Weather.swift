//
//  Weather.swift
//  JSON
//  Created by Farlely on 10/09/2018.
//  Copyright © 2018 Farlely. All rights reserved.
//

import Foundation
import CoreLocation

struct Weather {
    let summary:String
    let icon:String
    let temperature:Double
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(json:[String:Any]) throws {
        guard let summary = json["summary"] as? String else {throw SerializationError.missing("summary is missing")}
        
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("icon is missing")}
        
        guard let temperature = json["temperatureMax"] as? Double else {throw SerializationError.missing("temp is missing")}
        
        self.summary = summary
        self.icon = icon
        self.temperature = temperature
        
    }
    
    func formattedTemperature(unit: UnitTemperature) -> String? {
        
        // Convert the temperature value to
        // the selected temperature unit
        let farhenheit = Measurement(value: temperature,
                                     unit: UnitTemperature.fahrenheit)
        let convertedTemperature = farhenheit.converted(to: unit)
        
        // Format the temperature value to a
        // localized string
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        let temperatureString = formatter.string(from: NSNumber(value: convertedTemperature.value))
        
        return temperatureString
    }
    
    static let basePath = "https://api.darksky.net/forecast/7e07fe509e45ecc0583c1aab41cadb33/"
    
    static func forecast (withLocation location: CLLocationCoordinate2D, completion: @escaping ([Weather]?) -> ()) {
        
        let url = basePath + "\(location.latitude),\(location.longitude)"
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[Weather] = []
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["daily"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? Weather(json: dataPoint) {
                                        forecastArray.append(weatherObject)
                                    }
                                }
                            }
                        }
                    
                    }
                }catch {
                    print(error.localizedDescription)
                }
                
                completion(forecastArray)
                
            }
            
        }
        
        task.resume()
    }
}
