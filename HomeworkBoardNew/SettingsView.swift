//
//  SettingsView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 5/7/22.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var MM: MemberManager
    
    var body: some View {
        Form {
            if MM.member?.perm == .admin {
                
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(MM: MemberManager())
    }
}
