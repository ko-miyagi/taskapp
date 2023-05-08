//
//  Task.swift
//  taskapp
//
//  Created by 宮城 光太朗 on 2023/04/24.
//

import RealmSwift

class Task: Object {
    //管理者用ID。 プリマリーキー
    @Persisted(primaryKey: true) var id: ObjectId
    
    //タイトル
    @Persisted var title = ""
    
    //内容
    @Persisted var contents = ""
    
    //日時
    @Persisted var date = Date()
    
    //カテゴリ
    @Persisted var category = ""
}
