//
//  categoryViewController.swift
//  taskapp
//
//  Created by 宮城 光太朗 on 2023/05/10.
//

import UIKit
import RealmSwift
import UserNotifications

class categoryViewController: UIViewController {
    
    let realm = try! Realm()
    var category: Category!
    @IBOutlet weak var categoryTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.category = Category()
        //背景をタップしたらdismissKeyboardメソッドを呼ぶよう設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        categoryTextField.text = category.categoryTitle
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.categoryTextField.text! != "" {
            try! realm.write {
                self.category.categoryTitle = self.categoryTextField.text!
                self.realm.add(self.category, update: .modified)
            }
        }
        
        print("登録したよ")
        super.viewWillDisappear(animated)
    }
    
    @objc func dismissKeyboard(){
        //キーボードを閉じる
        view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
