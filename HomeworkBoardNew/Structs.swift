//
//  Structs.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import Foundation
import SwiftUI

protocol Item {
    var type: String? { get }
    var name: String { get set }
    
    func getProp() -> String
}

struct Member: Identifiable, Equatable, Codable, Item {
    func getProp() -> String {
        return self.clas
    }
    
    /// Creates an empty Member
    
    init() {
        self.name = ""
        self.password = ""
        self.clas = ""
        self.perm = .admin
    }
    
    var id = UUID()
    
    var type: String? = "users"
    /// The account's username
    var name: String
    
    /// The account's password (before encryption)
    var password: String
    
    /// The account's class (ensures they only see their own class)
    var clas: String
    
    /// The account's permission type
    var perm: Permissions
    
}

struct Class: Identifiable, Equatable, Codable, Item {
    
    func getProp() -> String {
        return ""
    }
    ///Creates and empty class
    init(name: String, date: String) {
        self.name = name
        self.board = Board(date: date)
    }
    
    var id = UUID()
    var type: String? = "classes"
    
    ///Name of the class
    var name: String
    
    ///The board
    var board: Board
}

struct Board: Identifiable, Equatable, Codable, Item {
    
    func getProp() -> String {
        return ""
    }
    
    
    ///Creates an empty class
    init(date: String) {
        self.entries = [date:[]]
        self.subjects = []
    }
    
    var id = UUID()

    var type: String? = nil
    var name: String = ""
    
    var entries: [String: [Entry]]
    var subjects: [Subject]
}

struct Entry: Identifiable, Equatable, Codable, Item {
    
    func getProp() -> String {
        return ""
    }
    
    init(entry: String?, due: String?, subject: Subject?) {
        if entry == nil {
            self.entry = " "
        } else {
            self.subject = subject
            self.entry = entry!
            self.due = due
        }
        self.author = ""
    }
    
    var id = UUID()
    
    var type: String? = nil
    var name: String = ""
    var author: String
    
    var subject: Subject?
    var entry: String
    var due: String?
}

struct Subject: Identifiable, Equatable, Codable, Hashable, Item {
    
    func getProp() -> String {
        return ""
    }
    
    init() {
        self.name = ""
        self.colour = RGB(r: 0, g: 0, b: 0)
    }
    var id = UUID()
    
    var type: String? = "subjects"
    var name: String
    
    var colour: RGB
}

struct RGB: Identifiable, Equatable, Codable, Hashable, Item {
    
    func getProp() -> String {
        return ""
    }
    
    var id = UUID()
    
    var type: String? = nil
    var name: String = ""
    
    var r: Double
    var g: Double
    var b: Double
}
