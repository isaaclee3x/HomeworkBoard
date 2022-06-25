//
//  BoardManager.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 19/6/22.
//

import Foundation
import SwiftUI

class CacheManager {
    
    @ObservedObject var CM = ClassManager()
    
    func updateCache(clas: Class, did what: String) {
        var clas = clas
        clas.board.cache.append(what)
    }
}
