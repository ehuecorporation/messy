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
    
    // trueならメアドによる新規登録falseならTwitterによる新規登録
    var loginFlag = true
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userPass: UITextField!
    @IBOutlet weak var loginLabel: UIButton!
    
    
    @IBAction func hideKeybord(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func loginButton(_ sender: UIButton) {
        let targetName = self.userName.text!
        let targetPass = self.userPass.text!
        
        
        
        if (targetName.isEmpty || targetPass.isEmpty) {
            
            //エラーアラートを表示してOKで戻る
            presentError("エラー", "入力に不備があります")
        // 新規会員登録
        } else if (!userData.bool(forKey: "useCount")) {
            let newUser = NCMBUser()
            newUser.userName = targetName
            newUser.password = targetPass
            newUser.signUpInBackground({
                (error) in
            
                if error != nil {
                    self.presentError("登録エラー", "\(error!.localizedDescription)")
                } else {
                    print("新規登録成功")
                    
                    // ユーザー情報を端末へ保存
                    self.userData.register(defaults: [ "userName": String()])
                    self.userData.set(targetName, forKey: "userName")
                    self.userData.register(defaults: ["userPass": String()])
                    self.userData.set(targetPass, forKey: "userPass")
                    self.userData.synchronize()
                    print("確認\(self.userData.object(forKey: "userName"))\(self.userData.object(forKey: "userPass"))")
                    self.performSegue(withIdentifier: "pushUpdate", sender: nil)
                }
            })

        } else {
            NCMBUser.logInWithUsername(inBackground: targetName, password: targetPass, block: {
                (user, error) in
                
                if error != nil {
                    self.presentError("認証エラー", "\(error!.localizedDescription)")
                    
                } else if (user != nil){
                    //端末情報への保存
                    self.userData.set(targetName, forKey: "userName")
                    self.userData.set(targetPass, forKey: "userPass")
                    self.userData.synchronize()
                    print("確認\(self.userData.object(forKey: "userName"))\(self.userData.object(forKey: "userPass"))\(self.userData.object(forKey: "useCount"))")
                    self.performSegue(withIdentifier: "pushMemos", sender: nil)
                }
            })
        }
        
    }
    
    //Twitter認証
    @IBAction func twitterLogin(_ sender: UIButton) {
        NCMBTwitterUtils.logIn({
            (user, error) in
            
            if(error != nil){
                NSLog("Twitterでログインがキャンセルされました。:\(error)")
                //エラーアラートを表示してOKで戻る
                self.presentError("認証エラー", "\(error!.localizedDescription)")
            } else if (user != nil){
                
                if !self.userData.bool(forKey: "userID") {
                    self.userData.register(defaults: ["userID" : String()])
                    self.userData.set(user?.objectId, forKey: "userID")
                                        self.userData.synchronize()
                }
                
                self.userData.register(defaults: ["useCount" : Bool()])
                
                // 初めての使用なら更新画面へ
                if !self.userData.bool(forKey: "useCount"){
                    NSLog("Twitterで登録成功！");
                    self.performSegue(withIdentifier: "pushUpdate", sender: nil)
                } else {
                    // そうでないなら一覧画面へ
                    self.userData.set(true, forKey: "useCount")
                    self.userData.synchronize()
                    self.performSegue(withIdentifier: "pushMemos", sender: nil)
                }

            }
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートを通しておく
        userName.delegate = self
        userPass.delegate = self
        
        //初めての利用であればボタンのラベルを変える
        self.userData.register(defaults: ["useCount" : Bool()])
        
        if !userData.bool(forKey: "useCount") {
            loginLabel.setTitle("会員登録", for: .normal)
        }
        
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
            
            // ログイン処理
            let targetName = self.userName.text!
            let targetPass = self.userPass.text!
            
            if (targetName.isEmpty || targetPass.isEmpty) {
                
                presentError("エラー", "入力内容に不備があります")
                
                // 新規会員登録
            }
            
            NCMBUser.logInWithUsername(inBackground: targetName, password: targetPass, block: {
                (user, error) in
                
                if error != nil {
                    
                    self.presentError("認証エラー", "\(error!.localizedDescription)")
                    
                } else if (user != nil){
                    
                    self.userData.set(targetName, forKey: "userName")
                    self.userData.set(targetPass, forKey: "userPass")
                    self.userData.synchronize()
//                    print("確認\(self.userData.object(forKey: "userName"))\(self.userData.object(forKey: "userPass"))\(self.userData.object(forKey: "useCount"))")
                    self.performSegue(withIdentifier: "pushMemos", sender: nil)
                }
            })
            
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
