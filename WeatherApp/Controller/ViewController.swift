//
//  ViewController.swift
//  WeatherApp
//
//  Created by 赵芷涵 on 10/29/21.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit

class ViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    //let arr = ["Seattle WA, USA 54 °F", "Delhi DL, India, 75°F"]
    
    var arrCityInfo: [CityInfo] = [CityInfo]()
    var arrCurrentWeather : [CurrentWeather] = [CurrentWeather]()
    
    @IBOutlet weak var tblView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.delegate = self
        tblView.dataSource = self
        loadCurrentConditions()
        
    }
    
    
    // table view code
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCurrentWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("CurrentWeatherTableViewCell", owner: self, options: nil)?.first as! CurrentWeatherTableViewCell
        
        cell.lblCityName.text = "\(arrCurrentWeather[indexPath.row].cityInfoName)"
        //cell.lblWeather.text = "\(arrCurrentWeather[indexPath.row].weatherText)"
        cell.lblTemp.text = "\(arrCurrentWeather[indexPath.row].tempMetric)°C / \(arrCurrentWeather[indexPath.row].tempImperial)°F "
        
        if(arrCurrentWeather[indexPath.row].weatherText.lowercased().contains("rainny")){
            cell.imgWeather.image = UIImage(named: "rainny")
        }else if(arrCurrentWeather[indexPath.row].weatherText.lowercased().contains("cloudy")){
            cell.imgWeather.image = UIImage(named: "cloudy")
        }else if(arrCurrentWeather[indexPath.row].weatherText.lowercased().contains("snowy")){
            cell.imgWeather.image = UIImage(named: "snowy")
        }else if(arrCurrentWeather[indexPath.row].weatherText.lowercased().contains("windy")){
            cell.imgWeather.image = UIImage(named: "windy")
        }else{
            cell.imgWeather.image = UIImage(named: "sunny")
        }
        
        return cell
    }
    
    //refresh button
    @IBAction func refreshAction(_ sender: Any) {
        loadCurrentConditions()
    }
    
    // read DB data
    func loadCurrentConditions(){
        do{
            let realm = try Realm()
            let cities = realm.objects(CityInfo.self)
            self.arrCityInfo.removeAll()
            getAllCurrentWeather(Array(cities)).done { currentWeather in
                self.arrCurrentWeather = currentWeather
                self.tblView.reloadData()
            }
            .catch { error in
               print(error)
            }
       }catch{
           print("Error in reading Database \(error)")
       }
                
        
    }
    
    
    //get data
    func getAllCurrentWeather(_ cities: [CityInfo] ) -> Promise<[CurrentWeather]> {
            var promises: [Promise< CurrentWeather>] = []
            
        for i in 0 ..< cities.count {
                promises.append( getCurrentWeather(cities[i].locationKey, cities[i].cityName) )
            }
            
            return when(fulfilled: promises)
            
        }
    
    func getCurrentWeather(_ cityKey : String, _ cityName : String) -> Promise<CurrentWeather>{
            return Promise<CurrentWeather> { seal -> Void in
                let url = "\(currentWeatherURL)\(cityKey)?apikey=\(apiKey)" // build URL for current weather here
                print(url)
                Alamofire.request(url).responseJSON { response in
                    
                    if response.error != nil {
                        seal.reject(response.error!)
                    }
                    
                    let autoCompleteJSON : [JSON] = JSON(response.value).arrayValue
                    let WeatherInfo = autoCompleteJSON[0]
                    let currentWeather = CurrentWeather()
                    currentWeather.cityInfoName = cityName
                    currentWeather.cityKey = cityKey
                    currentWeather.epochTime = WeatherInfo["EpochTime"].intValue
                    currentWeather.isDayTime = WeatherInfo["IsDayTime"].boolValue
                    currentWeather.tempMetric = WeatherInfo["Temperature"]["Metric"]["Value"].intValue
                    currentWeather.tempImperial = WeatherInfo["Temperature"]["Imperial"]["Value"].intValue
                    currentWeather.weatherText = WeatherInfo["WeatherText"].stringValue
                  
                    
                    seal.fulfill(currentWeather)
                    
                }
            }
    }


}

