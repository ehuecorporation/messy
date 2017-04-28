//
//  SignInViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2017/04/14.
//  Copyright © 2017年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB
import SWRevealViewController

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userPass: UITextField!
    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var manButton: UIButton!
    @IBOutlet weak var womanButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBAction func hydeKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
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
    
    @IBAction func signIn(_ sender: UIBarButtonItem) {
        
        print("signIn")
        
        // 多重サインインを防止
        if loading_flag {
            return
        }
        
        let newUser = NCMBUser()
        // textFieldの値を取得
        let targetName = self.userName.text!
        let targetMail = self.userMail.text!
        let targetPass = self.userPass.text!
        let targetImage = self.userImage.image
        let targetSex = self.user_sex
        
        if targetName.isEmpty || targetMail.isEmpty || targetPass.isEmpty || targetSex == nil{
            presentError("エラー", "入力に不備があります")
            return
        }
        
        loading_flag = true
        
        newUser.userName = targetName
        newUser.password = targetPass
        newUser.mailAddress = targetMail
        newUser.setObject(targetPass, forKey: "pass")
        newUser.setObject([], forKey: "favList")
        newUser.setObject([], forKey: "likeList")
        newUser.setObject([], forKey: "reportList")
        newUser.setObject([], forKey: "reportCounter")
        newUser.setObject(targetSex, forKey: "userSex")
        
        // アイコン画像の設定
        let imageData: Data = UIImagePNGRepresentation(targetImage!)!

        newUser.signUpInBackground({(error) in
                    
            if error != nil {
                        
                self.loading_flag =  false
                self.presentError("登録エラー", "\(error!.localizedDescription)")
                        
            } else {
                
                print("新規登録成功")
                self.loading_flag = false
                
                newUser.acl.setPublicReadAccess(true)
                newUser.acl.setWriteAccess(true, for: newUser)

                newUser.saveInBackground({(error) in
                    if error == nil {
                        print("登録完了")
                    }
                })
                
                // 端末に入っているmessyのデータを削除
                let appDomain = Bundle.main.bundleIdentifier
                UserDefaults.standard.removePersistentDomain(forName: appDomain!)
                
                // ユーザー情報を端末へ保存
                self.userData.register(defaults: [ "userName": String()])
                self.userData.set(targetName, forKey: "userName")
                self.userData.register(defaults: ["userPass": String()])
                self.userData.set(targetPass, forKey: "userPass")
                self.userData.register(defaults: [ "userMeil": String()])
                self.userData.set(targetMail, forKey: "userMainl")
                self.userData.register(defaults: [ "userID": String()])
                self.userData.register(defaults: ["useCount": Bool()])
                self.userData.synchronize()
                print("確認\(String(describing: self.userData.object(forKey: "userName")))\(String(describing: self.userData.object(forKey: "userPass")))\(String(describing: self.userData.object(forKey: "userMail")))\(String(describing: self.userData.object(forKey: "userID")))")
                
                let targetFile = NCMBFile.file(with: imageData) as! NCMBFile
                newUser.setObject(targetFile.name, forKey: "userIcon")
                
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
                        
                        newUser.setObject(targetFile.name, forKey: "userIcon")
                        newUser.saveInBackground({(error) in
                            if error == nil {
                                print("登録完了")
                            }
                        })
                        
                        let errorAlert = UIAlertController(
                            title: "完了",
                            message: "会員情報が登録されました",
                            preferredStyle: UIAlertControllerStyle.alert
                        )
                        errorAlert.addAction(
                            UIAlertAction(
                                title: "OK",
                                style: UIAlertActionStyle.default,
                                handler: self.saveComplete
                            )
                        )
                        self.present(errorAlert, animated: true, completion: nil)
                        
                        
                    } else {
                        self.presentError("画像アップロードエラー", "\(error!.localizedDescription)")
                    }
                    
                }, progressBlock: { (percentDone: Int32) -> Void in
                    
                    // 進捗状況を取得します。保存完了まで何度も呼ばれます
                    print("進捗状況: \(percentDone)% アップロード済み")
                }) // targetFile end
            }
        })
    }
    
    var userData = UserDefaults.standard
    var user_sex: Int? = nil
    var loading_flag = false
    
    override func viewDidLoad() {
        print("now")
        super.viewDidLoad()
        
        userImage.image = #imageLiteral(resourceName: "defaultIcon")
        
        userName.delegate = self
        userPass.delegate = self
        userMail.delegate = self

        
        userName.placeholder = "Kendrick"
        userPass.placeholder  = "Kendrick1123"
        userMail.placeholder  = "Kendrick@gmail.com"
        
        //ドロワーメニュー
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //左スライドメニューの幅
        self.revealViewController().rearViewRevealWidth = 200

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // エラーメッセージを出す関数を定義
    func presentError (_ title: String?, _ message: String?) {
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
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
        self.present(nextView, animated: true, completion: nil)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
