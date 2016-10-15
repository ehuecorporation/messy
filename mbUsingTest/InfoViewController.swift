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
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var locationManager = CLLocationManager()
        locationManager.delegate = self
        mapView.delegate = self
       
        locationManager.startUpdatingLocation()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // 位置情報取得に成功したときに呼び出されるデリゲート.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var userLocation = CLLocationCoordinate2DMake((manager.location?.coordinate.latitude)!, (manager.location?.coordinate.longitude)!)
        
        var userLocAnnotation: MKPointAnnotation = MKPointAnnotation()
        userLocAnnotation.coordinate = userLocation
        userLocAnnotation.title = "現在地"
        mapView.addAnnotation(userLocAnnotation)

    }
    
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(_ manager: CLLocationManager,didFailWithError error: Error){
        print("locationManager error")
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
