//
//  LoginModel.swift
//  mentorship ios
//
//  Created by Yugantar Jain on 05/06/20.
//  Copyright © 2020 Yugantar Jain. All rights reserved.
//

import SwiftUI
import Combine

final class LoginModel: ObservableObject {
    struct LoginUploadData: Encodable {
        var username: String
        var password: String
    }

    struct LoginResponseData: Decodable {
        let message: String?
        let access_token: String?
    }
    
    @Published var loginData = LoginUploadData(username: "", password: "")
    @Published var loginResponseData = LoginResponseData(message: "", access_token: "")
    private var cancellable: AnyCancellable?
    
    var loginDisabled: Bool {
        if self.loginData.username.isEmpty || self.loginData.password.isEmpty {
            return true
        }
        return false
    }
        
    func login() {
        guard let uploadData = try? JSONEncoder().encode(loginData) else {
            fatalError("login data unable to be encoded")
        }
        cancellable = NetworkManager.callAPI(urlString: URLStringConstants.login, httpMethod: "POST", uploadData: uploadData, decodeType: loginResponseData)
            .receive(on: RunLoop.main)
            .catch { _ in Just(self.loginResponseData) }
            .assign(to: \.loginResponseData, on: self)
    }
}
