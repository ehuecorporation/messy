//
//  MymenuCollectionViewCell.swift
//  mbUsingTest
//
//  Created by 松本匡平 on 2016/10/21.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB

class MymenuCollectionViewCell: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var menuList: UICollectionView!
    
    var userData = UserDefaults.standard
    var targetNum = 0
    var mbs : NCMBSearch = NCMBSearch()
    var targetmemo = memo()
    
    //NotificcationのObserver
    var loadDataObserver: NSObjectProtocol?
    var refreshObserver: NSObjectProtocol?
    
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
                    self.targetNum = 0
                    self.menuList.reloadData()
                    print("読み込み完了")
                    print(self.mbs.favList)
                }// notification error end
                
            } // using end
        ) // loadDataObserver end
        
        Favorite.load()
        mbs.getFavList(Favorite.favorites)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // pull to refreshの実装
        let refreshControl = UIRefreshControl()
        //下に引っ張った時に、リフレッシュさせる関数を実行する。
        refreshControl.addTarget(self, action: #selector(MymenuCollectionViewCell.onRefresh(_:)), for: UIControlEvents.valueChanged)
        //UICollectionView上に、ロード中...を表示するための新しいビューを作る
        menuList.addSubview(refreshControl)
        
    }
    
    func onRefresh(_ refreshControl: UIRefreshControl) {
        
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
                
                
        }) // uisng block end
        
        // 通常のリフレッシュ
        mbs.reLoadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        // Cell はストーリーボードで設定したセルのID
        let testCell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "mymenuItem", for: indexPath)
        
        if mbs.favList.count == 0 {
            let label = testCell.contentView.viewWithTag(2) as! UILabel
            label.text! = "読み込み中"
            let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
            imageView.image = #imageLiteral(resourceName: "loading")
            return testCell
        }
        
        let targetMemoData :memo = mbs.favList[(indexPath as NSIndexPath).row]
        
        // Tag番号を使ってLabelのインスタンス生成
        let label = testCell.contentView.viewWithTag(2) as! UILabel
        label.text! = targetMemoData.shopName
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        imageView.image = #imageLiteral(resourceName: "loading")
        
        // 画像の読み込み
        if let image = targetMemoData.menuImage {
            imageView.image = image
        } else {
            
            let filename: String = targetMemoData.filename
            let fileData = NCMBFile.file(withName: filename, data: nil) as! NCMBFile
            
            fileData.getDataInBackground {
                (imageData, error) -> Void in
                
                if error != nil {
                    print("写真の取得失敗: \(error)")
                } else {
                    imageView.image = UIImage(data: imageData!)
                    self.mbs.favList[(indexPath as NSIndexPath).row].menuImage = UIImage(data: imageData!)
                }
            }
        }
        
        return testCell
    }
    
    // Cell が選択された場合
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if Favorite.favorites.count == 0 {
            return
        }
        
        // [indexPath.row] から画像名を探し、UImage を設定
        targetmemo = mbs.favList[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: "pushDetailFromMyMenu",sender: nil)
        
    }
    
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize:CGFloat = self.view.frame.size.width/2 - 2.5
        // 正方形で返すためにwidth,heightを同じにする
        return CGSize(width: cellSize, height: cellSize)
        
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる

        return Favorite.favorites.count;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //segueを呼び出したときに呼ばれるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //詳細画面へ行く前に詳細データを渡す
        if segue.identifier == "pushDetailFromMyMenu" {
            
            let InfoController = segue.destination as! InfoViewController
            InfoController.targetMemo = self.targetmemo
            
            //編集の際は編集対象のobjectIdと編集フラグ・編集対象のデータを設定する
            
        }
    }

    
    
}
