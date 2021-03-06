//
//  MyPostViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/11/28.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB
import SWRevealViewController
import Social

class MyPostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var postTable: UITableView!
    
    @IBAction func goAdd(_ sender: UIBarButtonItem) {
        self.editFlag = false
        let errorAlert = UIAlertController(
            title: "投稿画面へ移動",
            message: "近隣の店舗を取得できます",
            preferredStyle: UIAlertControllerStyle.actionSheet
        )
        errorAlert.addAction(
            UIAlertAction(
                title: "投稿画面へ",
                style: UIAlertActionStyle.default,
                handler: self.goAddView
            )
        )
        errorAlert.addAction(
            UIAlertAction(
                title: "現在地から取得",
                style: UIAlertActionStyle.default,
                handler: self.goShopListView
            )
        )
        errorAlert.addAction(
            UIAlertAction(
                title: "キャンセル",
                style: UIAlertActionStyle.cancel,
                handler: nil
            )
        )
        
        self.present(errorAlert, animated: true, completion: nil)

    }
    
    //NCMBAPIの利用
    public var mbs: NCMBSearch = NCMBSearch()
    
    //NotificcationのObserver
    var loadDataObserver: NSObjectProtocol?
    var refreshObserver: NSObjectProtocol?
    
    // APIカウント
    var apiCounter = 0
    var firstAppear = true
    
    //コメント編集フラグ
    var editFlag: Bool = false
    
    //更新フラグ
    var refreshFlag: Bool = false
    
    //テーブルビューの要素数
    let sectionCount: Int = 1
    
    // テーブル再描画回数を制限
    var reloadCount = 0
    
    //対象MeMoのobjectID
    var targetMemoObjectId: String!
    
    //参照している配列の場所
    var targetNum: Int = Int()
    
    //対象メモ
    var targetMemo: memo = memo()
    
    // 画像
    let star_on = UIImage(named: "myMenu_on")
    let star_off = UIImage(named: "myMenu_off")
    
    // instagramShare用
    var documentInteractionController = UIDocumentInteractionController()
    
    //ユーザー情報
    var userData = UserDefaults.standard
    
    var myLocationManager: CLLocationManager!
    // 取得した緯度を保持するインスタンス
    var latitude: Double = Double()
    // 取得した経度を保持するインスタンス
    var longitude: Double = Double()

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
                            if userInfo["error"]! == "" {
                                self.presentError("まだ投稿がありません", "投稿画面からメニューを投稿して見ましょう！")
                            }
                            self.presentError("エラー", userInfo["error"]!!)
                        } // error end
                        
                    } // userInfo ned
                    
                } else {
                    self.postTable.reloadData()
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
        if firstAppear {
            myLocationManager.startUpdatingLocation()
            firstAppear = false
        }
        
        // 投稿一覧の取得
        if mbs.postMenu.count == 0 {
            if let userID = userData.object(forKey: "userID"){
                mbs.getUserPost(userID as! String)
            }
        } else {
            self.postTable.reloadData()
        }
        
        //お気に入りを読み込み
        Favorite.load()
        Like.load()
        
        //テーブルビューのデリゲート
        self.postTable.delegate = self
        self.postTable.dataSource = self
        
        //Xibのクラスを読み込む
        let nib: UINib = UINib(nibName: "MemoCell", bundle:  Bundle(for: MemoCell.self))
        self.postTable.register(nib, forCellReuseIdentifier: "MemoCell")
        
        //セルの高さを設定
        self.postTable.rowHeight = self.view.frame.size.width + 120
        
        self.postTable.tableFooterView = UIView(frame: .zero)
        
        //ドロワーメニュー
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // 左メニューの幅
        self.revealViewController().rearViewRevealWidth = 200
        
        // UILongPressGestureRecognizer宣言
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.addTarget(self, action: #selector(MainViewController.cellLongPressed(recognizer:)))
        
        // `UIGestureRecognizerDelegate`を設定するのをお忘れなく
        longPressRecognizer.delegate = self
        
        // tableViewにrecognizerを設定
        postTable.addGestureRecognizer(longPressRecognizer)
        
        
        // Pull to Refreshコントロール初期化
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MainViewController.onRefresh(_:)), for: .valueChanged)
        self.postTable.addSubview(refreshControl)
        
        
    }
    
    // Pull to Refresh
    func onRefresh(_ refreshControl: UIRefreshControl){
        // UIRefreshControlを読込状態にする
        refreshControl.beginRefreshing()
        // 終了通知を受信したらUIRefreshControlを停止する
        refreshObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: mbs.NCMBLoadCompleteNotification),
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
        mbs.getUserPost(userData.object(forKey: "userID") as! String)
        refreshFlag = false
        
    } // onRefresh end
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //通知待受を終了
        NotificationCenter.default.removeObserver(self.loadDataObserver!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // テーブルの要素数を設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //取得データの総数
        if mbs.postMenu.count > 0 {
            return mbs.postMenu.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell") as? MemoCell
        //各値をセルに入れる
        let targetMemoData: memo = mbs.postMenu[(indexPath as NSIndexPath).row]
        print(targetMemoData)
        
        //隠しておく要素
        cell!.objectID.text = targetMemoData.objectID
        cell!.objectID.isHidden = true
        cell!.fileName.text = targetMemoData.filename
        cell!.fileName.isHidden = true
        
        //表示する要素
        cell!.shopName.text = "# "+targetMemoData.shopName
        cell!.menuName.text = targetMemoData.menuName
        cell!.updateDate.text = targetMemoData.updateDate
        cell!.menuCost.text = "¥\(targetMemoData.menuMoney)"
        cell!.favoriteCounter.text = "\(targetMemoData.favoriteCounter)"
        cell!.lookCounter.text = "\(targetMemoData.lookCounter)"
        cell!.likeCounter.text = "\(targetMemoData.likeCounter)"
        cell!.menuImage.image = #imageLiteral(resourceName: "loading")
        
        if latitude != 0 {
            // 距離の計算
            let destination : CLLocation = CLLocation(latitude: targetMemoData.geoPoint.latitude,longitude: targetMemoData.geoPoint.longitude)
            let department: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
            let d = destination.distance(from: department)
            cell!.shopGeo.text = "\(round(d/10)/100)km"
        } else {
            // 位置情報がなければ隠す
            cell!.shopGeo.isHidden = true
            cell!.shopGeoLabel.isHidden = true
        }

        
        // menuHoursに従って色分け
        if targetMemoData.menuHours == 0 {
            cell!.hoursIcon.image = #imageLiteral(resourceName: "morningIcon")
        } else if targetMemoData.menuHours == 1 {
            cell!.hoursIcon.image = #imageLiteral(resourceName: "lunchIcon")
        } else {
            cell!.hoursIcon.image = #imageLiteral(resourceName: "dinerIcon")
        }

        
        if let icon = userData.object(forKey: "userIcon") {
            let image: UIImage = UIImage(data: (icon as! NSData) as Data)!
            cell!.userImage.image = image
        }
        
        //お気に入りに入っていれば星をon
        if Favorite.inFavorites(targetMemoData.filename) {
            cell!.favoriteButton.setImage(star_on, for: .normal)
        } else {
            cell!.favoriteButton.setImage(star_off, for: .normal)
        }
        //Likeに入っていればハートをon
        if Like.inLikes(targetMemoData.filename) {
            cell!.likeButton.setImage(#imageLiteral(resourceName: "like_on"), for: .normal)
        } else {
            cell!.likeButton.setImage(#imageLiteral(resourceName: "like_off"), for: .normal)
        }
        
        // メニュー画像の取得
        if let image = targetMemoData.menuImage {
            cell!.menuImage.image = image
        } else {
            getCellImage((indexPath as NSIndexPath).row)
        }
        
        //3個先まで画像を事前に取得
        getCellImage((indexPath as NSIndexPath).row + 4)

        
        cell!.selectionStyle = UITableViewCellSelectionStyle.none
        cell!.accessoryType = UITableViewCellAccessoryType.none
                
        return cell!
    }
    
    // セルの高さを設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let targetMemoData: memo = mbs.postMenu[(indexPath as NSIndexPath).row]
        let imageHeight = targetMemoData.menuImage?.size.height
        let imageWidth = targetMemoData.menuImage?.size.width
        if targetMemoData.menuImage != nil && imageHeight != nil && imageWidth != nil{
            let aspect = Double(imageHeight!)/Double(imageWidth!)
            let height = Double(self.view.frame.size.width)*aspect
            return CGFloat(height) + 115
        } else {
            let aspect = Double(#imageLiteral(resourceName: "loading").size.height)/Double(#imageLiteral(resourceName: "loading").size.width)
            let height = Double(self.view.frame.size.width)*aspect
            return CGFloat(height) + 95
        }
    }

    
    //セルをタップした場合に実行
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //セグエの実行時に値を渡す
        let targetMemo: memo = mbs.postMenu[(indexPath as NSIndexPath).row]
        self.targetMemo = targetMemo
        
        performSegue(withIdentifier: "pushDetail", sender: targetMemo)
    }
    
    //テーブルのセクションを設定する
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionCount
    }
    
    //セルの画像を取得
    func getCellImage(_ index: Int){
        
        if index < mbs.postMenu.count {
            if mbs.postMenu[index].menuImage != nil {
                return
            }
            let filename: String = mbs.postMenu[index].filename
            let fileData = NCMBFile.file(withName: filename, data: nil) as! NCMBFile
            
            fileData.getDataInBackground {
                (imageData, error) -> Void in
                
                if error != nil {
                    print("写真の取得失敗: \(String(describing: error))")
                } else {
                    self.mbs.postMenu[index].menuImage = UIImage(data: imageData!)
                    self.reloadCount += 1
                    if self.reloadCount % 2 == 0 {
                        self.postTable.reloadData()
                    }
                }
            }
            apiCounter += 1
            print("API通信回数\(apiCounter)")
        }
        
    } // getCellImage end
    
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
    
    /* 長押しした際に呼ばれるメソッド */
    func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        
        // 押された位置でcellのPathを取得
        let point = recognizer.location(in: postTable)
        let indexPath = postTable.indexPathForRow(at: point)
        self.targetMemo = mbs.postMenu[((indexPath)?.row)!]
        
        if indexPath == nil {
            
        } else if recognizer.state == UIGestureRecognizerState.began  {
            // 長押しされた場合の処理
            print("長押しされたcellのindexPath:\(String(describing: indexPath?.row))")
            
            let errorAlert = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: UIAlertControllerStyle.actionSheet
            )
            errorAlert.addAction(
                UIAlertAction(
                    title: "Twitter",
                    style: UIAlertActionStyle.default,
                    handler: self.shareTwitter
                )
            )
            errorAlert.addAction(
                UIAlertAction(
                    title: "Facebook",
                    style: UIAlertActionStyle.default,
                    handler: self.sharefacebook
                )
            )
            errorAlert.addAction(
                UIAlertAction(
                    title: "LINE",
                    style: UIAlertActionStyle.default,
                    handler: self.shareLine
                )
            )
            errorAlert.addAction(
                UIAlertAction(
                    title: "Instagram",
                    style: UIAlertActionStyle.default,
                    handler: self.shareInstagram
                )
            )
            errorAlert.addAction(
                UIAlertAction(
                    title: "投稿を修正",
                    style: UIAlertActionStyle.default,
                    handler: self.edit
                )
            )
            
            errorAlert.addAction(
                UIAlertAction(
                    title: "キャンセル",
                    style: UIAlertActionStyle.cancel,
                    handler: nil
                )
            )
            
            self.present(errorAlert, animated: true, completion: nil)
            
        }
    }
    
    // 選択されたアクションに応じて移動先を決定
    func goAddView(_ ac: UIAlertAction) -> Void {
        performSegue(withIdentifier: "goAdd", sender: nil)
    }
    func goShopListView(_ ac: UIAlertAction) -> Void {
        performSegue(withIdentifier: "goShopList", sender: nil)
    }

    
    // アクションシートに応じた処理
    func shareTwitter(_ ac: UIAlertAction) -> Void {
        let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        vc?.setInitialText(self.targetMemo.shopName + "\n" + self.targetMemo.menuName + "\n")
        if self.targetMemo.menuImage != nil {
            vc?.add(self.targetMemo.menuImage)
        }
        
        self.present(vc!, animated: true, completion: nil)
        
    }
    func sharefacebook(_ ac: UIAlertAction) -> Void {
        let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        vc?.setInitialText(self.targetMemo.shopName + "\n" + self.targetMemo.menuName + "\n")
        if self.targetMemo.menuImage != nil {
            vc?.add(self.targetMemo.menuImage)
        }
        
        self.present(vc!, animated: true, completion: nil)
        
    }
    func shareLine(_ ac: UIAlertAction) -> Void {
        var message = ""
        message += self.targetMemo.shopName + "\n"
        message += self.targetMemo.menuName + "\n"
        let encodeMessage: String! = message.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let messageURL: NSURL! = NSURL( string: "line://msg/text/" + encodeMessage )
        if (UIApplication.shared.canOpenURL(messageURL as URL)) {
            UIApplication.shared.open( messageURL as URL,options: [String:Int](),completionHandler: nil)
        }
    }
    func shareInstagram(_ ac:UIAlertAction) -> Void {
        let imageData = UIImageJPEGRepresentation(self.targetMemo.menuImage!, 1.0)
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("YourImageFileName.igo")
        try? imageData?.write( to: url!, options: .atomic)
        
        documentInteractionController.url = url
        documentInteractionController.uti = "com.instagram.exclusivegram"
        documentInteractionController.presentOpenInMenu(
            from: self.postTable.bounds,
            in: self.postTable,
            animated: true
        )
    }
    func edit(_ ac:UIAlertAction) -> Void{
        self.editFlag = true
        performSegue(withIdentifier: "goAdd", sender: nil)
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
        
        if !firstAppear {
            return
        }
        
        // 位置情報の保存
        let user = NCMBUser.current()
        if user != nil {
            let lastLocations = NCMBGeoPoint(latitude: latitude,longitude: longitude)
            var saveError: NSError? = nil
            user?.objectId = userData.object(forKey: "userID") as! String!
            user?.fetchInBackground({(error) in
                if (error == nil) {
                    print("保存")
                    user?.setObject(lastLocations, forKey: "lastLocations")
                    user?.save(&saveError)
                    if saveError == nil {
                        print("success save data.")
                    } else {
                        print("failure save data. \(String(describing: saveError))")
                    }
                } else {
//                    print(error?.localizedDescription)
                }
            })
        } // unwrap user

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
    
    //segueを呼び出したときに呼ばれるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //詳細画面へ行く前に詳細データを渡す
        if segue.identifier == "pushDetail" {
            let InfoController = segue.destination as! ShopInfoViewController
            InfoController.targetMemo = self.targetMemo
        }
        
        //投稿画面へ行く際に渡すデータ
        if segue.identifier == "goAdd" {
            let AddController = segue.destination as! AddController
            AddController.editFlag = self.editFlag
            AddController.targetData = targetMemo
        }
        
    }
    
}
