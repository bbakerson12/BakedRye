//
//  Category.swift
//  BakeRyeBudgets
//
//  Created by Alex Baker on 10/9/20.
//
import RealmSwift
import Foundation

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let expenses = List<Expense>()
}
