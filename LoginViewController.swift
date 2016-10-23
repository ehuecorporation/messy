//
//  LoginViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/09/30.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB

class LoginViewController: UIViewController, UINavigationControllerDelegate{
    
    let userData = UserDefaults.standard
    
    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var userPass: UITextField!
    
    @IBAction func hideKeybord(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func loginButton(_ sender: UIButton) {
        let targetMail = self.userMail.text!
        let targetPass = self.userPass.text!
        
        if (targetMail.isEmpty || targetPass.isEmpty) {
            
            //エラーアラートを表示してOKで戻る
            let errorAlert = UIAlertController(title: "エラー", message:"入力に不備があります", preferredStyle: UIAlertControllerStyle.alert)
            
            errorAlert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.default,
                    handler: nil
                )
            )
            self.present(errorAlert, animated: true, completion: nil)
            return
        } else {
            NCMBUser.logInWithMailAddress(inBackground: targetMail, password: targetPass, block: {
                (user, error) in
                
                if error != nil {
                    //エラーアラートを表示してOKで戻る
                    let errorAlert = UIAlertController(title: "認証エラー", message:"入力内容を確認の上、もう一度お試しください", preferredStyle: UIAlertControllerStyle.alert)
                    
                    errorAlert.addAction(
                        UIAlertAction(
                            title: "OK",
                            style: UIAlertActionStyle.default,
                            handler: nil
                        )
                    )
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                } else if (user != nil){
                    self.performSegue(withIdentifier: "pushMemos", sender: nil)
                }
            })
        }
        
    }
    @IBAction func twitterLogin(_ sender: UIButton) {
        NCMBTwitterUtils.logIn({
            (user, error) in
            
            if(error != nil){
                NSLog("Twitterでログインがキャンセルされました。:\(error)")
                //エラーアラートを表示してOKで戻る
                let errorAlert = UIAlertController(title: "認証エラー", message:"もう一度お試し下さい", preferredStyle: UIAlertControllerStyle.alert)
                
                errorAlert.addAction(
                    UIAlertAction(
                        title: "OK",
                        style: UIAlertActionStyle.default,
                        handler: nil
                    )
                )
                self.present(errorAlert, animated: true, completion: nil)
                return
            } else if (user != nil){
                
                if !self.userData.bool(forKey: "userID") {
                    self.userData.set(user?.objectId, forKey: "userID")
                }
                if !self.userData.bool(forKey: "useCount"){
                    NSLog("Twitterで登録成功！");
                    self.performSegue(withIdentifier: "pushUpdate", sender: nil)
                } else {
                    self.performSegue(withIdentifier: "pushMemos", sender: nil)
                }

            }
        })
        
    }
    
    
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

}
