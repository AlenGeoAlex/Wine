//
//  SelfHostedWine.swift
//  Wine
//
//  Created by Alen Alex on 24/06/25.
//

import SwiftUI
import FactoryKit

struct SelfHostedWine: View {
    
    @State private var selfhostedWineViewModel : SelfHostedWineViewModel;
    @State private var showingAlertForTest : Bool = false;
    @State private var alertMessageForTest : String? = "";
    @State private var showingAlertForSave : Bool = false;
    @State private var alertMessageForSave : String? = "";
    
    let settingsService : SettingsService = Container.shared.settingsService.resolve()
    var apiUploadService: FileUploadApiService = Container.shared.fileUploadApi.resolve()
    
    init(){
        selfhostedWineViewModel = SelfHostedWineViewModel(serverAddress: settingsService.uploadSettings.type.wineSettings.serverAddress,
                                                          secureToken: settingsService.uploadSettings.type.wineSettings.secureToken)
    }
    
    private var urlStringProxy : Binding<String> {
        return Binding(get: {
            return self.selfhostedWineViewModel.serverAddress?.absoluteString ?? "";
        }, set: {
            guard let urlString = URL(string: $0) else {
                self.selfhostedWineViewModel.lastServerAddressErrorMessage = "Invalid URL";
                return
            }
            self.selfhostedWineViewModel.serverAddress = urlString;
        })
    }
    
    var body: some View {
        VStack {
            SettingsGroup {
                HStack {
                    Image(systemName: "opticaldisc")
                    VStack(alignment: .leading) {
                        Text("Server address").fontWeight(.medium)
                        Text("Valid HTTP(s) url to connect to the self hosted wine server").font(.callout).foregroundColor(.secondary)
                    }
                    Spacer()
                    TextField("https://wine.example.com", text: urlStringProxy)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .border(selfhostedWineViewModel.lastServerAddressErrorMessage != nil ? Color.red : Color.clear, width: 1)
                        
                }
                
                Divider()
                HStack {
                    Spacer()
                    Text("The server address is used to connect to the Wine server.")
                }.padding(.top, 4)
            }
            
            SettingsGroup {
                HStack {
                    Image(systemName: "key.fill")
                    VStack(alignment: .leading) {
                        Text("Secure token").fontWeight(.medium)
                        Text("A valid token generated by the self hosted wine instance").font(.callout).foregroundColor(.secondary)
                    }
                    Spacer()
                    SecureField("Secure token", text: $selfhostedWineViewModel.secureToken)
                }
                
                Divider()
                HStack {
                    Spacer()
                    Text("The access token to access the server.")
                }.padding(.top, 4)
            }
            
            Section {
                HStack(alignment: .center, spacing: 20) {
                    Button(action: {
                        Task {
                            await testConnection()
                        }
                    }, label: {
                        Text("Test").fontWeight(.medium)
                    })
                    .alert(Text(alertMessageForTest != nil ? "Failed to connect to the server" : "Connection success"), isPresented: $showingAlertForTest, actions: {
                        Button("Ok") {
                            showingAlertForTest.toggle()
                        }
                    }, message: {
                        Text(alertMessageForTest ?? "Connection success")
                    })
                    
                    Button(action: {
                        Task {
                            await saveSettings()
                        }
                    }, label: {
                        Text("Save").fontWeight(.medium)
                    }).alert(Text(alertMessageForSave != nil ? "Failed to save settings" : "Settings saved"), isPresented: $showingAlertForSave, actions: {
                        Button("Ok") {
                            showingAlertForSave.toggle()
                        }
                    }, message: {
                        Text(alertMessageForSave ?? "Save success")
                    }).disabled(!selfhostedWineViewModel.canSave)
                }
            }.padding(.top, 10)
        }
    }
    
    private func saveSettings() async {
        guard let url = selfhostedWineViewModel.serverAddress else {
            showingAlertForSave = true
            alertMessageForSave = "Server address is required"
            return;
        }
        
        if selfhostedWineViewModel.secureToken.isEmpty {
            showingAlertForSave = true
            alertMessageForSave = "Server address is required"
            return;
        }
        
        var settings = WineServerSettings();
        settings.serverAddress = url;
        settings.secureToken = selfhostedWineViewModel.secureToken;
        settingsService.uploadSettings.type = .wine(settings)
        showingAlertForSave = true
        alertMessageForSave = nil
    }
    
    private func testConnection() async -> Bool {
        guard let url = selfhostedWineViewModel.serverAddress else {
            return false
        }
        
        let pingResponse = await self.apiUploadService.pingServer(url: url);
        
        switch pingResponse {
        case .success(_):
            showingAlertForTest = true
            alertMessageForTest = nil
            return true;
        case .failure(let err):
            showingAlertForTest = true
            alertMessageForTest = err.localizedDescription
            return false;
        }
    }
    
    var disabledTestButton : Bool {
        return selfhostedWineViewModel.serverAddress == nil;
    }
    
    var disabledSaveButton : Bool {
        return selfhostedWineViewModel.serverAddress == nil || selfhostedWineViewModel.secureToken != "";
    }
}
