//
//  InputViewController.swift
//  taskapp
//
//  Created by 宮城 光太朗 on 2023/04/21.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    
    let realm = try! Realm()
    var task: Task!
    var categoryArray = try! Realm().objects(Category.self)
    var category: Category?
    
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(categoryArray)
        //背景をタップしたらdismissKeyboardメソッドを呼ぶよう設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        let index = categoryArray.firstIndex { category in
            return task.category == category
        }
        
        // Delegate設定
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
    
        // categoryPickerの初期選択指定
        if index != nil {
            print(index!)
            categoryPicker.selectRow(index!, inComponent: 0, animated: false)
        }
        print("viewDidload")
        //categoryTextField.text = task.category
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //pickerView.reloadData()
        self.categoryPicker.reloadAllComponents()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            if let ct = self.category {
                self.task.category = ct
            }
//            self.task.category = self.categoryTextField.text!
            self.realm.add(self.task, update: .modified)
        }
        
        print("更新")
        print(self.task.category)
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    @objc func dismissKeyboard(){
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    //タスクのローカル通知を登録する
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        //タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(××なし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        //ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        //identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id.stringValue), content: content, trigger: trigger)
        
        //ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK") //errorがnillならローカル通知の塔小禄に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        //未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("/---------------")
            }
        }
    }
    

}

extension InputViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    
    // UIPickerViewの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの最初の表示
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return categoryArray[row].categoryTitle
    }
    
     //UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        self.category = categoryArray[row]
    }
}
