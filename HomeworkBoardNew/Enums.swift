//
//  Enums.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 17/6/22.
//

import Foundation

enum Permissions: String, Codable {
    case member = "member"
    case subLeader = "subLeader"
    case teacher = "teacher"
    case admin = "admin"
}
