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

class MyPostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
    
    //対象MeMoのobjectID
    var targetMemoObjectId: String!
    
    //参照している配列の場所
    var targetNum: Int = Int()
    
    //対象メモ
    var targetMemo: memo = memo()
    
    //会員情報管理
    let userInfo = NCMBUser.current()!
    
    // 画像
    let star_on = UIImage(named: "myMenu_on")
    let star_off = UIImage(named: "myMenu_off")
    
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
                            self.presentError("エラー", userInfo["error"]!!)
                        } // error end
                        
                    } // userInfo ned
                    
                } else {
                    
                    self.mbs.getUserPost(self.userData.object(forKey: "userID") as! String)
                    self.postTable.reloadData()
                    
                }// notification error end
                
        } // using end
        ) // loadDataObserver end
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // 位置情報の更新を開始.
        if mbs.postMenu.count == 0 {
            if let userID = userData.object(forKey: "userID"){
                mbs.getUserPost(userID as! String)
                print("なう")
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
        
        //自動計算の場合は必要
        
        self.postTable.estimatedRowHeight = 450.0
        
        self.postTable.rowHeight = UITableViewAutomaticDimension
        
        //ドロワーメニュー
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.revealViewController().rearViewRevealWidth = 200
        
        
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
        
        //各値をセルに入れる
        let targetMemoData: memo = mbs.postMenu[(indexPath as NSIndexPath).row]
        print(targetMemoData)
        
        // objectID,fileNamの保存と隠し
        cell!.objectID.text = targetMemoData.objectID
        cell!.objectID.isHidden = true
        cell!.fileName.text = targetMemoData.filename
        cell!.fileName.isHidden = true
        
        cell!.shopName.text = targetMemoData.shopName
        cell!.menuName.text = targetMemoData.menuName
        cell!.menuCost.text = "¥\(targetMemoData.menuMoney)"
        cell!.menuImage.image = #imageLiteral(resourceName: "loading")
        cell!.userImage.image = #imageLiteral(resourceName: "loading")
        
        //お気に入りに入っていれば星をon
        if Favorite.inFavorites(targetMemoData.filename) {
            cell!.favButton.setImage(star_on, for: .normal)
        } else {
            cell!.favButton.setImage(star_off, for: .normal)
        }
        
        if let image = targetMemoData.menuImage {
            cell!.menuImage.image = image
        } else {
            
            let filename: String = targetMemoData.filename
            let fileData = NCMBFile.file(withName: filename, data: nil) as! NCMBFile
            
            fileData.getDataInBackground {
                (imageData, error) -> Void in
                
                if error != nil {
                    print("写真の取得失敗: \(error)")
                } else {
                    cell!.menuImage.image = UIImage(data: imageData!)
                    self.mbs.postMenu[(indexPath as NSIndexPath).row].menuImage = UIImage(data: imageData!)
                }
            }
        }
        
        //3個先まで画像を事前に取得
        getCellImage((indexPath as NSIndexPath).row + 2)
        getCellImage((indexPath as NSIndexPath).row + 3)
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.none
        cell!.accessoryType = UITableViewCellAccessoryType.none
        
        print(targetMemoData)
        
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
            let filename: String = mbs.postMenu[index].filename
            let fileData = NCMBFile.file(withName: filename, data: nil) as! NCMBFile
            
            fileData.getDataInBackground {
                (imageData, error) -> Void in
                
                if error != nil {
                    print("写真の取得失敗: \(error)")
                } else {
                    self.mbs.postMenu[index].menuImage = UIImage(data: imageData!)
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
