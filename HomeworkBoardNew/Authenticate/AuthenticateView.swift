//
//  AuthenticateView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import SwiftUI

struct AuthenticateView: View {
    
    @State var username = ""
    @State var password = ""
    
    @Binding var success: Bool
    @ObservedObject var MM: AccountManager
    
    @State var createNewAccount = false
    
    var body: some View {
        VStack {
            Text("Login to your account")
                .header()
            
            TextField("Username", text: $username)
                .disableAutocorrection(true)
                .credStyle(dimensions: (300, 60))
            
            SecureField("Password", text: $password)
                .credStyle(dimensions: (300, 60))
            
            Button {
                Task {
                    await MM.auth(username: username, password: password) {
                        success = true
                    }
                }
            } label: {
                Text("Login")
                    .foregroundColor(.black)
                    .bold()
            }
            .bottomButton()
            
            HStack {
                Text("Create Account")
                    .foregroundColor(.black)
                    .onTapGesture {
                        createNewAccount = true
                    }
            }
        }
        .sheet(isPresented: $createNewAccount) {
            NewAccountView(isSheetPresented: $createNewAccount, MM: MM)
        }
    }
}

struct AuthenticateView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticateView(success: .constant(false) ,MM: AccountManager())
    }
}
