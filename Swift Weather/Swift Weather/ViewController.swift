//
//  ViewController.swift
//  Swift Weather
//
//  Created by JackWee on 14-7-16.
//  Copyright (c) 2014年 JackWee. All rights reserved.
//

import UIKit
import CoreLocation 

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet var location: UILabel!
    @IBOutlet var temperature: UILabel!
    @IBOutlet var icon: UIImageView!
    @IBOutlet var loadIndicator: UIActivityIndicatorView!
    @IBOutlet var loading: UILabel?
    let locationManger:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //使当前类作为locationManger的代理
        locationManger.delegate = self
        //设置精确度
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        self.loadIndicator.startAnimating()//启动UIActivityIndicatorView
        loading!.text = "努力加载中..."
        if ios8(){
            locationManger.requestAlwaysAuthorization()
            //println("!!!")
        }
        locationManger.startUpdatingLocation()//更新地理位置，从CLLocationManagerDelegate协议中实现的方法locationManager()开始生效
    }
    //判断device版本
    func ios8() -> Bool{
        //println(UIDevice.currentDevice().systemVersion)
        return UIDevice.currentDevice().systemVersion == "8.0"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //当location发生变化时，返回locations数组
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        //获取最新的地理位置
        var location:CLLocation = locations[locations.count-1] as CLLocation
        if location.horizontalAccuracy > 0{
            println(location.coordinate.latitude)//经度
            println(location.coordinate.longitude)//纬度
            self.updateWeatherInfo(location.coordinate.latitude,longitude:location.coordinate.longitude)
            locationManger.stopUpdatingLocation()
        }
    }
    //调用AFNetworking库 传递经纬度对API进行调用
    func updateWeatherInfo(latitude:CLLocationDegrees,longitude:CLLocationDegrees){
        let manger = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
        let params = ["lat":latitude ,"lon":longitude,"cnt":0]
        manger.GET(url, parameters: params, success:{
                (operation:AFHTTPRequestOperation!,responseObject:AnyObject!) in
                println(responseObject.description!)
                self.updateUISuccess(responseObject as NSDictionary)
            }, failure: {
                (operation:AFHTTPRequestOperation!,error:NSError!) in
                    println(error.localizedDescription)
            })
        
    }

    func updateUISuccess(responseObject:NSDictionary!){
        self.loadIndicator.hidden = true
        self.loadIndicator.stopAnimating()//停止UIActivityIndicato rView
        self.loading!.text = nil
        
        
        if let tempResult = responseObject["main"]!["temp"]! as? Double {
            //更新温度信息
            var temperature:Double

            if responseObject["sys"]!["country"]! as? String == "US"{
                temperature = round((tempResult - 273.15) * 1.8)
            }
            else{
                temperature = round(tempResult - 273.15)
            }
            self.temperature.text = "\(temperature)˚"
            //更新城市信息
            self.location.text = responseObject["name"]! as? String
            //更新UIImage
            var condition = (responseObject["weather"]! as NSArray)[0]["id"]! as? Int
            var sunrise = responseObject["sys"]!["sunrise"]! as? Double
            var sunset = responseObject["sys"]!["sunset"]! as? Double
            
            var nightTime = false
            var currentTime = NSDate().timeIntervalSince1970
            
            if (currentTime < sunrise) || (currentTime > sunset){
                nightTime = true
            }
            self.updateWeatherIcon(condition!, nightTime: nightTime)
        }
        else{
            self.loading!.text = "天气信息不可用"
        }
    

    }
    func updateWeatherIcon(condition:Int,nightTime:Bool){
        if condition < 300{
            if nightTime{
                self.icon.image = UIImage(named: "tstorm1_night")
            }
            else{
                self.icon.image = UIImage(named: "tstorm1")
            }
        }
        else{
            self.icon.image = UIImage(named: "sunny")
        }
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        println(error)
        println("!!!")
        self.loading!.text = "地理位置信息不可用"
    }

}

