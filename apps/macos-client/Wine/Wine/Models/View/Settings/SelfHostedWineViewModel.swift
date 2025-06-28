//
//  SelfHostedWineViewModel.swift
//  Wine
//
//  Created by Alen Alex on 24/06/25.
//

import SwiftUI

class SelfHostedWineViewModel: ObservableObject {

    
    @Published var serverAddress: URL? = nil;
    @Published var secureToken: String = "";
    @Published var lastServerAddressErrorMessage : String? = "";
    @Published var canSave : Bool = false;
    
    init(serverAddress: URL? = nil, secureToken: String) {
        self.serverAddress = serverAddress
        self.secureToken = secureToken
        self.lastServerAddressErrorMessage = nil
        self.canSave = false
        validateSave();
    }
    
    func validateServerAddress(_ serverAddress: String) -> Bool {
        if serverAddress.isEmpty {
            self.lastServerAddressErrorMessage = "Server address cannot be empty";
            return false;
        }
        
         if URL(string: serverAddress) == nil {
            self.lastServerAddressErrorMessage = "Invalid server address";
            return false;
        }
        
        self.lastServerAddressErrorMessage = nil;
        return true;
    }
    
    func validateSave() {
        if self.serverAddress == nil || self.secureToken.isEmpty {
            self.canSave = false;
        }else {
            self.canSave = true;
        }
    }
}
