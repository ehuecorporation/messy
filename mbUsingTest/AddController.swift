//
//  AddController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/09/26.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB
import Social

class AddController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate{
    
    @IBAction func hideKeybord(_ sender: UITapGestureRecognizer) {
            self.view.endEditing(true)
    }
    
    //ユーザーデータ
    var userData = UserDefaults.standard
    
    //更新・追加・削除用のメンバ変数
    var targetShopName: String = ""
    var targetMenuName: String = ""
    var targetMenuPrice: String = ""
    var targetHousrs: Int? = nil
    var targetDisplayImage: UIImage? = nil

    //編集フラグ
    var editFlag: Bool = false
    
    //店舗セレクトフラグ
    var selectFlag: Bool = false
    
    //更新フラグ
    var updateFlag: Bool = false
    
    //編集対象メモのobjectId
    var targetMemoObjectId: String = ""
    
    //メモリスト
    var mbs: NCMBSearch = NCMBSearch()
    
    //編集対象メモのfilename
    var targetFileName: String = ""
    
    //MyPostViewViewController.swiftから渡されたデータ
    var targetData: memo = memo()
    
    //ShopListTableから渡される値
    var targetShopData: shop = shop()
    
    @IBOutlet weak var shopName: UITextField!
    @IBOutlet weak var menuName: UITextField!
    @IBOutlet weak var menuPrice: UITextField!
    @IBOutlet weak var displayImage: UIImageView!

    @IBOutlet weak var morningButton: UIButton!
    @IBOutlet weak var lunchButton: UIButton!
    @IBOutlet weak var dinerButton: UIButton!
    
    @IBAction func selctMorning(_ sender: UIButton) {
        
        // 選択済みなら選択解除
        if let selcted = targetHousrs {
            if selcted == 0 {
                targetHousrs = nil
                morningButton.backgroundColor = UIColor.white
                morningButton.setTitleColor(UIColor.black, for: .normal)
                return
            }
        }
        
        // モーニングなら0
        targetHousrs = 0
        
        // 色を変える
        morningButton.backgroundColor = UIColor.init(red: 220/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1.0)
        morningButton.setTitleColor(UIColor.white, for: .normal)
        lunchButton.backgroundColor = UIColor.white
        lunchButton.setTitleColor(UIColor.black, for: .normal)
        dinerButton.backgroundColor = UIColor.white
        dinerButton.setTitleColor(UIColor.black, for: .normal)
    }
    
    @IBAction func selctLunch(_ sender: UIButton) {
        
        // 選択済みなら選択解除
        if let selcted = targetHousrs {
            if selcted == 1 {
                targetHousrs = nil
                lunchButton.backgroundColor = UIColor.white
                lunchButton.setTitleColor(UIColor.black, for: .normal)
                return
            }
        }
        
        // ランチなら1
        targetHousrs = 1
        
        // 色を変える
        morningButton.backgroundColor = UIColor.white
        morningButton.setTitleColor(UIColor.black, for: .normal)
        lunchButton.backgroundColor = UIColor.init(red: 253/255.0, green: 147/255.0, blue: 10/255.0, alpha: 0.75)
        lunchButton.setTitleColor(UIColor.white, for: .normal)
        dinerButton.backgroundColor = UIColor.white
        dinerButton.setTitleColor(UIColor.black, for: .normal)
    }
    
    @IBAction func selctDiner(_ sender: UIButton) {
        
        // 選択済みなら選択解除
        if let selcted = targetHousrs {
            if selcted == 2 {
                targetHousrs = nil
                dinerButton.backgroundColor = UIColor.white
                dinerButton.setTitleColor(UIColor.black, for: .normal)
                return
            }
        }
        
        // ディナーなら2
        targetHousrs = 2
        
        // 色を変える
        // 色を変える
        morningButton.backgroundColor = UIColor.white
        morningButton.setTitleColor(UIColor.black, for: .normal)
        lunchButton.backgroundColor = UIColor.white
        lunchButton.setTitleColor(UIColor.black, for: .normal)
        dinerButton.backgroundColor = UIColor.init(red: 102/255.0, green: 119/255.0, blue: 238/255.0, alpha: 0.75)
        dinerButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    @IBAction func addMemo(_ sender: UIBarButtonItem) {
        
        //バリデーションを通す前の準備
        self.targetShopName = self.shopName.text!
        self.targetMenuName = self.menuName.text!
        self.targetMenuPrice = self.menuPrice.text!
        self.targetDisplayImage = self.displayImage.image
        
        //情報が不十分の時エラーアラートを表示
        if (self.targetShopName.isEmpty || self.targetMenuName.isEmpty || self.targetMenuPrice.isEmpty || self.targetDisplayImage == nil || self.targetHousrs == nil) {
            
            presentError("エラー", "入力内容にエラーがあります")
            
        } else {
            
            //保存対象の画像ファイルを作成する
            let imageData: Data = UIImagePNGRepresentation(self.targetDisplayImage!)!
            let targetFile = NCMBFile.file(with: imageData) as! NCMBFile
            
            //NCMBへデータを登録。編集する
            if self.editFlag == true {
                
                //既存データの更新
                var saveError: NSError? = nil
                let obj: NCMBObject = NCMBObject(className: "MemoClass")
                obj.objectId = self.targetMemoObjectId
                obj.fetchInBackground({
                    (error)
                    in
                    
                    if (error == nil) {
                        
                        obj.setObject(self.targetShopName, forKey: "shopName")
                        obj.setObject(self.targetMenuPrice, forKey: "menuPrice")
                        obj.setObject(self.targetMenuName, forKey: "menuName")
                        obj.setObject(targetFile.name, forKey: "filename")
                        obj.setObject(self.userData.object(forKey: "userID")!, forKey: "postUser")
                        obj.save(&saveError)
                    } else {
                        self.presentError("登録エラー", "\(error!.localizedDescription)")
                    }
                    
                    if targetFile.name != self.targetFileName {
                        
                        targetFile.saveInBackground({
                            (error) -> Void in
                            
                            if error == nil {
                                print("画像データ保存完了: \(targetFile.name)")
                            } else {
                                self.self.presentError("画像アップロードエラー", "\(error!.localizedDescription)")
                            }
                            
                            }, progressBlock: { (percentDone: Int32) -> Void in
                                
                                // 進捗状況を取得します。保存完了まで何度も呼ばれます
                                print("進捗状況: \(percentDone)% アップロード済み")
                        })
                    }
                    
                    if saveError == nil {
                        print("success save data.")
                    } else {
                        print("failure save data. \(saveError)")
                    }
                    
                })
            } else if selectFlag {
                //新規データを一件登録する
                var saveError: NSError? = nil
                let obj: NCMBObject = NCMBObject(className: "MemoClass")
                obj.setObject(self.targetShopName, forKey: "shopName")
                obj.setObject(self.targetMenuPrice, forKey: "menuPrice")
                obj.setObject(self.targetMenuName, forKey: "menuName")
                obj.setObject(targetFile.name, forKey: "filename")
                obj.setObject(self.userData.object(forKey: "userID")!, forKey: "postUser")
                obj.setObject(self.targetHousrs!, forKey: "menuHours")
                obj.setObject(0 as Int, forKey: "lookCounter")
                obj.setObject(0 as Int, forKey: "favoriteCounter")
                obj.setObject(0 as Int, forKey: "likeCounter")
                obj.setObject(0 as Int, forKey: "reportCounter")
                obj.setObject(self.targetShopData.shopGeo as NCMBGeoPoint, forKey: "geoPoint")
                obj.setObject(self.targetShopData.shopNumber as Int, forKey: "shopNumber")
                obj.setObject(self.targetShopData.shopName as String, forKey: "shopName")
                obj.save(&saveError)
                
                //ファイルをバックグランドで実行
                targetFile.saveInBackground({
                    (error) -> Void in
                    
                    if error == nil {
                        print("画像データ保存完了: \(targetFile.name)")
                    } else {
                        self.presentError("登録エラー", "\(error!.localizedDescription)")
                    }
                }, progressBlock: {
                    (percentDone: Int32) -> Void
                    in
                    //進捗状況を終わるまで取得
                    print("進捗状況: \(percentDone)%アップロード済み")
                })
                
                if saveError == nil {
                    print("success save data.")
                } else {
                    print("failure save data.\(saveError)")
                }
                
                let errorAlert = UIAlertController(
                    title: "投稿完了",
                    message: "投稿が反映されるまでお待ち下さい",
                    preferredStyle: UIAlertControllerStyle.alert
                )
                errorAlert.addAction(
                    UIAlertAction(
                        title: "OK",
                        style: UIAlertActionStyle.default,
                        handler: self.saveComplete                    )
                )
                
                errorAlert.addAction(
                    UIAlertAction(
                        title: "投稿をSNSにシェア",
                        style: UIAlertActionStyle.default,
                        handler: self.socialShare                   )
                )

                
                self.present(errorAlert, animated: true, completion: nil)
                
            } else {
                
                //新規データを一件登録する
                var saveError: NSError? = nil
                let obj: NCMBObject = NCMBObject(className: "MemoClass")
                obj.setObject(self.targetShopName, forKey: "shopName")
                obj.setObject(self.targetMenuPrice, forKey: "menuPrice")
                obj.setObject(self.targetMenuName, forKey: "menuName")
                obj.setObject(targetFile.name, forKey: "filename")
                obj.setObject(self.userData.object(forKey: "userID")!, forKey: "postUser")
                obj.setObject(self.targetHousrs!, forKey: "menuHours")
                obj.setObject(0 as Int, forKey: "lookCounter")
                obj.setObject(0 as Int, forKey: "favoriteCounter")
                obj.setObject(0 as Int, forKey: "likeCounter")
                obj.setObject(0 as Int, forKey: "reportCounter")
                obj.save(&saveError)
                
                //ファイルをバックグランドで実行
                targetFile.saveInBackground({
                    (error) -> Void in
                    
                    if error == nil {
                        print("画像データ保存完了: \(targetFile.name)")
                    } else {
                        self.presentError("登録エラー", "\(error!.localizedDescription)")
                    }
                    }, progressBlock: {
                        (percentDone: Int32) -> Void
                        in
                        //進捗状況を終わるまで取得
                        print("進捗状況: \(percentDone)%アップロード済み")
                })
                
                if saveError == nil {
                    print("success save data.")
                } else {
                    print("failure save data.\(saveError)")
                }
                
                let errorAlert = UIAlertController(
                    title: "投稿完了",
                    message: "投稿が反映されるまでお待ちください",
                    preferredStyle: UIAlertControllerStyle.alert
                )
                errorAlert.addAction(
                    UIAlertAction(
                        title: "OK",
                        style: UIAlertActionStyle.default,
                        handler: self.saveComplete                    )
                )
                
                errorAlert.addAction(
                    UIAlertAction(
                        title: "投稿をSNSにシェア",
                        style: UIAlertActionStyle.default,
                        handler: self.socialShare                   )
                )

                self.present(errorAlert, animated: true, completion: nil)
                
            } // normal add end
        }
    } // addmemo end

    @IBAction func displayCamera(_ sender: UIBarButtonItem) {
        
        //UIActionSheetを起動して選択後、カメラ・フォントライブラリを起動
        let alertActionSheet = UIAlertController(
            title: "写真を選択してください",
            message: "",
            preferredStyle: UIAlertControllerStyle.actionSheet
        )
        
        //UIActionSheetの戻り値をチェック
        alertActionSheet.addAction(
            UIAlertAction(
                title: "ライブラリから選択",
                style: UIAlertActionStyle.default,
                handler: handlerActionSheet
            )
        )
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            
            alertActionSheet.addAction(
                UIAlertAction(
                    title: "カメラで撮影",
                    style: UIAlertActionStyle.default,
                    handler: handlerActionSheet
                )
            )
        }
        
        alertActionSheet.addAction(
            UIAlertAction(
                title: "キャンセル",
                style: UIAlertActionStyle.cancel,
                handler: handlerActionSheet
            )
        )
        
        present(alertActionSheet, animated: true, completion: nil)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UITextFieldのプレースホルダー
        self.shopName.placeholder = "Eggs'n Things 原宿店"
        self.menuName.placeholder = "パンケーキ"
        self.menuPrice.placeholder = "1080"
        
        // 店舗リストから到達した場合
        if selectFlag {
            self.shopName.text = targetShopData.shopName
        }
        
        //投稿内容を修正
        if editFlag {
            // 現在の登録内容の反映
            self.shopName.text = targetData.shopName
            self.menuName.text = targetData.menuName
            self.menuPrice.text = targetData.menuMoney
            self.targetHousrs = targetData.menuHours
            self.displayImage.image = targetData.menuImage
            if let selectHours = targetHousrs {
                targetHousrs = nil
                switch selectHours {
                case 0: self.selctMorning(UIButton.init())
                case 1: self.selctLunch(UIButton.init())
                case 2: self.selctDiner(UIButton.init())
                default:
                    break
                }
            }
        }
        
        //ドロワーメニュー
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //金額の部分は数字のキーボードを使用
        self.menuPrice.keyboardType = UIKeyboardType.numbersAndPunctuation
        
        //UITextFieldのデリゲードの設定
        self.shopName.delegate = self
        self.menuName.delegate = self
        self.menuPrice.delegate = self
        
        // UILongPressGestureRecognizer宣言
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(AddController.imageTapped(recognizer:)))
        
        // `UIGestureRecognizerDelegate`を設定するのをお忘れなく
        tapRecognizer.delegate = self
        
        // tableViewにrecognizerを設定
        displayImage.addGestureRecognizer(tapRecognizer)
        
    } // View Did Load end
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if (textField == shopName) {
            // メニュー名欄へフォーカスする
            menuName.becomeFirstResponder()
        } else if (textField == menuName){
            // 金額欄へフォーカス
            menuPrice.becomeFirstResponder()
        } else {
            // キーボードを閉じる
            textField.resignFirstResponder()
            
            //画像選択へ
            displayCamera(UIBarButtonItem.init())
        }
        return true
    }
    
    // 画像サイズの変更
    func resizeImage(image: UIImage, width: Int, height: Int) -> UIImage {
        
        let size: CGSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImage!
    }
    
    func imageTapped(recognizer: UITapGestureRecognizer) {
        print("tapped")
        displayCamera(UIBarButtonItem.init())
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
    
    //登録が完了した際のアクション
    func saveComplete(_ ac: UIAlertAction) -> Void {
        //UItextFieldを空にする
        self.shopName.text = ""
        self.menuName.text = ""
        self.menuPrice.text = ""
        self.displayImage.image = nil
        navigationController?.popViewController(animated: true)
    }
    
    //登録完了後SNSへシェア
    func socialShare(_ ac: UIAlertAction) -> Void {
        
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
    
    func shareTwitter(_ ac: UIAlertAction) -> Void {
        let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        vc?.setInitialText(self.targetShopName + "\n" + self.targetMenuName + "\n")
        if self.targetDisplayImage != nil {
            vc?.add(self.targetDisplayImage)
        }
        
        self.present(vc!, animated: true, completion: nil)
        
    }
    
    func sharefacebook(_ ac: UIAlertAction) -> Void {
        let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        vc?.setInitialText(self.targetShopName + "\n" + self.targetMenuName + "\n")
        if self.targetDisplayImage != nil {
            vc?.add(self.targetDisplayImage)
        }
        
        self.present(vc!, animated: true, completion: nil)
        
    }
    
    
    func shareLine(_ ac: UIAlertAction) -> Void {
        var message = ""
        message += self.targetShopName + "\n"
        message += self.targetMenuName + "\n"
        let encodeMessage: String! = message.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let messageURL: NSURL! = NSURL( string: "line://msg/text/" + encodeMessage )
        if (UIApplication.shared.canOpenURL(messageURL as URL)) {
            UIApplication.shared.openURL( messageURL as URL)
        }
        
    }
    
    //アクションシートの結果に応じて処理を変更
    func handlerActionSheet(_ ac: UIAlertAction) -> Void {
        
        switch ac.title! {
            
        case "ライブラリから選択":
            self.selectAndDisplayFromPhotoLibrary()
            break
        case "カメラで撮影":
            self.loadAndDisplayFromCamera()
            break
        case "キャンセル":
            break
        default:
            break
        }
    }
    
    //ライブラリから写真を選択してimageに書き出す
    func selectAndDisplayFromPhotoLibrary() {
        
        //フォトアルバムを表示
        let ipc = UIImagePickerController()
        ipc.allowsEditing = true
        ipc.delegate = self
        ipc.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(ipc, animated: true, completion: nil)
    }
    
    //カメラで撮影してimageに書き出す
    func loadAndDisplayFromCamera() {
        
        //カメラを起動
        let ip = UIImagePickerController()
        ip.allowsEditing = true
        ip.delegate = self
        ip.sourceType = UIImagePickerControllerSourceType.camera
        present(ip, animated: true, completion: nil)
    }
    
    //画像を選択した時のイベント
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        //画像をセットして戻る
        self.dismiss(animated: true, completion: nil)
        
        let width = image.size.width / 1.7
        let height = image.size.height / 1.7
        let resizedImage =  resizeImage(image: image, width: Int(width), height: Int(height))
        
        self.displayImage.image = resizedImage
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //コメント表示画面へ行く前に詳細データを渡す

    }
    
    /*
     @IBAction func deleteMemo(_ sender: UIBarButtonItem) {
     
     let obj:NCMBObject = NCMBObject(className: "MemoClass")
     obj.objectId = self.targetMemoObjectId
     obj.deleteInBackground({
     (error) in
     
     if(error == nil){
     //削除成功時に画像も一緒に削除
     let fileData = NCMBFile.file(withName: self.targetFileName, data: nil) as! NCMBFile
     fileData.deleteInBackground({
     (error) in
     print("画像データ削除完了:\(self.targetFileName)")
     })
     
     
     } else {
     print("データ処理時にエラーが発生しました:\(error)")
     }
     })
     
     //UITextFieldをからにする
     self.shopName.text = ""
     self.menuName.text = ""
     self.updateFlag = true
     
     //削除完了を表示
     let errorAlert = UIAlertController(
     title: "完了",
     message: "このデータは削除されました。",
     preferredStyle: UIAlertControllerStyle.alert
     )
     errorAlert.addAction(
     UIAlertAction(
     title: "OK",
     style: UIAlertActionStyle.default,
     handler: saveComplete
     )
     )
     present(errorAlert, animated: true, completion: nil)
     
     }
     */
    
}
