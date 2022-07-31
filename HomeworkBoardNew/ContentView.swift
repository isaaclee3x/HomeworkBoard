//
//  ContentView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var member = Member()
    @State var success = false
    @State var chooseClassView = false
    
    var body: some View {
        if !success {
            NavigationView {
                AuthenticateView(member: $member, success: $success)
                
            }
        } else {
            NavigationView {
                ClassesView(member: $member, success: $success, chooseClassView: $chooseClassView)
            }
        }
    }
}
