//
//  WeerTableViewController.swift
//  Weer
//
//  Created by Farlely on 10/09/2018.
//  Copyright © 2018 Farlely. All rights reserved.
//

import UIKit
import CoreLocation

class WeerTableViewController: UITableViewController,UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedUnit: UnitTemperature = .kelvin {
        didSet {
            tableView.reloadData()
        }
    }
    
    var forecastData = [Weather]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !locationString.isEmpty {
            updateWeatherForLocation(location: locationString)
        }
    }
    
    func updateWeatherForLocation (location:String) {
        CLGeocoder().geocodeAddressString(location) { placemarks, error in
            guard error == nil else { return }
            guard let location = placemarks?.first?.location else { return }
            
            Weather.forecast(withLocation: location.coordinate) { result in
                guard let result = result else { return }
                
                DispatchQueue.main.async {
                    self.forecastData = result
                }
            }
        }
        
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let weatherObject = forecastData [indexPath.row]
        
        cell.textLabel?.text = weatherObject.summary
        cell.detailTextLabel?.text = weatherObject.formattedTemperature(unit: selectedUnit)
        cell.imageView?.image = UIImage(named: weatherObject.icon)
        
        return cell
    }
}
