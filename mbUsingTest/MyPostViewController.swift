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

class MyPostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var postTable: UITableView!
    
    @IBAction func goAdd(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goAdd", sender: nil)
    }
    
    //NCMBAPIの利用
    public var mbs: NCMBSearch = NCMBSearch()
    
    //NotificcationのObserver
    var loadDataObserver: NSObjectProtocol?
    var refreshObserver: NSObjectProtocol?
    
    
    // APIカウント
    var apiCounter = 0
    
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
        NotificationCenter.default.removeObserver(self.loadDataObserver)
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
        
        //メニュー画像のぐるぐる
        let indicatorOfImage = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicatorOfImage.color = UIColor.gray
        let w = indicatorOfImage.frame.size.width
        let h = indicatorOfImage.frame.size.height
        // 画面の中央に表示するようにframeを変更する
        indicatorOfImage.frame = CGRect(origin: CGPoint(x: cell!.menuImage.frame.size.width/2 - w/2, y: cell!.menuImage.frame.size.height/2 - h/2), size: CGSize(width: indicatorOfImage.frame.size.width, height:  indicatorOfImage.frame.size.height))
        
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
        cell!.menuImage.image = nil
        cell!.menuImage.addSubview(indicatorOfImage)
        indicatorOfImage.startAnimating()
        
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
            cell!.favButton.setImage(star_on, for: .normal)
        } else {
            cell!.favButton.setImage(star_off, for: .normal)
        }
        
        // メニュー画像の取得
        if let image = targetMemoData.menuImage {
            indicatorOfImage.stopAnimating()
            cell!.menuImage.image = image
        } else {
            getCellImage((indexPath as NSIndexPath).row)
        }
        
        //3個先まで画像を事前に取得
        getCellImage((indexPath as NSIndexPath).row + 2)

        
        cell!.selectionStyle = UITableViewCellSelectionStyle.none
        cell!.accessoryType = UITableViewCellAccessoryType.none
                
        return cell!
    }
    
    //セルをタップした場合に実行
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //セグエの実行時に値を渡す
        let targetMemo: memo = mbs.postMenu[(indexPath as NSIndexPath).row]
        self.targetMemo = targetMemo
        
        self.editFlag = true
//       performSegue(withIdentifier: "pushDetail", sender: targetMemo)
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
                    print("写真の取得失敗: \(error)")
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
            print("長押しされたcellのindexPath:\(indexPath?.row)")
            
            let errorAlert = UIAlertController(
                title: "メニューをシェア",
                message: "シェアしたいSNSを選択してください",
                preferredStyle: UIAlertControllerStyle.alert
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
                    handler: nil
                )
            )
            
            errorAlert.addAction(
                UIAlertAction(
                    title: "キャンセル",
                    style: UIAlertActionStyle.default,
                    handler: nil
                )
            )
            
            self.present(errorAlert, animated: true, completion: nil)
            
        }
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
            UIApplication.shared.openURL( messageURL as URL)
        }
    }
    
    func shareInstagram(_ ac:UIAlertAction) -> Void {
        let imageData = UIImageJPEGRepresentation(self.targetMemo.menuImage!, 1.0)
        
        let temporaryDirectory = URL(string: NSTemporaryDirectory())
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
    
    //segueを呼び出したときに呼ばれるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //詳細画面へ行く前に詳細データを渡す
        if segue.identifier == "pushDetail" {
            
            let InfoController = segue.destination as! InfoViewController
            InfoController.targetMemo = self.targetMemo
            
            //編集の際は編集対象のobjectIdと編集フラグ・編集対象のデータを設定する
            
        }
    }
    
}
