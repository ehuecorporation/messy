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
    var firstAppear = true
    
    //NotificcationのObserver
    var keyBoardOnObserver: NSObjectProtocol?
    var keyBoardOfferver: NSObjectProtocol?

    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userPass: UITextField!
    
    @IBOutlet weak var underSpaceHeight: NSLayoutConstraint!
    
    
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
                    
                    if !self.userData.bool(forKey: "userName"){
//                        print(user!.userName)
//                        print(self.userData.object(forKey: "userName"))
                        if user!.userName != self.userData.object(forKey: "userName") as? String{
                            // 端末に入っているmessyのデータを削除
                            let appDomain = Bundle.main.bundleIdentifier
                            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
                        }
                    }

                    //端末情報の更新
                    self.userData.set(user!.userName, forKey: "userName")
                    self.userData.set(targetPass, forKey: "userPass")
                    self.userData.set(user!.mailAddress, forKey: "userMail")
                    self.userData.set(user!.object(forKey: "userIcon"), forKey: "userIconFileName")
                    let favList: [String] = user?.object(forKey: "favList") as! [String]
                    let likeList: [String] = user?.object(forKey: "likeList") as! [String]
                    self.userData.set( favList, forKey: "favorites")
                    self.userData.set( likeList, forKey: "likes")
                    self.userData.set( user!.object(forKey: "userSex"), forKey: "userSex")
                    
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
                    print("\(String(describing: self.userData.object(forKey: "userName")))\(String(describing: self.userData.object(forKey: "userPass")))\(String(describing: self.userData.object(forKey: "useCount")))\(String(describing: self.userData.object(forKey: "userMail")))\(String(describing: self.userData.object(forKey: "userID")))\(String(describing: self.userData.object(forKey: "userIconFileName")))\(String(describing: self.userData.object(forKey:"userSex")))")
                    
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
        performSegue(withIdentifier: "goSignIn", sender: nil)
    } // singInButton end
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self,selector: #selector(LoginViewController.keyboardWillBeShown(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 強制的にログアウト
        NCMBUser.logOut()
        
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
    
    func keyboardWillBeShown(_ notification: Notification) {
        self.view.setNeedsUpdateConstraints()
        underSpaceHeight.constant = CGFloat(200.0)
        // アニメーションによる移動
        UIView.animate(withDuration: 0.3, animations: self.view.layoutIfNeeded)
    }
    
    func keyboardWillBeHidden(_ notification : Notification) {
        self.view.setNeedsUpdateConstraints()
        underSpaceHeight.constant = CGFloat(20.0)
        // アニメーションによる移動
        UIView.animate(withDuration: 0.3, animations: self.view.layoutIfNeeded)
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
}
