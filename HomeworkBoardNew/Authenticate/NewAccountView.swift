//
//  NewAccountView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import SwiftUI

struct NewAccountView: View {
    
    @State var member = Member()
    @Binding var isSheetPresented: Bool
    @ObservedObject var MM: MemberManager
    
    var body: some View {
        VStack {
            
            Text("Create a new account")
                .header()
            
            TextField("Username", text: $member.username)
                .disableAutocorrection(true)
                .credStyle(dimensions: (300, 60))
            
            
            SecureField("Password", text: $member.password)
                .credStyle(dimensions: (300, 60))
            
            TextField("Class In", text: $member.clas)
                .disableAutocorrection(true)
                .credStyle(dimensions: (300, 60))
            
            Button {
                Task {
                    await MM.saveAccount(member: member)
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

struct NewAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NewAccountView(isSheetPresented: .constant(true), MM: MemberManager())
    }
}
