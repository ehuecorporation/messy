//
//  InfoViewController.swift
//  mbUsingTest
//
//  Created by 松本匡平 on 2016/10/15.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import MapKit

class InfoViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate  {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var openHours: UILabel!
    
    var targetMemo: memo = memo()
    
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shopName.text = targetMemo.memoTitle

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        mapView.delegate = self
        
        // 距離のフィルタ.
        locationManager.distanceFilter = 300.0
        
        // 精度.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if(status != CLAuthorizationStatus.authorizedWhenInUse) {
            
            print("not determined")
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            locationManager.requestWhenInUseAuthorization()
        }
        
        
        // 位置情報の更新を開始.
        locationManager.startUpdatingLocation()
        
        // 中心点の緯度経度.
        let myLat: CLLocationDegrees = 35.702069
        let myLon: CLLocationDegrees = 139.775327
        let myCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLat, myLon) as CLLocationCoordinate2D
        
        // 縮尺.
        let myLatDist : CLLocationDistance = 300
        let myLonDist : CLLocationDistance = 300
        
        // Regionを作成.
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(myCoordinate, myLatDist, myLonDist);
        
        let shopLat: CLLocationDegrees = 35.695959
        let shopLon: CLLocationDegrees = 139.698422
        let shopCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(shopLat, shopLon) as CLLocationCoordinate2D
        
        let shopName = "鶏Dining&Bar Goto"
        
        // ピンを生成.
        let shopPin: MKPointAnnotation = MKPointAnnotation()
        shopPin.coordinate = shopCoordinate
        shopPin.title = ""
        mapView.addAnnotation(shopPin)
        
        
        // MapViewに反映.
        mapView.setRegion(myRegion, animated: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(_ manager: CLLocationManager,didFailWithError error: Error){
        print("locationManager error")
    }
    
    // GPSから値を取得した際に呼び出されるメソッド.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("didUpdateLocations")
        
        // 配列から現在座標を取得.
        let myLocations: NSArray = locations as NSArray
        let myLastLocation: CLLocation = myLocations.lastObject as! CLLocation
        let myLocation:CLLocationCoordinate2D = myLastLocation.coordinate
        
        print("\(myLocation.latitude), \(myLocation.longitude)")
        
        // 縮尺.
        let myLatDist : CLLocationDistance = 500
        let myLonDist : CLLocationDistance = 500
        
        // Regionを作成.
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation, myLatDist, myLonDist);
        
        // ピンを生成.
        let myPin: MKPointAnnotation = MKPointAnnotation()
        myPin.coordinate = myLocation
        myPin.title = "現在地"
        mapView.addAnnotation(myPin)
        
        // MapViewに反映.
        mapView.setRegion(myRegion, animated: true)
    }
    
    // Regionが変更した時に呼び出されるメソッド.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated")
    }
    
    // 認証が変更された時に呼び出されるメソッド.
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status{
        case .authorizedWhenInUse:
            print("AuthorizedWhenInUse")
        case .authorized:
            print("Authorized")
        case .denied:
            print("Denied")
        case .restricted:
            print("Restricted")
        case .notDetermined:
            print("NotDetermined")
        }
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
