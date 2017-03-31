//
//  ShopEditViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2017/03/30.
//  Copyright © 2017年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB
import CoreLocation

class ShopEditViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var shopName: UITextField!
    @IBOutlet weak var openHours: UITextView!
    @IBOutlet weak var restDay: UITextField!
    
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var unChangeButton: UIButton!
    
    @IBOutlet weak var upperSpace: NSLayoutConstraint!
    
    @IBAction func hideKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func upload(_ sender: UIBarButtonItem) {
        let newName = self.shopName.text
        let newHours = self.openHours.text
        let newRestDay = self.restDay.text
        let changed_label = self.change_flag
        var targetLat = 0.0
        var targetLon = 0.0
        if changed_label == 1 {
            targetLat = latitude
            targetLon = longitude
        }
        
        if((newName?.isEmpty)! || (newHours?.isEmpty)! || (newRestDay?.isEmpty)!) {
            presentError("エラー", "入力内容にエラーがあります")
            return
        } else {
            
            let geoPoint = NCMBGeoPoint()
            geoPoint.latitude = targetLat
            geoPoint.longitude = targetLon
            
            var saveError: NSError? = nil
            
            let obj: NCMBObject = NCMBObject(className: "editedShopData")
            obj.setObject(newName, forKey: "shopName")
            obj.setObject(newHours, forKey: "openHours")
            obj.setObject(newRestDay, forKey: "restDay")
            obj.setObject(geoPoint, forKey: "geoPoint")
            obj.setObject(self.targetShop.shopNumber, forKey: "number")
            obj.save(&saveError)
            
            
            if saveError == nil {
                print("success save data.")
                let errorAlert = UIAlertController(
                    title: "投稿完了",
                    message: nil,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                errorAlert.addAction(
                    UIAlertAction(
                        title: "OK",
                        style: UIAlertActionStyle.default,
                        handler: self.saveComplete                    )
                )
                
                self.present(errorAlert, animated: true, completion: nil)

            } else {
                print("failure save data.\(String(describing: saveError))")
                presentError("エラー", "もう一度お試しください")
            }
            
        }
        
    } // end upload
    
    @IBAction func change(_ sender: UIButton) {
        if change_flag == 1 {
            change_flag = 0
            return
        }
        changeButton.backgroundColor = UIColor.init(red: 220/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1.0)
        changeButton.setTitleColor(UIColor.white, for: .normal)
        unChangeButton.backgroundColor = UIColor.white
        unChangeButton.setTitleColor(UIColor.black, for: .normal)
        change_flag = 1

        // LocationManagerの生成.
        myLocationManager = CLLocationManager()
        // Delegateの設定.
        myLocationManager.delegate = self
        // 距離のフィルタ.
        myLocationManager.distanceFilter = 100.0
        // 精度.
        myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if(status != CLAuthorizationStatus.authorizedWhenInUse) {
            
            print("not determined")
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            myLocationManager.requestWhenInUseAuthorization()
        }
        
        // 位置情報の更新を開始.
        myLocationManager.startUpdatingLocation()
        
    }
    
    @IBAction func unChange(_ sender: UIButton) {
        if change_flag == 0 {
            change_flag = 1
            return
        }
        changeButton.backgroundColor = UIColor.white
        changeButton.setTitleColor(UIColor.black, for: .normal)
        unChangeButton.backgroundColor = UIColor.init(red: 220/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1.0)
        unChangeButton.setTitleColor(UIColor.white, for: .normal)
        change_flag = 0
    }
    
    // 対象店舗データ
    var targetShop: shop = shop()
    // 現在地の変更をするかどうか
    var change_flag = 0
    // 取得した緯度を保持するインスタンス
    var latitude: Double = Double()
    // 取得した経度を保持するインスタンス
    var longitude: Double = Double()
    // 位置情報利用のためのインスタンス
    var myLocationManager: CLLocationManager!
    // 選択中のテキストフィールド
    var txtActiveField = UITextField()
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self,selector: #selector(ShopEditViewController.keyboardWillBeShown(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ShopEditViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shopName.text = targetShop.shopName
        openHours.text = targetShop.openHours
        restDay.text = targetShop.restDay
        
        
        unChangeButton.backgroundColor = UIColor.init(red: 220/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1.0)
        unChangeButton.setTitleColor(UIColor.white, for: .normal)
        
        self.restDay.delegate = self

    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    // UITextFieldが編集開始直前に呼ばれる.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        txtActiveField = textField
        return true
    }
    
    // キーボード登場時の処理
    func keyboardWillBeShown(_ notification: Notification) {
        self.view.setNeedsUpdateConstraints()
        print(txtActiveField)
        if txtActiveField != restDay {
            return
        }
        if let userInfo = notification.userInfo{
            if let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue{
                let keyBoardRect = keyboard.cgRectValue
                let myBoundSize: CGSize = UIScreen.main.bounds.size
                let tmp_height = myBoundSize.height-keyBoardRect.size.height
                if tmp_height < 360 {
                    upperSpace.constant = CGFloat(-200.0)
                    // アニメーションによる移動
                    UIView.animate(withDuration: 0.3, animations: self.view.layoutIfNeeded)
                }
            }
        }
    }
    // キーボードが消える時の処理    
    func keyboardWillBeHidden(_ notification : Notification) {
        self.view.setNeedsUpdateConstraints()
        if txtActiveField != restDay {
            return
        }
        txtActiveField = shopName
        if let userInfo = notification.userInfo{
            if let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue{
                let keyBoardRect = keyboard.cgRectValue
                let myBoundSize: CGSize = UIScreen.main.bounds.size
                let tmp_height = myBoundSize.height-keyBoardRect.size.height
                if tmp_height < 360 {
                    upperSpace.constant = CGFloat(10.0)
                    // アニメーションによる移動
                    UIView.animate(withDuration: 0.3, animations: self.view.layoutIfNeeded)
                }
            }
        }
    }
    
    //登録が完了した際のアクション
    func saveComplete(_ ac: UIAlertAction) -> Void {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // GPSから値を取得した際に呼び出されるメソッド.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("didUpdateLocations")
        myLocationManager.stopUpdatingLocation()
        
        // 配列から現在座標を取得.
        let myLocations: NSArray = locations as NSArray
        let myLastLocation: CLLocation = myLocations.lastObject as! CLLocation
        let myLocation:CLLocationCoordinate2D = myLastLocation.coordinate
        
        print("\(myLocation.latitude), \(myLocation.longitude)")
        
        latitude = myLocation.latitude as Double
        longitude = myLocation.longitude as Double
        
    }
    
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(_ manager: CLLocationManager,didFailWithError error: Error){
        print("locationManager error")
        myLocationManager.stopUpdatingLocation()
        
        unChange(UIButton.init())
        
        //エラーアラートを表示してOKで戻る
        presentError("エラー", "位置情報の利用を許可してください")
        
        return
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

}
