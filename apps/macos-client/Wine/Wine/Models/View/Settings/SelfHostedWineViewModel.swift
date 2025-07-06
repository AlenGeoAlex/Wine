//
//  SelfHostedWineViewModel.swift
//  Wine
//
//  Created by Alen Alex on 24/06/25.
//

import SwiftUI
import Combine
import FactoryKit

class SelfHostedWineViewModel: ObservableObject {

    @Published var serverAddressString: String = ""
    @Published var secureToken: String = ""
    @Published var lastServerAddressErrorMessage : String? = ""
    @Published var canSave : Bool = false
    
    private var serverAddress: URL? = nil
    private var cancellables = Set<AnyCancellable>()
    
    private let settingsService : SettingsService
    private let apiUploadService: FileUploadApiService

    @MainActor
    init() {
        self.settingsService = Container.shared.settingsService.resolve()
        self.apiUploadService = Container.shared.fileUploadApi.resolve()
        
        let initialSettings = settingsService.uploadSettings.type.wineSettings
        self.serverAddress = initialSettings.serverAddress
        self.serverAddressString = initialSettings.serverAddress.absoluteString
        self.secureToken = initialSettings.secureToken
        
        $serverAddressString
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.validateServerAddress(text)
                self?.validateSave()
            }
            .store(in: &cancellables)
        
        $secureToken
            .sink { [weak self] _ in
                self?.validateSave()
            }
            .store(in: &cancellables)
            
        validateSave()
    }
    
    private func validateServerAddress(_ address: String) {
        guard !address.isEmpty else {
            self.serverAddress = nil; self.lastServerAddressErrorMessage = nil; return
        }
        if let url = URL(string: address), (url.scheme == "http" || url.scheme == "https") {
            self.serverAddress = url; self.lastServerAddressErrorMessage = nil
        } else {
            self.serverAddress = nil; self.lastServerAddressErrorMessage = "Invalid HTTP(s) URL"
        }
    }
    
    private func validateSave() {
        self.canSave = self.serverAddress != nil && !self.secureToken.isEmpty
    }
    
    @MainActor
    func saveSettings() -> String? {
        guard let url = self.serverAddress else { return "Server address is invalid." }
        guard !self.secureToken.isEmpty else { return "Secure token is required." }
        
        var settings = WineServerSettings()
        settings.serverAddress = url
        settings.secureToken = self.secureToken
        
        settingsService.uploadSettings.type = .wine(settings)
        
        return nil
    }
    
    @MainActor
    func testConnection() async -> String? {
        guard let url = self.serverAddress else {
            return "Server address is required to test connection."
        }
        
        let pingResponse = await self.apiUploadService.pingServer(url: url)
        
        switch pingResponse {
        case .success:
            return nil
        case .failure(let err):
            return err.localizedDescription
        }
    }
}
