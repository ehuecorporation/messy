//
//  LoginViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/09/30.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB

class LoginViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate{
    
    let userData = UserDefaults.standard
    
    var loginFlag = false
    var mbs: NCMBSearch = NCMBSearch()
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userPass: UITextField!
    @IBOutlet weak var loginLabel: UIButton!
    
    
    @IBAction func hideKeybord(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        let targetName = self.userName.text!
        let targetPass = self.userPass.text!
        
        //すでにログインを実行しているならなにもしない
        if loginFlag {
            return
        }
        
        loginFlag = true
        
        if (targetName.isEmpty || targetPass.isEmpty) {
            
            loginFlag = false
            
            //エラーアラートを表示してOKで戻る
            presentError("エラー", "入力に不備があります")

        } else {
            NCMBUser.logInWithUsername(inBackground: targetName, password: targetPass, block: {
                (user, error) in
                
                if error != nil {
                    
                    self.loginFlag = false

                    self.presentError("認証エラー", "\(error!.localizedDescription)")
                    
                } else {
                    
                    // 端末に入っているmessyのデータを削除
                    let appDomain = Bundle.main.bundleIdentifier
                    UserDefaults.standard.removePersistentDomain(forName: appDomain!)

                    //端末情報の更新
                    self.userData.set(user?.userName, forKey: "userName")
                    self.userData.set(targetPass, forKey: "userPass")
                    self.userData.set(user!.mailAddress, forKey: "userMail")
                    self.userData.set(user?.object(forKey: "userIcon"), forKey: "userIconFileName")
                    let favList: [String] = user?.object(forKey: "favList") as! [String]
                    self.userData.set( favList, forKey: "favorites")
                    
                    if !self.userData.bool(forKey: "userIcon") {
                        let mbs = NCMBSearch()
                        mbs.loadIcon()
                    }
 
                    if let userID = user!.objectId {
                        self.userData.register(defaults: ["userID": String()])
                        self.userData.set(userID, forKey: "userID")
                    }
                    self.userData.register(defaults: ["useCount": Bool()])
                    self.userData.set(true, forKey: "useCount")
                    self.userData.synchronize()
                    // ユーザーデータの確認
                    print("確認\(self.userData.object(forKey: "userName"))\(self.userData.object(forKey: "userPass"))\(self.userData.object(forKey: "useCount"))\(self.userData.object(forKey: "userMail"))\(self.userData.object(forKey: "userID"))\(self.userData.object(forKey: "userIconFileName"))")
                    
                    // 該当端末で初めての使用なら更新画面へ
                    if !self.userData.bool(forKey: "useCount"){
                        self.performSegue(withIdentifier: "pushUpdate", sender: nil)
                    } else {
                        // そうでないなら一覧画面へ
                        self.userData.set(true, forKey: "useCount")
                        self.userData.synchronize()
                        self.performSegue(withIdentifier: "pushMemos", sender: nil)
                    }
                }
                
            }) //loginWithUsername end
        }
        
    }
    
    @IBAction func signInButton(_ sender: UIButton) {
        
        let targetName = self.userName.text!
        let targetPass = self.userPass.text!

        
        //すでに実行しているならなにもしない
        if loginFlag {
            return
        }
        
        let newUser = NCMBUser()
        newUser.userName = targetName
        newUser.password = targetPass
        newUser.setObject([], forKey: "favList")
        //デフォルト設定
        newUser.mailAddress = "default@gmail.com"
        newUser.setObject("", forKey: "userIcon")
        newUser.signUpInBackground({(error) in
            
            if error != nil {

                self.loginFlag =  false
                self.presentError("登録エラー", "\(error!.localizedDescription)")
            
            } else {
                print("新規登録成功")
                
                // 端末に入っているmessyのデータを削除
                let appDomain = Bundle.main.bundleIdentifier
                UserDefaults.standard.removePersistentDomain(forName: appDomain!)
                
                    
                // ユーザー情報を端末へ保存
                self.userData.register(defaults: [ "userName": String()])
                self.userData.set(targetName, forKey: "userName")
                self.userData.register(defaults: ["userPass": String()])
                self.userData.set(targetPass, forKey: "userPass")
                
                self.userData.register(defaults: [ "userMeil": String()])
                self.userData.register(defaults: [ "userID": String()])
                self.userData.register(defaults: ["useCount": Bool()])
                
                self.userData.synchronize()
                print("確認\(self.userData.object(forKey: "userName"))\(self.userData.object(forKey: "userPass"))\(self.userData.object(forKey: "userMail"))\(self.userData.object(forKey: "userID"))")
                    self.performSegue(withIdentifier: "pushUpdate", sender: nil)
                }
            })

    } // singInButton end
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ステータスバーのスタイル変更を促す
        self.setNeedsStatusBarAppearanceUpdate();
        
        // デリゲートを通しておく
        userName.delegate = self
        userPass.delegate = self
                
        // 値をプリセット
        if let name = userData.object(forKey: "userName") {
            userName.text = name as? String
        }
        if let pass = userData.object(forKey: "userPass") {
            userPass.text = pass as? String
        }
    }
    
    // キーボードの確定を押した後の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if (textField == userName) {
            // password欄へフォーカスする
            userPass.becomeFirstResponder()
        } else {
            // キーボードを閉じる
            textField.resignFirstResponder()
            
            loginButton(UIButton.init())
            
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        // ステータスバーを白くする
        return .lightContent;
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
     //ログインボタンが押された時の処理。Facebookの認証とその結果を取得する
     func loginButton(_ loginButton: FBSDKLoginButton!,didCompleteWith
     result: FBSDKLoginManagerLoginResult!, error: Error!) {
     print("User Logged In")
     
     if ((error) != nil)
     {
     //エラー処理
     } else if result.isCancelled {
     //キャンセルされた時
     print("キャンセルされました")
     } else {
     //必要な情報が取れていることを確認(今回はemail必須)
     if result.grantedPermissions.contains("email")
     {
     performSegue(withIdentifier: "PushMemos", sender: nil)
     }
     }
     }
     
     //ログアウトボタンが押された時の処理
     func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
     print("User Logged Out")
     }
     
     
     override func viewDidLoad() {
     super.viewDidLoad()
     if (FBSDKAccessToken.current() != nil) {
     print("User Already Logged In")
     //後で既にログインしていた場合の処理（メイン画面へ遷移）を書く
     } else {
     print("User not Logged In")
     let loginView : FBSDKLoginButton = FBSDKLoginButton()
     self.view.addSubview(loginView)
     loginView.center = self.view.center
     loginView.readPermissions = ["public_profile", "email", "user_friends"]
     loginView.delegate = self
     }
     // Do any additional setup after loading the view.
     }
     */

}
