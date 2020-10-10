//
//  Expense.swift
//  BakeRyeBudgets
//
//  Created by Alex Baker on 10/9/20.
//
import RealmSwift
import Foundation

class Expense: Object {
    @objc dynamic var title: String = ""
    
    @objc dynamic var amount: Float = 0.00
    
    @objc dynamic var done: Bool = false
    
    @objc dynamic var dateCreated: Date?
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "expenses")
    
}
