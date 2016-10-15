//
//  ViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/09/11.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import  NCMB

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // 一覧表示テーブルビュー
    @IBOutlet weak var memoTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //新規追加時
    @IBAction func addMemo(_ sender: UIBarButtonItem) {
        
        self.editFlag = false
        performSegue(withIdentifier: "goAddMemo", sender: nil)
        
    }
    
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
    
    //会員情報管理
    let userInfo = NCMBUser.current()!
    
    //更新受信フラグ
    var updateFlag: Bool = false

    //ユーザー情報
    var userName: String = ""
    var userData = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setname()
        
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
                    self.memoTableView.reloadData()
                }// notification error end
                
            } // using end
        ) // loadDataObserver end
        
        if mbs.memos.count == 0 {
            //通常の検索
            mbs.loadMemoData(true)
        }
        
        //リストの更新があった場合
        if updateFlag {
            mbs.reLoadData()
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //テーブルビューのデリゲート
        self.memoTableView.delegate = self
        self.memoTableView.dataSource = self
        
        //Xibのクラスを読み込む
        let nib: UINib = UINib(nibName: "MemoCell", bundle:  Bundle(for: MemoCell.self))
        self.memoTableView.register(nib, forCellReuseIdentifier: "MemoCell")
        
        //自動計算の場合は必要
        
        self.memoTableView.estimatedRowHeight = 450.0
        self.memoTableView.rowHeight = UITableViewAutomaticDimension
        
//        titleLabel.text = "\(userInfo.userName!)さんのページです"
        
        // Pull to Refreshコントロール初期化
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.onRefresh(_:)), for: .valueChanged)
        self.memoTableView.addSubview(refreshControl)

        
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
            mbs.reLoadData()
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
        if mbs.memos.count > 0 {
            return mbs.memos.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell") as? MemoCell
        
        //各値をセルに入れる
        let targetMemoData: memo = mbs.memos[(indexPath as NSIndexPath).row]
        print(targetMemoData)
        
        cell!.shopName.text = targetMemoData.memoTitle
        cell!.menuCost.text = targetMemoData.memoMoney
        cell!.menuName.text = targetMemoData.memoComment
        cell!.menuImage.image = #imageLiteral(resourceName: "loading")
        cell!.userImage.image = #imageLiteral(resourceName: "loading")
        
        if let image = targetMemoData.memoImage {
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
                    self.mbs.memos[(indexPath as NSIndexPath).row].memoImage = UIImage(data: imageData!)
                }
            }
        }
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.none
        cell!.accessoryType = UITableViewCellAccessoryType.none
        
        print(targetMemoData)
        
        return cell!
    }

    //セルをタップした場合に実行
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //セグエの実行時に値を渡す
        let targetMemoData: memo = mbs.memos[(indexPath as NSIndexPath).row]
        targetNum = (indexPath as NSIndexPath).row
        
        self.editFlag = true
        performSegue(withIdentifier: "goAddMemo", sender: targetMemoData)
    }
    
    //テーブルのセクションを設定する
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionCount
    }
    
    func setname() {
        if let userName = userData.object(forKey: "Name") {
            titleLabel.text = "\(userName)さんのページ"
        } else {
            userData.set("\(userInfo.userName!)", forKey: "Name")
            titleLabel.text = "\(userData.object(forKey: "Name")!)さんのページ"
            
        }
    }
    
    
    //segueを呼び出したときに呼ばれるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //コメント表示画面へ行く前に詳細データを渡す
        if segue.identifier == "goAddMemo" {
            
            let addController = segue.destination as! AddController
            
            //編集の際は編集対象のobjectIdと編集フラグ・編集対象のデータを設定する
            if self.editFlag == true {
                addController.editFlag = self.editFlag
                addController.targetData = sender as! memo
                addController.targetNum = self.targetNum
            }
        }
    }
    
    
}

