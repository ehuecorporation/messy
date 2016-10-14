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
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var moneyField: UITextField!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var displayImage: UIImageView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    //前の画面に戻る
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
//        performSegue(withIdentifier: "BackMemos", sender: nil)
    }
    @IBAction func hidekeyboardAction(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    @IBAction func addMemo(_ sender: UIBarButtonItem) {
        
        //バリデーションを通す前の準備
        self.targetTitle = self.titleField.text!
        self.targetMoney = self.moneyField.text!
        self.targetCommnet = self.commentField.text!
        self.targetDisplayImage = self.displayImage.image
        
        //情報が不十分の時エラーアラートを表示
        if (self.targetTitle.isEmpty || self.targetMoney.isEmpty || self.targetCommnet.isEmpty || self.targetDisplayImage == nil) {
            
            //エラーアラートを表示してOKで戻る
            let errorAlert = UIAlertController(title: "エラー", message:"入力に不備があります", preferredStyle: UIAlertControllerStyle.alert)
            
            errorAlert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.default,
                    handler: nil
                )
            )
            present(errorAlert, animated: true, completion: nil)
            
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
                        obj.setObject(self.targetTitle, forKey: "title")
                        obj.setObject(self.targetMoney, forKey: "money")
                        obj.setObject(targetFile.name, forKey: "filename")
                        obj.setObject(self.targetCommnet, forKey: "comment")
                        obj.save(&saveError)
                    } else {
                        print("データ処理時にエラーが発生しました:\(error)")
                    }
                    
                    if targetFile.name != self.targetFileName {
                        
                        targetFile.saveInBackground({
                            (error) -> Void in
                            
                            if error == nil {
                                print("画像データ保存完了: \(targetFile.name)")
                            } else {
                                print("アップロード中にエラーが発生しました: \(error)")
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
                obj.setObject(self.targetTitle, forKey: "title")
                obj.setObject(self.targetMoney, forKey: "money")
                obj.setObject(targetFile.name, forKey: "filename")
                obj.setObject(self.targetCommnet, forKey: "comment")
                obj.save(&saveError)
                
                //ファイルをバックグランドで実行
                targetFile.saveInBackground({
                    (error) -> Void in
                    
                    if error == nil {
                        print("画像データ保存完了: \(targetFile.name)")
                    } else {
                        print("アップロード中にエラーが発生しました: \(error)")
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
                self.titleField.text = ""
                self.moneyField.text = ""
                self.commentField.text = ""
                
                //登録されたアラートを表示してOKを押すと戻る
                let errorAlert = UIAlertController(
                    title: "完了",
                    message: "入力データが登録されました。",
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
            
        }
        
    }
    
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
        self.titleField.text = ""
        self.moneyField.text = ""
        self.commentField.text = ""
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
    
    
    @IBAction func diplayCamera(_ sender: UIBarButtonItem) {
        
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
    
    
    //登録が完了した際のアクション
    func saveComplete(_ ac: UIAlertAction) -> Void {
        performSegue(withIdentifier: "BackMemos", sender: nil)
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
        
        let width = 360
        let height = 360
        let resizedImage =  resizeImage(image: image, width: width, height: height)

        self.displayImage.image = resizedImage
    }
    
    
    //更新・追加・削除用のメンバ変数
    var targetTitle: String = ""
    var targetMoney: String = ""
    var targetCommnet: String = ""
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
    //参照している配列の場所
    var targetNum: Int = Int()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UITextFieldのプレースホルダー
        self.titleField.placeholder = "(例) ラーメン二郎"
        self.moneyField.placeholder = "(例) 900"
        self.commentField.placeholder = "(例) 激しく食べ過ぎました...反省"
        
        //金額の部分は数字のキーボードを使用
        self.moneyField.keyboardType = UIKeyboardType.numberPad
        
        //UITextFieldのデリゲードの設定
        self.titleField.delegate = self
        self.moneyField.delegate = self
        self.commentField.delegate = self
        
        //追加・編集での入力状態の制御
        if self.editFlag == true {
            
            //更新対象のobjetIdを入力
            self.targetMemoObjectId = targetData.objectID
            //UITextFieldに値を入れた状態にしておく
            self.titleField.text = targetData.memoTitle
            self.moneyField.text = targetData.memoMoney
            self.commentField.text = targetData.memoComment
            //登録されている画像イメージをセットする
            self.displayImage.image = targetData.memoImage
        }
        
    } // View Did Load end

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func resizeImage(image: UIImage, width: Int, height: Int) -> UIImage {
        
        let size: CGSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImage!
    }
    
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //コメント表示画面へ行く前に詳細データを渡す
            
            let ViewController = segue.destination as! ViewController
            
            ViewController.updateFlag = self.updateFlag
        

    }
    
}
