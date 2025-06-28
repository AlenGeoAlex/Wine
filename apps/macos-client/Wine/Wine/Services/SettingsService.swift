//
//  SettingsService.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//

import Foundation
import Combine
import AppKit
import OSLog

@MainActor
class SettingsService : ObservableObject {
    
    private var logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "SettingsService");
    
    @Published var appSettings: AppSettings;
    @Published var uploadSettings: UploadSettings;
    
    private var cancellables = Set<AnyCancellable>();
    
    init(){
        self.appSettings = AppSettings();
        self.uploadSettings = UploadSettings(type: .none)
        
        self.loadAppSettings();
        self.loadUploadsSettings();

        $appSettings.debounce(for: .milliseconds(700), scheduler: DispatchQueue.main)
            .sink{
                [weak self] settings in self?.saveGeneralSettings(settings)
            }
            .store(in: &cancellables)
        
        $uploadSettings.debounce(for: .milliseconds(700), scheduler: DispatchQueue.main)
            .sink {
                [weak self] settings in self?.saveUploadSettings(uploadSettings: settings.type)
            }
            .store(in: &cancellables)
    }
    
    public func setKeyBinds(orginalAction: BindableAction, key: KeyboardKey){
        resetDuplicateKeyBinds(orginalAction: orginalAction, keyToSet: key)
        appSettings.bindings[orginalAction] = key
        appSettings.versionId = UUID();
        logger.info("Update general setting to version \(self.appSettings.versionId)")
    }
    
    public func resetKeybinds(){
        appSettings.bindings.forEach{ (binding, key) in
            appSettings.bindings[binding] = nil
        }
        appSettings.versionId = UUID();
        logger.info("Resetted Keybinds to version \(self.appSettings.versionId)")
    }
    
    private func resetDuplicateKeyBinds(orginalAction: BindableAction, keyToSet: KeyboardKey){
        logger.info("Checking duplicate key binds for action \(orginalAction.id) and key \(keyToSet.displayText).")
        appSettings.bindings.forEach{ (binding, key) in
            if(binding == orginalAction){
                return;
            }
            
            if(key == keyToSet){
                logger.warning( "Duplicate key bindings found. Resetting action \(binding.id)_.")
                appSettings.bindings[binding] = nil
            }
        }
    }
    
    private func saveGeneralSettings(_ settings: AppSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: AppConstants.Settings.generalSettingsKey)
            logger.info("General settings saved.")
        } else {
            logger.error("Failed to encode and save general settings.")
        }
    }
    
    private func loadAppSettings(){
        if let appData = UserDefaults.standard.data(forKey: AppConstants.Settings.generalSettingsKey),
           let deserializedSettings = try? JSONDecoder().decode(AppSettings.self, from: appData)
            {
                self.appSettings = deserializedSettings
                logger.info( "General settings loaded.")
            }
    }
    
    private func loadUploadsSettings(){
        
        guard let uploadTypeRaw = UserDefaults.standard.string(forKey: AppConstants.Settings.uploadTypeSetting),
              let uploadType = UploadSource.allCases.first(where: { $0.id == uploadTypeRaw }) else {
            return
        };
        
        logger.info("Upload type: \(uploadType.id)")
        do {
            let uploadSettings: UploadSource

            switch uploadType {
            case .none:
                uploadSettings = .none
            case .wineCloud:
                uploadSettings = .wineCloud
            case .wine:
                let creds: WineServerSettings = try KeychainHelper.loadSettings(forService: AppConstants.Settings.wineServerSetting)
                uploadSettings = .wine(creds)
            case .s3:
                let creds: S3Settings = try KeychainHelper.loadSettings(forService: AppConstants.Settings.s3ServerSetting)
                uploadSettings = .s3(creds)
            case .r2:
                let creds: R2Settings = try KeychainHelper.loadSettings(forService: AppConstants.Settings.r2ServerSetting)
                uploadSettings = .r2(creds)
            case .backblaze:
                let creds: BackblazeSettings = try KeychainHelper.loadSettings(forService: AppConstants.Settings.backblazeServerSetting)
                uploadSettings = .backblaze(creds)
            case .sftp:
                let creds: SFTPSettings = try KeychainHelper.loadSettings(forService: AppConstants.Settings.sftoServerSetting)
                uploadSettings = .sftp(creds)
            }

            self.uploadSettings = UploadSettings(type: uploadSettings)
            logger.info("Loaded upload settings from OSX Keychain")
        } catch {
            logger.error("Failed to get the upload settings from OSX Keychain due to \(error)")
        }
    }
    
    public func saveUploadSettings(uploadSettings: UploadSource){
        UserDefaults.standard.set(uploadSettings.id, forKey: AppConstants.Settings.uploadTypeSetting)
        logger.info("Saving upload settings to OSX Keychain")
        switch uploadSettings {
        case .wine(let settings):
            do {
                try  KeychainHelper.saveSettings(settings, forService: AppConstants.Settings.wineServerSetting)
            }catch {
                logger.error("Failed to save wine credentials to key chain due to \(error)")
            }
        case .s3(let settings):
            do {
                try  KeychainHelper.saveSettings(settings, forService: AppConstants.Settings.s3ServerSetting)
            }catch{
                logger.error( "Failed to save s3 credentials to key chain due to \(error)")
            }
        case .r2(let settings):
            do {
                try  KeychainHelper.saveSettings(settings, forService: AppConstants.Settings.r2ServerSetting)
            }catch {
                logger.error("Failed to save r2 credentials to key chain due to \(error)")
            }
        case .backblaze(let settings):
            do {
                try  KeychainHelper.saveSettings(settings, forService: AppConstants.Settings.backblazeServerSetting)

            }catch {
                logger.error("Falied to save backblaze credentials to key chain due to \(error)")
            }
        case .sftp(let settings):
            do {
                try  KeychainHelper.saveSettings(settings, forService: AppConstants.Settings.sftoServerSetting)
            }catch {
                logger.error("Falied to save sftp credentials to key chain due to \(error)")
            }
        default :
            break
        }
    }
    
}
