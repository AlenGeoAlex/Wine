//
//  SelfHostedWineViewModel.swift
//  Wine
//
//  Created by Alen Alex on 24/06/25.
//

import SwiftUI

class SelfHostedWineViewModel: ObservableObject {
    
    init(){
        self.lastServerAddressErrorMessage = nil;
    }
    
    @Published var lastServerAddressErrorMessage : String? = "";
    
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
}
