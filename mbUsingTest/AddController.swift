//
//  AddController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/09/26.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB

class AddController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBAction func hideKeybord(_ sender: UITapGestureRecognizer) {
            self.view.endEditing(true)
    }
    
    
    //ユーザーデータ
    var userData = UserDefaults.standard
    
    //更新・追加・削除用のメンバ変数
    var targetShopName: String = ""
    var targetMenuName: String = ""
    var targetMenuPrice: String = ""
    var targetDisplayImage: UIImage? = nil
    
    //編集フラグ
    var editFlag: Bool = false
    
    //更新フラグ
    var updateFlag: Bool = false
    
    //編集対象メモのobjectId
    var targetMemoObjectId: String = ""
    
    //メモリスト
    var mbs: NCMBSearch = NCMBSearch()
    
    //編集対象メモのfilename
    var targetFileName: String = ""
    
    //ViewController.swiftから渡されたデータ
    var targetData: memo = memo()
    
    @IBOutlet weak var shopName: UITextField!
    @IBOutlet weak var menuName: UITextField!
    @IBOutlet weak var menuPrice: UITextField!
    @IBOutlet weak var displayImage: UIImageView!
    

    @IBAction func backButton(_ sender: UIBarButtonItem) {
                dismiss(animated: true, completion: nil)
    }

    @IBAction func addMemo(_ sender: UIBarButtonItem) {
        
        //バリデーションを通す前の準備
        self.targetShopName = self.shopName.text!
        self.targetMenuName = self.menuName.text!
        self.targetMenuPrice = self.menuPrice.text!
        self.targetDisplayImage = self.displayImage.image
        
        //情報が不十分の時エラーアラートを表示
        if (self.targetShopName.isEmpty || self.targetMenuName.isEmpty || self.targetMenuPrice.isEmpty || self.targetDisplayImage == nil) {
            
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
            } else {
                
                //新規データを一件登録する
                var saveError: NSError? = nil
                let obj: NCMBObject = NCMBObject(className: "MemoClass")
                obj.setObject(self.targetShopName, forKey: "shopName")
                obj.setObject(self.targetMenuPrice, forKey: "menuPrice")
                obj.setObject(self.targetMenuName, forKey: "menuName")
                obj.setObject(targetFile.name, forKey: "filename")
                obj.setObject(self.userData.object(forKey: "userID")!, forKey: "postUser")
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
                
                //UItextFieldを空にする
                self.shopName.text = ""
                self.menuName.text = ""
                self.menuPrice.text = ""
                self.displayImage.image = nil
                
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
                self.present(errorAlert, animated: true, completion: nil)
                
            }
            
        }
        
    }

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
        self.shopName.placeholder = "(例) ラーメン二郎"
        self.menuName.placeholder = "(例) ラーメン小"
        self.menuPrice.placeholder = "(例) 800"
        
        //金額の部分は数字のキーボードを使用
        self.menuPrice.keyboardType = UIKeyboardType.numbersAndPunctuation
        
        //UITextFieldのデリゲードの設定
        self.shopName.delegate = self
        self.menuName.delegate = self
        self.menuPrice.delegate = self
        
        //追加・編集での入力状態の制御
        if self.editFlag == true {
            
            //更新対象のobjetIdを入力
            self.targetMemoObjectId = targetData.objectID
            //UITextFieldに値を入れた状態にしておく
            self.shopName.text = targetData.shopName
            self.menuName.text = targetData.menuMoney
            //登録されている画像イメージをセットする
            self.displayImage.image = targetData.menuImage
        }
        
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
        dismiss(animated: true, completion: nil)
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
        
        let width = image.size.width / 2
        let height = image.size.height / 2
        let resizedImage =  resizeImage(image: image, width: Int(width), height: Int(height))
        
        self.displayImage.image = resizedImage
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //コメント表示画面へ行く前に詳細データを渡す
            
            let MainViewController = segue.destination as! MainViewController
            
            MainViewController.updateFlag = self.updateFlag
        

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
