//
//  MZWeatherView.swift
//  MZWeatherSplash
//
//  Created by 张逸 on 16/4/14.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit
import Alamofire

class MZLocationManager: NSObject, AMapLocationManagerDelegate, AMapSearchDelegate {
    private let APIKEY = ""
    private var locationManager: AMapLocationManager?
    private var search: AMapSearchAPI?
    var location: CLLocation
    var cityName: String? {
        didSet {
            print("cityName didSet: \(cityName)")
            SaveData.set(value: self.cityName ?? "上海", withKey: DataKeys.CITYNAME)
        }
    }
    var cityCode: String = ""

    override init() {
        location = CLLocation()
        super.init()
        print("MZLocationManager")
        if CLLocationManager.locationServicesEnabled() &&
            (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined)
        {
            locationManager = AMapLocationManager()
            locationManager?.delegate = self
            locationManager?.startUpdatingLocation()
            AMapSearchServices.sharedServices().apiKey = APIKEY
            search = AMapSearchAPI()
            search?.delegate = self
        } else {
            print("gps invalid")
        }
    }

    func getCurrentCity() {
        let regeoRequest = AMapReGeocodeSearchRequest()
        regeoRequest.location = AMapGeoPoint.locationWithLatitude(CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.longitude))
        print("currentLocation: \(regeoRequest.location)")
        regeoRequest.radius = 10000
        regeoRequest.requireExtension = true
        self.search?.AMapReGoecodeSearch(regeoRequest)
    }

    //MARK: AMapSearchDelegate Mathods
    func onReGeocodeSearchDone(request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        print("onReGeocodeSearchDone")
        if let regeocode = response.regeocode {
            var fullCityName = ""
            if (regeocode.addressComponent.city == nil || regeocode.addressComponent.city == "") {
                fullCityName = regeocode.addressComponent.province
                print("直辖市: \(self.cityName) code: \(cityCode)")
            } else {
                fullCityName = regeocode.addressComponent.city
                print("非直辖市: \(self.cityName) code: \(cityCode)")
            }
            fullCityName = fullCityName.substringToIndex(fullCityName.endIndex.advancedBy(-1))
            cityName = fullCityName

            locationManager?.stopUpdatingLocation()
            if let cityCode = regeocode.addressComponent.citycode {
                if cityCode != "" {
                    self.cityCode = cityCode
                } else {
                    return
                }
            } else {
                return
            }
        }
    }

    //MARK: AMapLocationManagerDelegate Methods
    func amapLocationManager(manager: AMapLocationManager!, didUpdateLocation location: CLLocation!) {
        print("GPS->: \(location.coordinate)")
        self.location = location
        if ((self.cityName == nil)) {
            getCurrentCity()
        }
    }
}

class MZWeatherView: UIView {
    var city: String?
    var showInterval: NSTimeInterval = 3
    var dismissTimer: NSTimer?

    var weatherModel: MZWeatherModel? {
        didSet {
            self.degreeLabel?.text = "\(self.weatherModel!.minDegree)° ~ \(self.weatherModel!.maxDegree)°"
        }
    }

    var dismissButton: UIButton?
    var blurView: UIVisualEffectView?

    var cityLabel: UILabel? {
        didSet {
            cityLabel?.textAlignment = .Center
            cityLabel?.font = UIFont.systemFontOfSize(30)
        }
    }

    var degreeLabel: UILabel? {
        didSet {
            degreeLabel?.textAlignment = .Center
            degreeLabel?.font = UIFont.systemFontOfSize(50)
        }
    }

    init(frame: CGRect, day: Int = 0) {
        super.init(frame: frame)
        blurView = UIVisualEffectView(effect: UIBlurEffect())
        degreeLabel = UILabel()
        cityLabel = UILabel()
        dismissButton = UIButton(type: .System)
        degreeLabel?.text = "0"
        self.city = (SaveData.get(withKey: .CITYNAME) as? String) ?? "上海"
        cityLabel?.text = city

        dismissButton?.setTitle("跳过", forState: .Normal)
        dismissButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        dismissButton?.backgroundColor = UIColor.blackColor()
        dismissButton?.addTarget(self, action: #selector(dismissSelf), forControlEvents: .TouchUpInside)

        addSubview(blurView!)
        addSubview(dismissButton!)
        addSubview(cityLabel!)
        addSubview(degreeLabel!)
        setupConstraints()
        fetchWeatherInfo()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        dismissButton?.translatesAutoresizingMaskIntoConstraints = false
        degreeLabel?.translatesAutoresizingMaskIntoConstraints = false
        cityLabel?.translatesAutoresizingMaskIntoConstraints = false
        blurView?.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint(item: blurView!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurView!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurView!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blurView!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: degreeLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: degreeLabel!, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cityLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cityLabel!, attribute: .Bottom, relatedBy: .Equal, toItem: degreeLabel!, attribute: .Top, multiplier: 1, constant: -15),
            NSLayoutConstraint(item: dismissButton!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dismissButton!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dismissButton!, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.2, constant: 0),
            NSLayoutConstraint(item: dismissButton!, attribute: .Height, relatedBy: .Equal, toItem: dismissButton, attribute: .Width, multiplier: 0.6, constant: 0)
            ])
    }

    func dismissButtonPressed(sender: UIButton) {
        dismissSelf()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews")
        self.dismissTimer = NSTimer.scheduledTimerWithTimeInterval(showInterval, target: self, selector: #selector(dismissSelf), userInfo: nil, repeats: false)
    }

    private func placeWithGB2312Coding(rawString: String) -> String {
        let encodedString = rawString.stringByAddingPercentEscapesUsingEncoding(CFStringConvertEncodingToNSStringEncoding(0x0632))
        return encodedString ?? ""
    }

    private func weatherQueryURL(city: String = "上海", day: Int = 0) -> String {
        return"http://php.weather.sina.com.cn/xml.php?city=\(self.placeWithGB2312Coding(city))&password=DJOYnieT8234jlsK&day=\(day)"
    }

    private func fetchWeatherInfo() {
        let url = weatherQueryURL(city ?? "上海", day: 0)
        print("city: \(city)")
        print("url: \(url)")
        Alamofire.request(.GET, url).response {
            req, res, data, error in
            let xml = SWXMLHash.parse(data!)
            print(xml)
            self.weatherModel = MZWeatherModel(withXML: xml)
        }
    }

    func dismissSelf() {
        dismissTimer?.invalidate()
        dismissTimer = nil
        UIView.animateWithDuration(0.25, animations: {
            self.transform = CGAffineTransformMakeScale(2.0, 2.0)
            self.alpha = 0.0
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
}
