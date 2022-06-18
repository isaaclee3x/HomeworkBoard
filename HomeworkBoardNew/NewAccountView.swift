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
    @ObservedObject var MM: AccountManager
    
    var body: some View {
        VStack {
            TextField("Username", text: $member.username)
            SecureField("Password", text: $member.password)
            TextField("Class In", text: $member.clas)
            
            Button {
                Task {
                    await MM.saveAccount(member: member)
                    isSheetPresented = false
                }
            } label: {
                Text("Save")
            }
            
        }
    }
}

struct NewAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NewAccountView(isSheetPresented: .constant(true), MM: AccountManager())
    }
}
