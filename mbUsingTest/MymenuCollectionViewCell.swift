//
//  MymenuCollectionViewCell.swift
//  mbUsingTest
//
//  Created by 松本匡平 on 2016/10/21.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB
import Social
import SWRevealViewController

class MymenuCollectionViewCell: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate{
    
    @IBOutlet weak var menuList: UICollectionView!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBAction func reLoadButton(_ sender: UIBarButtonItem) {
        mbs.getFavList(Favorite.favorites)
    }
    var userData = UserDefaults.standard
    var targetNum = 0
    var mbs : NCMBSearch = NCMBSearch()
    var targetMemo: memo = memo()
    
    // instagramShare用
    var documentInteractionController = UIDocumentInteractionController()
    
    //NotificcationのObserver
    var loadDataObserver: NSObjectProtocol?
    var refreshObserver: NSObjectProtocol?
    
    let user = NCMBUser.current()
    
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
        if Favorite.favorites.count == 0 {
            presentError("お気に入りがありません", "お気に入りメニューを\n登録しましょう！")
        } else {
            mbs.getFavList(Favorite.favorites)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //ドロワーメニュー
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // セルサイズをあらかじめ指定
        menuList.contentSize = CGSize(width: self.view.frame.size.width/2 - 2.5, height: self.view.frame.size.width/2 - 2.5)
        
        // 長押し処理の追加
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.delegate = self
        longPressRecognizer.addTarget(self, action: #selector(MymenuCollectionViewCell.cellLongPressed(recognizer:)))
        menuList.addGestureRecognizer(longPressRecognizer)

    
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        // Cell はストーリーボードで設定したセルのID
        let testCell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "mymenuItem", for: indexPath)
        
        let targetMemoData :memo = mbs.favList[(indexPath as NSIndexPath).row]
        
        // Tag番号を使ってLabelのインスタンス生成
        let label = testCell.contentView.viewWithTag(2) as! UILabel
        label.text! = targetMemoData.menuName
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        
        // 画像の読み込み
        if let image = targetMemoData.menuImage {
            imageView.image = image
        } else {
            
            let filename: String = targetMemoData.filename
            let fileData = NCMBFile.file(withName: filename, data: nil) as! NCMBFile
            
            fileData.getDataInBackground {
                (imageData, error) -> Void in
                
                if error != nil {
                    print("写真の取得失敗: \(String(describing: error))")
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
        // [indexPath.row] から画像名を探し、UImage を設定
        targetMemo = mbs.favList[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: "pushDetailFromMyMenu",sender: nil)
    }
    
    // 長押し
    func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        let point: CGPoint = recognizer.location(in: self.menuList)
        let indexPaths = menuList.indexPathForItem(at: point)
        let indexPath = (indexPaths?.row)! + (indexPaths?.section)! * 2
        self.targetMemo = mbs.favList[indexPath]
        
        if recognizer.state == UIGestureRecognizerState.began  {
            // 長押しされた場合の処理
            print("長押しされたcellのindexPath:\(indexPath)")
            
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
                    title: "お気に入りから削除",
                    style: UIAlertActionStyle.destructive,
                    handler: self.removeFav
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
    
    // Screenサイズに応じたセルサイズを返す
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
        return mbs.favList.count;
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
    
    // SNSシェアの各挙動
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
            from: self.menuList.bounds,
            in: self.menuList,
            animated: true
        )
    }
    
    func removeFav(_ ac:UIAlertAction) -> Void {
        // お気に入りはファイル名で管理
        Favorite.remove(targetMemo.filename)
        
        // cloud上のfavListの更新
        let tmpFav = Favorite.favorites
        user?.setObject(tmpFav, forKey: "favList")
        user?.saveInBackground({(error) in
            if error == nil {
                print("cloud上に保存")
            }
        })
        
        reLoadButton(UIBarButtonItem.init())
    
        presentError("削除完了", "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //segueを呼び出したときに呼ばれるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //詳細画面へ行く前に詳細データを渡す
        if segue.identifier == "pushDetailFromMyMenu" {
            
            let InfoController = segue.destination as! ShopInfoViewController
            InfoController.targetMemo = self.targetMemo
            
        }
    }
    
}
