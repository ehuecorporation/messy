//
//  LoginViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/09/30.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController{
    
    let userData = UserDefaults.standard
    
    // テスト
    
    
    
    @IBAction func twitterLogin(_ sender: UIButton) {
        NCMBTwitterUtils.logIn({
            (user, error) in
            
            if(error != nil){
                NSLog("Twitterでログインがキャンセルされました。:\(error)")
                return;
            } else {
                
                if !self.userData.bool(forKey: "useCount"){
                    NSLog("Twitterで登録成功！");
                    self.performSegue(withIdentifier: "PushUpdate", sender: nil)
                } else {
                    self.performSegue(withIdentifier: "pushMemos", sender: nil)
                }

            }
        })
        
    }
    
    
    @IBAction func facebookLogin(_ sender: UIButton) {
    
        NCMBFacebookUtils.logIn(withReadPermission: ["public_profile","email"]){
            (user, error) -> Void in
            if (error != nil){
                print("エラーが発生しました。:\(error)")
            }else {
                // 会員登録後の処理
                NSLog("facebookで認証完了")
                self.performSegue(withIdentifier: "pushMemos", sender: nil)
            }
        }
        
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
