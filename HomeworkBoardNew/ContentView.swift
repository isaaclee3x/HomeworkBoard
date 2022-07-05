//
//  ContentView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var MM = MemberManager()
    @StateObject var CM = ClassManager()
    
    @State var success = false
    
    var body: some View {
        NavigationView {
            if !success {
                AuthenticateView(success: $success, MM: MM)
                    .background(color: "lightestBlue")
            } else {
                ClassesView(success: $success, MM: MM)
                    .background(color: colorScheme == .light ? "lightestBlue" : "murkyBlue")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
