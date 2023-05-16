//
//  Category.swift
//  taskapp
//
//  Created by 宮城 光太朗 on 2023/05/09.
//

import RealmSwift

class Category: Object {
    //管理者用ID。 プリマリーキー
    @Persisted(primaryKey: true) var id: ObjectId
    
    //カテゴリ
    @Persisted var categoryTitle = ""
}
