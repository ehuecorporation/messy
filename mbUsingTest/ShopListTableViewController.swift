//
//  ShopListTableViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/12/12.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB
import CoreLocation

class ShopListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    
    @IBOutlet weak var shopListTable: UITableView!
    //NCMBAPIの利用
    public var mbs: NCMBSearch = NCMBSearch()
    
    //NotificcationのObserver
    var loadDataObserver: NSObjectProtocol?
    var refreshObserver: NSObjectProtocol?
    
    // APIカウント
    var apiCounter = 0
    
    //コメント編集フラグ
    var editFlag: Bool = false
    
    //セレクトフラグ
    var selctFlag:Bool = false
    
    //更新フラグ
    var refreshFlag: Bool = false
    
    //テーブルビューの要素数
    let sectionCount: Int = 1
    
    //対象店舗
    var targetShop: shop = shop()
    
    //対象MeMoのobjectID
    var targetMemoObjectId: String = ""
    
    //参照している配列の場所
    var targetNum: Int = Int()
    
    //ユーザー情報
    var userData = UserDefaults.standard
    
    var myLocationManager: CLLocationManager!
    // 取得した緯度を保持するインスタンス
    var latitude: Double = Double()
    // 取得した経度を保持するインスタンス
    var longitude: Double = Double()
    
    @IBAction func addNewShop(_ sender: UIBarButtonItem) {
        self.selctFlag = false
        performSegue(withIdentifier: "goPostView", sender: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //読込完了通知を受信した後の処理
        loadDataObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name(rawValue: mbs.NCMBShopLoadCompleteNotification),
            object: nil,
            queue: nil,
            using:{
                (notification) in
                
                //エラーがあればダイアログを開いて通知
                if (notification as NSNotification).userInfo != nil {
                    
                    if let userInfo = (notification as NSNotification).userInfo as? [String: String?]{
                        
                        if userInfo["error"] != nil{
                            self.presentError("エラー", userInfo["error"]!!)
                        } // error end
                        
                    } // userInfo ned
                    
                } else {
                    
                    self.shopListTable.reloadData()
                    
                }// notification error end
                
        } // using end
        ) // loadDataObserver end
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        if mbs.memos.count == 0 {
            myLocationManager.startUpdatingLocation()
        } else {
            self.shopListTable.reloadData()
        }
        
        //テーブルビューのデリゲート
        self.shopListTable.delegate = self
        self.shopListTable.dataSource = self
        
        //Xibのクラスを読み込む
        let nib: UINib = UINib(nibName: "MemoCell", bundle:  Bundle(for: MemoCell.self))
        self.shopListTable.register(nib, forCellReuseIdentifier: "MemoCell")
        
        //セルの高さを設定
        self.shopListTable.rowHeight = 50
        self.shopListTable.tableFooterView = UIView(frame: .zero)
        
        // Pull to Refreshコントロール初期化
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MainViewController.onRefresh(_:)), for: .valueChanged)
        self.shopListTable.addSubview(refreshControl)
        
        
    }
    
    // Pull to Refresh
    func onRefresh(_ refreshControl: UIRefreshControl){
        // UIRefreshControlを読込状態にする
        refreshControl.beginRefreshing()
        // 終了通知を受信したらUIRefreshControlを停止する
        refreshObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: mbs.NCMBShopLoadCompleteNotification),
            object: nil,
            queue: nil,
            using: {
                notification in
                // 通知の待受を終了
                NotificationCenter.default.removeObserver(self.refreshObserver!)
                // UIRefreshControlを停止する
                refreshControl.endRefreshing()
        }
        ) // uisng block end
        // 通常のリフレッシュ
        
        // 位置情報の更新を開始.
        myLocationManager.startUpdatingLocation()
        
    } // onRefresh end
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //通知待受を終了
        NotificationCenter.default.removeObserver(self.loadDataObserver)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // テーブルの要素数を設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //取得データの総数
        if mbs.restaurants.count > 0 {
            return mbs.restaurants.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell") as? MemoCell
        
        let targetShopData: shop = mbs.restaurants[(indexPath as NSIndexPath).row]
    
        //隠しておく要素
        cell!.objectID.isHidden = true
        cell!.fileName.isHidden = true
        cell!.favoriteCounter.isHidden = true
        cell!.lookCounter.isHidden = true
        cell!.lookCounterLabel.isHidden = true
        cell!.favoriteCounterLabel.isHidden = true
        cell!.menuName.isHidden = true
        cell!.menuCost.isHidden = true
        cell!.menuImage.isHidden = true
        cell!.updateDate.isHidden = true
        cell!.favButton.isHidden = true
        
        //表示する要素
        cell!.shopName.text = targetShopData.shopName
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.none
        cell!.accessoryType = UITableViewCellAccessoryType.none
    
        return cell!
    }
    
    //セルをタップした場合に実行
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //セグエの実行時に値を渡す
        let targetShopData: shop = mbs.restaurants[(indexPath as NSIndexPath).row]
        self.targetShop = targetShopData
        self.selctFlag = true
        
        performSegue(withIdentifier: "goPostView", sender: targetShop)
    }
    
    //テーブルのセクションを設定する
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionCount
    }
    
    //segueを呼び出したときに呼ばれるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //詳細画面へ行く前に詳細データを渡す
        if segue.identifier == "goPostView" {
            
            let addControler = segue.destination as! AddController
            addControler.selectFlag = self.selctFlag
            addControler.targetShopData = self.targetShop
            
            //編集の際は編集対象のobjectIdと編集フラグ・編集対象のデータを設定する
            
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
        
        mbs.getShopList(latitude , longitude)
    }
    
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(_ manager: CLLocationManager,didFailWithError error: Error){
        print("locationManager error")
        myLocationManager.stopUpdatingLocation()
        
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

}
