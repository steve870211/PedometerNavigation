//
//  CoreLocationViewController.swift
//  AbawMission
//
//  Created by 許佳航 on 2017/1/25.
//  Copyright © 2017年 許佳航. All rights reserved.
//

import UIKit
import CoreLocation

class CoreLocationViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var imageView: UIImageView!

    // drawLine
    let coreLocationManager = CLLocationManager()
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 1.0
    var opacity: CGFloat = 1.0
    // corelocation
    var locationManager:CLLocationManager!
    // labels
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var altitude: UILabel!
    @IBOutlet weak var horizontalAccuracy: UILabel!
    @IBOutlet weak var verticalAccuracy: UILabel!
    @IBOutlet weak var course: UILabel!
    @IBOutlet weak var speed: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        //設置定位服務管理器代理
        locationManager.delegate = self
        //設置定位進度
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        //更新距離
        locationManager.distanceFilter = 1
        //發送授權申请
        locationManager.requestAlwaysAuthorization()
        if (CLLocationManager.locationServicesEnabled()) {
            //允許使用定位服務的話，開啟定位服務更新
            locationManager.startUpdatingLocation()
            print("定位開始")
        }
        if (CLLocationManager.headingAvailable()) {
            locationManager.startUpdatingHeading()
            print("指北針啟動")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //最新的座標
        let currLocation:CLLocation = locations.last!
        longitude.text = "經度：\(currLocation.coordinate.longitude)"
        //緯度
        latitude.text = "緯度：\(currLocation.coordinate.latitude)"
        //海拔
        altitude.text = "海拔：\(currLocation.altitude)"
        //獲得水平精度
        horizontalAccuracy.text = "水平精度：\(currLocation.horizontalAccuracy)"
        //獲得垂直精度
        verticalAccuracy.text = "垂直精度：\(currLocation.verticalAccuracy)"
        //獲得速度
        speed.text = "速度：\(currLocation.speed)"
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print(newHeading.magneticHeading)
        //獲得方向
        course.text = "方向：\(Int(newHeading.magneticHeading))"
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        
        imageView.image?.draw(in: view.bounds)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context?.setBlendMode(CGBlendMode.normal)
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        imageView.alpha = opacity
        UIGraphicsEndImageContext()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
