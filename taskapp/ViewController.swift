//
//  ViewController.swift
//  taskapp
//
//  Created by 宮城 光太朗 on 2023/04/21.
//

import UIKit
import RealmSwift //Realmを追加
import UserNotifications //通知のライブラリを追加

class ViewController: UIViewController {
    
    //Realmインスタンスを取得する
    let realm = try! Realm()
    var srchCategory: String = ""
    //DB内のタスクが格納されるリスト。
    //日付の近い順でソート：昇順
    //以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true) //追加
    
    @IBOutlet weak var tableView: UITableView!
    
    //var taskArray: Results<Task>!
    override func viewDidLoad() {
        super.viewDidLoad()
//        // Do any additional setup after loading the view.
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    //segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            inputViewController.task = Task()
        }
    }
    
    //入力画面から戻ってきた時にTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //カテゴリ絞込み
    @IBAction func categoryButton(_ sender: Any) {
        // UIAlertControllerの生成
        let alert = UIAlertController(title: "カテゴリ", message: "選択してください", preferredStyle: .actionSheet)
        
        let inputViewController = InputViewController()
        let categoryArray = inputViewController.categoryArray
        for num in categoryArray {
            print(num.categoryTitle)
            
            //カテゴリ表示
            let categoryAction = UIAlertAction(title: num.categoryTitle, style: .default) { action in
                print("tapped yes")
                print(num.categoryTitle)
                self.taskArray = try! Realm().objects(Task.self).where({$0.category == num})
                self.tableView.reloadData()
            }
            alert.addAction(categoryAction)
        }
        
        //全表示
        let allviewAction = UIAlertAction(title: "全表示", style: .default) { action in
            self.taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
            self.tableView.reloadData()
        }
        alert.addAction(allviewAction)
        
        //キャンセル
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { action in
        }
        
        // アクションの追加
        
        alert.addAction(cancelAction)
        
        // UIAlertControllerの表示
        present(alert, animated: true, completion: nil)
    }
    //    @IBAction func buttonSearch(_ sender: Any) {
//        //検索欄に文字が入力されてるか
//        if categorySearchField.text?.isEmpty ?? true {
//            //すべてのタスクを配列に格納
//            print("文字が空だよ")
//            self.taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
//        } else {
//            //print(categorySearchField.text)
//            srchCategory = categorySearchField.text!
//            print(srchCategory)
//            //指定されたカテゴリのタスクを格納
//            self.taskArray = try! Realm().objects(Task.self).filter(NSPredicate(format: "category == %@", srchCategory))
//        }
//        self.tableView.reloadData()
//    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil) // ←追加する
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id.stringValue)])
            
            //データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/----------")
                    print(request)
                    print("/----------")
                }
            }
        }
    }
}
