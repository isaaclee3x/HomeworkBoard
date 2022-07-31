//
//  ChangeDefaultPassword.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 25/7/22.
//

import SwiftUI

struct ChangeDefaultPassword: View {
    
    @State var newPassword = ""
    @State var confirmPassword = ""
    
    @State var notEqualPassword = false
    @Binding var isSheetPresented: Bool
    @Binding var member: Member
    
    var MM: MemberManager
    
    
    var body: some View {
        VStack {
            Text("**Reset** your password")
                .header()
            
            Text("Please change your password")
                .bold()
                .frame(width: 150)
                .padding()
            
            TextField("Password", text: $newPassword)
                .credStyle(width: 300, height: 60)
                .disableAutocorrection(true)
            
            TextField("Confirm Password:", text: $confirmPassword)
                .credStyle(width: 300, height: 60)
                .disableAutocorrection(true)
            
            Button {
                if newPassword == confirmPassword {
                    member.password = newPassword
                    Task {
                        await MM.saveAccount(member: member, bypass: false)
                    }
                    isSheetPresented = false
                }
            } label: {
                Text("Save")
                    .bold()
            }
            .bottomButton()
        }
        .background(color: "lightestBlue")
    }
}


