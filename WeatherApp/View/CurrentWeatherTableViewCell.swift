//
//  CurrentWeatherTableViewCell.swift
//  WeatherApp
//
//  Created by 赵芷涵 on 10/29/21.
//

import UIKit

class CurrentWeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCityName: UILabel!
    //@IBOutlet weak var lblWeather: UILabel!
    @IBOutlet weak var imgWeather: UIImageView!
    @IBOutlet weak var lblTemp: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
}
