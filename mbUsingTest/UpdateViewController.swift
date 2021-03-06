//
//  UpdateViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/10/03.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB
import SWRevealViewController


class UpdateViewController: UIViewController,UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIGestureRecognizerDelegate {
    
    var userData = UserDefaults.standard
    var userName : String = ""
    var loginFlag: Bool = Bool()
    let user = NCMBUser.current()
    var loading_flag = false
    var user_sex: Int? = nil

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userNewName: UITextField!
    @IBOutlet weak var mailAdress: UITextField!
    @IBOutlet weak var manButton: UIButton!
    @IBOutlet weak var womanButton: UIButton!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBAction func setMan(_ sender: UIButton) {
        if let sex = user_sex {
            if sex == 0 {
                user_sex = nil
                manButton.backgroundColor = UIColor.white
                manButton.setTitleColor(UIColor.black, for: .normal)
                return
            }
        }
        user_sex = 0
        manButton.backgroundColor = UIColor.init(red: 102/255.0, green: 119/255.0, blue: 238/255.0, alpha: 0.75)
        manButton.setTitleColor(UIColor.white, for: .normal)
        womanButton.backgroundColor = UIColor.white
        womanButton.setTitleColor(UIColor.black, for: .normal)

    }
    
    @IBAction func setWoman(_ sender: UIButton) {
        if let sex = user_sex {
            if sex == 1 {
                user_sex = nil
                womanButton.backgroundColor = UIColor.white
                womanButton.setTitleColor(UIColor.black, for: .normal)
                return
            }
        }
        user_sex = 1
        manButton.backgroundColor = UIColor.white
        manButton.setTitleColor(UIColor.black, for: .normal)
        womanButton.backgroundColor = UIColor.init(red: 220/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1.0)
        womanButton.setTitleColor(UIColor.white, for: .normal)

    }
    
    
    @IBAction func hydeKeybord(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func update(_ sender: UIBarButtonItem) {
        if loading_flag {
            return
        }
        
        // textFieldの値を取得
        let targetNewName = self.userNewName.text!
        let targetNewMailAdress = self.mailAdress.text!
        let targetUserImage = self.userImage.image
        let targetSex = self.user_sex
        
        if (targetNewName.isEmpty || targetNewMailAdress.isEmpty || targetUserImage == nil) {
            
            presentError("エラー", "入力に不備があります")
            
        } else {
            
            loading_flag = true
            
            // ユーザー情報を設定
            user?.setObject(targetNewName, forKey: "userName")
            self.userData.set(targetNewName, forKey: "userName")
            user?.setObject(targetNewMailAdress, forKey: "mailAddress")
            self.userData.set(targetNewMailAdress, forKey: "userMail")
            if targetSex != nil {
                user?.setObject(targetSex, forKey: "userSex")
                self.userData.set(targetSex, forKey: "userSex")
            }
            
            user?.acl.setPublicReadAccess(true)
            user?.acl.setWriteAccess(true, for: user)
            
            // アイコン画像の設定
            let imageData: Data = UIImagePNGRepresentation(targetUserImage!)!
            let targetFile = NCMBFile.file(with: imageData) as! NCMBFile
            user?.setObject(targetFile.name, forKey: "userIcon")
            
            // user情報の更新
            user?.saveInBackground({
                (error) -> Void in
                if let updateerror = error {
                    // 更新失敗時の処理
                    print("エラー内容\(String(describing: error))")
                    self.loading_flag = false
                    self.presentError("更新エラー", "\(updateerror.localizedDescription)")

                    
                } else {
                    
                    self.userData.register(defaults: ["useCount" : Bool()])
                    self.userData.register(defaults: ["userID" : String()])
                    self.userData.register(defaults: ["userMail" : String()])
                    self.userData.register(defaults: ["userSex " : Int()])
                    self.userData.set(true, forKey: "useCount")
                    self.userData.set(self.user?.objectId, forKey: "userID")
                    self.userData.set(self.user?.mailAddress, forKey: "userMail")
                    self.userData.set(targetSex, forKey: "userSex")
                    self.userData.synchronize()
                    
                    if let iconFileName = self.userData.object(forKey: "userIconFileName") {
                        self.userData.removeObject(forKey: "userIcon")
                        self.userData.removeObject(forKey: "userIconFileName")
                        let mbs: NCMBSearch = NCMBSearch()
                        mbs.deleteIcon(iconFileName as! String)
                    }
                    
                    targetFile.saveInBackground({
                        (error) -> Void in
                        
                        if error == nil {
                            print("画像データ保存完了: \(targetFile.name)")
                            self.userData.register(defaults: ["userIconFileName" : String()])
                            if let userIcon = UIImagePNGRepresentation(self.userImage.image!) {
                                self.userData.set(userIcon, forKey: "userIcon")
                            }
                            self.userData.set(targetFile.name, forKey: "userIconFileName")
                            self.userData.synchronize()
                            
                            let errorAlert = UIAlertController(
                                title: "完了",
                                message: "会員情報が更新されました",
                                preferredStyle: UIAlertControllerStyle.alert
                            )
                            errorAlert.addAction(
                                UIAlertAction(
                                    title: "OK",
                                    style: UIAlertActionStyle.default,
                                    handler: self.saveComplete
                                )
                            )
                            
                            self.loading_flag = false
                            
                            self.present(errorAlert, animated: true, completion: nil)
                            
                            
                        } else {
                            self.self.presentError("画像アップロードエラー", "\(error!.localizedDescription)")
                            self.loginFlag = false
                        }
                        
                    }, progressBlock: { (percentDone: Int32) -> Void in
                        
                        // 進捗状況を取得します。保存完了まで何度も呼ばれます
                        print("進捗状況: \(percentDone)% アップロード済み")
                    }) // targetFile end
                    
                }
            }) // user save
        }
    } // update end

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
    // キーボードの確定を押した後の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if (textField == userNewName) {
            // password欄へフォーカスする
            mailAdress.becomeFirstResponder()
        } else {
            // キーボードを閉じる
            textField.resignFirstResponder()
            
            displayCamera(UIBarButtonItem.init())
            
        }
        return true
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
    
    func saveComplete(_ ac: UIAlertAction) -> Void {
        performSegue(withIdentifier: "pushMain", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        userNewName.delegate = self
        mailAdress.delegate = self
        
        userImage.image = #imageLiteral(resourceName: "defaultIcon")
        
        if let name = userData.object(forKey: "userName") {
            userNewName.text = name as? String
        }
        
        if let mail = userData.object(forKey: "userMail") {
            mailAdress.text = mail as? String
        }
        
        if let icon = userData.object(forKey: "userIcon") {
            let image: UIImage = UIImage(data: (icon as! NSData) as Data)!
            userImage.image = image
        }
        
        if !userData.bool(forKey: "useCount") {
            menuButton.isEnabled = false
        }
        
        if let tmp = userData.object(forKey: "userSex") {
            let sex = tmp as! Int
            if sex == 0 {
                manButton.backgroundColor = UIColor.init(red: 102/255.0, green: 119/255.0, blue: 238/255.0, alpha: 0.75)
                manButton.setTitleColor(UIColor.white, for: .normal)
            }
            if sex == 1 {
                womanButton.backgroundColor = UIColor.init(red: 220/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1.0)
                womanButton.setTitleColor(UIColor.white, for: .normal)
            }
        }
        
        //ドロワーメニュー
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // UILongPressGestureRecognizer宣言
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(UpdateViewController.imageTapped(recognizer:)))
        
        // `UIGestureRecognizerDelegate`を設定するのをお忘れなく
        tapRecognizer.delegate = self
        
        // tableViewにrecognizerを設定
        userImage.addGestureRecognizer(tapRecognizer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let width = image.size.width / 3
        let height = image.size.height / 3
        let resizedImage =  resizeImage(image: image, width: Int(width), height: Int(height))
        
        self.userImage.image = resizedImage
    }

}
