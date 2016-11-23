//
//  InfoViewController.swift
//  mbUsingTest
//
//  Created by 松本匡平 on 2016/10/15.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import MapKit

class InfoViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var openHours: UILabel!
    
    var targetMemo: memo = memo()
    
    var targetShopData: shop = shop()
    
    var mbs : NCMBSearch = NCMBSearch()
    
    //NotificcationのObserver
    var loadDataObserver: NSObjectProtocol?
    var refreshObserver: NSObjectProtocol?
    
    var locationManager = CLLocationManager()
    
    @IBAction func pushMenuList(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "goMenuList", sender: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //読込完了通知を受信した後の処理
        loadDataObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name(rawValue: mbs.NCMBLoadCompleteNotification),
            object: nil,
            queue: nil,
            using:{
                (notification) in
                
                //エラーがあればダイアログを開いて通知
                if (notification as NSNotification).userInfo != nil {
                    if let userInfo = (notification as NSNotification).userInfo as? [String: String?]{
                        if userInfo["error"] != nil{
                            self.presentError("通信エラー", "通信エラーが発生しました")
                        } // error end
                    } // userInfo ned
                }
            }// using end
        ) // loadDataObserver end
        
        mbs.getShopData(targetMemo.shopNumber)
        
    } // viewWillAppear end

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        mapView.delegate = self
        
        // 距離のフィルタ.
        locationManager.distanceFilter = 300.0
        
        // 精度.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        checkGPSAuth()
        
        // 中心点の緯度経度.
        let myLat: CLLocationDegrees = 35.702069
        let myLon: CLLocationDegrees = 139.775327
        let myCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLat, myLon) as CLLocationCoordinate2D
        
        // 縮尺.
        let myLatDist : CLLocationDistance = 300
        let myLonDist : CLLocationDistance = 300
        
        // Regionを作成.
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(myCoordinate, myLatDist, myLonDist);
        
        // MapViewに反映.
        mapView.setRegion(myRegion, animated: true)
        
        loadDataObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name(rawValue: mbs.NCMBShopLoadCompleteNotification),
            object: nil,
            queue: nil,
            using:
            {(notification) in
        
                var targetShop: shop = shop()
                
                targetShop =  self.mbs.shopData
                self.targetShopData = targetShop

                self.shopName.text = targetShop.shopName
                self.openHours.text = targetShop.openHours
                
                
                self.makeShopPin(targetShop)
                
                // 位置情報の更新を開始.
                self.locationManager.startUpdatingLocation()
                
        
            }
        )

    } // ViewDidLoad end

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // 店のピンを作成
    func makeShopPin(_ targetShopData: shop) {
        let shopLat: CLLocationDegrees = targetShopData.shopLat
        let shopLon: CLLocationDegrees = targetShopData.shopLon
        let shopCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(shopLat, shopLon) as CLLocationCoordinate2D
        let shopName = targetShopData.shopName
        
        let shopPin: MKPointAnnotation = MKPointAnnotation()
        shopPin.coordinate = shopCoordinate
        shopPin.title = shopName
        
        mapView.addAnnotation(shopPin)
        
        return
    }
    
    // GPSの認証を確認
    func checkGPSAuth() {
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if(status != CLAuthorizationStatus.authorizedWhenInUse) {
            
            print("not determined")
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            locationManager.requestWhenInUseAuthorization()
        }
        
        return
    }
    
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(_ manager: CLLocationManager,didFailWithError error: Error){
        print("locationManager error")
        
        //エラーアラートを表示してOKで戻る
        presentError("エラー", "位置情報の利用を許可してください")
        locationManager.stopUpdatingLocation()
        
        return
    }
    
    // GPSから値を取得した際に呼び出されるメソッド.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("didUpdateLocations")
        locationManager.stopUpdatingLocation()
        
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
        
        // 配列から現在座標を取得.
        let myLocations: NSArray = locations as NSArray
        let myLastLocation: CLLocation = myLocations.lastObject as! CLLocation
        let myLocation:CLLocationCoordinate2D = myLastLocation.coordinate
        
        print("現在地は\(myLocation.latitude), \(myLocation.longitude)")
        
        
        // 縮尺.
        let myLatDist : CLLocationDistance = 600
        let myLonDist : CLLocationDistance = 600
        
        let shopLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(targetShopData.shopLat, targetShopData.shopLon) as CLLocationCoordinate2D
        
        let fromPlace: MKPlacemark = MKPlacemark(coordinate: myLocation, addressDictionary: nil)
        
        let toPlace: MKPlacemark = MKPlacemark(coordinate: shopLocation, addressDictionary: nil)
        
        // Itemを生成してPlaceMarkをセット.
        let fromItem: MKMapItem = MKMapItem(placemark: fromPlace)
        let toItem: MKMapItem = MKMapItem(placemark: toPlace)
        
        // MKDirectionsRequestを生成.
        let myRequest: MKDirectionsRequest = MKDirectionsRequest()
        
        // 出発地のItemをセット.
        myRequest.source = fromItem
        
        // 目的地のItemをセット.
        myRequest.destination = toItem
        
        // 複数経路の検索を有効.
        myRequest.requestsAlternateRoutes = true
        
        // 移動手段を車に設定.
        myRequest.transportType = MKDirectionsTransportType.walking
        
        // MKDirectionsを生成してRequestをセット.
        let myDirections: MKDirections = MKDirections(request: myRequest)
        
        // 経路探索.
        myDirections.calculate { (response, error) in
            
            // NSErrorを受け取ったか、ルートがない場合.
            if error != nil || response!.routes.isEmpty {
                //エラーアラートを表示してOKで戻る
                self.presentError("エラー", "経路が取得できませんでした")
                return
            }
            
            let route: MKRoute = response!.routes[0] as MKRoute
            print("目的地まで \(route.distance)km")
            print("所要時間 \(Int(route.expectedTravelTime/60))分")
            
            // mapViewにルートを描画.
            self.mapView.add(route.polyline)
        }
        
        // Regionを作成.
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation, myLatDist, myLonDist);
        
        // MapViewに反映.
        mapView.setRegion(myRegion, animated: true)
        
        // ピンを生成.
        let fromPin: MKPointAnnotation = MKPointAnnotation()
        let toPin: MKPointAnnotation = MKPointAnnotation()
        
        // 座標をセット.
        fromPin.coordinate = myLocation
        toPin.coordinate = shopLocation
        
        // titleをセット.
        fromPin.title = "現在地"
        toPin.title = targetShopData.shopName
        
        // mapViewに追加.
        mapView.addAnnotation(fromPin)
        mapView.addAnnotation(toPin)
        
    } // locationManager (get GPS) end
    
    // ルートの表示設定.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let route: MKPolyline = overlay as! MKPolyline
        let routeRenderer: MKPolylineRenderer = MKPolylineRenderer(polyline: route)
        
        // ルートの線の太さ.
        routeRenderer.lineWidth = 3.0
        
        // ルートの線の色.
        routeRenderer.strokeColor = UIColor.red
        return routeRenderer
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
    
    // エラーメッセージを出す関数を定義
    func presentError (_ title: String, _ message: String) {
        let errorAlert = UIAlertController(
            title: "\(title)",
            message: "\(message)",
            preferredStyle: UIAlertControllerStyle.alert
        )
        errorAlert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.default,
                handler: nil
            )
        )
        self.present(errorAlert, animated: true, completion: nil)
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "goMenuList" {
            
            let ShopMenuController = segue.destination as! ShopMenusViewController
            ShopMenuController.targetShopData = self.targetShopData
            
            //編集の際は編集対象のobjectIdと編集フラグ・編集対象のデータを設定する
            
        }

    }


}
