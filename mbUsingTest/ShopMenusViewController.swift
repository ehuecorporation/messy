//
//  ShopMenusViewController.swift
//  mbUsingTest
//
//  Created by 松本匡平 on 2016/11/04.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB

class ShopMenusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var menuList: UITableView!
    
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    //NCMBAPIの利用
    public var mbs: NCMBSearch = NCMBSearch()
    
    //NotificcationのObserver
    var loadDataObserver: NSObjectProtocol?
    var refreshObserver: NSObjectProtocol?
    
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
    
    var targetShopData: shop = shop()
    
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
                            
                            let alertView = UIAlertController(
                                title: "通信エラー",
                                message: "通信エラーが発生しました",
                                preferredStyle: .alert
                            )
                            
                            alertView.addAction(
                                UIAlertAction(title: "OK", style: .default){
                                    action in return
                                }
                            )
                            
                            self.present(alertView, animated: true, completion: nil)
                            
                        } // error end
                        
                    } // userInfo ned
                    
                } else {
                    self.menuList.reloadData()
                    self.mbs.getShopMenu(self.targetShopData.shopNumber)
                }// notification error end
                
            } // using end
        ) // loadDataObserver end
        
        if mbs.shopMenu.count == 0 {
            //通常の検索
            mbs.getShopMenu(targetShopData.shopNumber)
        } else {
            self.menuList.reloadData()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //お気に入りを読み込み
        Favorite.load()
        
        navigationTitle.title = "提供メニュー"
        
        //テーブルビューのデリゲート
        self.menuList.delegate = self
        self.menuList.dataSource = self
        
        //Xibのクラスを読み込む
        let nib: UINib = UINib(nibName: "MemoCell", bundle:  Bundle(for: MemoCell.self))
        self.menuList.register(nib, forCellReuseIdentifier: "MemoCell")
        
        //ドロワーメニュー
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        
        //自動計算の場合は必要
        
        self.menuList.estimatedRowHeight = 450.0
        
        self.menuList.rowHeight = UITableViewAutomaticDimension
        
        
        // Pull to Refreshコントロール初期化
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MainViewController.onRefresh(_:)), for: .valueChanged)
        self.menuList.addSubview(refreshControl)
        
        
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
        mbs.getShopMenu(targetShopData.shopNumber)
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
        if mbs.shopMenu.count > 0 {
            return mbs.shopMenu.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell") as? MemoCell
        
        //各値をセルに入れる
        let targetMemoData: memo = mbs.shopMenu[(indexPath as NSIndexPath).row]
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
                    self.mbs.shopMenu[(indexPath as NSIndexPath).row].menuImage = UIImage(data: imageData!)
                }
            }
        }
        
        //3セル先まで画像を事前に取得
        getCellImage((indexPath as NSIndexPath).row + 2)
        getCellImage((indexPath as NSIndexPath).row + 3)
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.none
        cell!.accessoryType = UITableViewCellAccessoryType.none
        
        print(targetMemoData)
        
        return cell!
    }
    
/*
    //セルをタップした場合に実行
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //セグエの実行時に値を渡す
        let targetMemo: memo = mbs.shopMenu[(indexPath as NSIndexPath).row]
        self.targetMemo = targetMemo
        
        self.editFlag = true
        performSegue(withIdentifier: "pushDetail", sender: targetMemo)
    }
*/
    //テーブルのセクションを設定する
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionCount
    }
    
    //セルの画像を取得
    func getCellImage(_ index: Int){
        
        if index < mbs.shopMenu.count {
            if mbs.shopMenu[index].menuImage != nil {
                return
            }
            let filename: String = mbs.shopMenu[index].filename
            let fileData = NCMBFile.file(withName: filename, data: nil) as! NCMBFile
            
            fileData.getDataInBackground {
                (imageData, error) -> Void in
                
                if error != nil {
                    print("写真の取得失敗: \(error)")
                } else {
                    self.mbs.shopMenu[index].menuImage = UIImage(data: imageData!)
                }
            }
        }
        
    } // getCellImage end
    
    /*
     func setname() {
     if let userName = userData.object(forKey: "Name") {
     
     } else {
     userData.set("\(userInfo.userName!)", forKey: "Name")
     
     
     }
     }
     */
    
    //segueを呼び出したときに呼ばれるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    


}

