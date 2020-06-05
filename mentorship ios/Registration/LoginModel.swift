//
//  LoginModel.swift
//  mentorship ios
//
//  Created by Yugantar Jain on 05/06/20.
//  Copyright © 2020 Yugantar Jain. All rights reserved.
//

import SwiftUI
import Combine

struct LoginUploadData: Encodable {
    var username: String
    var password: String
}

struct LoginDataReceived: Decodable {
    let message: String?
    let access_token: String?
}

final class LoginModel: ObservableObject {
    @Published var loginUploadData = LoginUploadData(username: "", password: "")
    @Published var loginResponseData = LoginDataReceived(message: "initial message", access_token: "")
    
    var loginDisabled: Bool {
        if self.loginUploadData.username.isEmpty || self.loginUploadData.password.isEmpty {
            return true
        }
        return false
    }
    
    private var cancellable: AnyCancellable?
    
    func network(uploadData: Data) -> AnyPublisher<LoginDataReceived, Error> {
        let url = URL(string: "https://mentorship-backend-temp.herokuapp.com/login")!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = uploadData
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: LoginDataReceived.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getMessage(uploadData: Data) {
        cancellable = network(uploadData: uploadData)
            .receive(on: RunLoop.main)
            .catch { _ in Just(self.loginResponseData) }
            .assign(to: \.loginResponseData, on: self)
    }
    
}
