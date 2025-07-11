//
//  MenuBarComponent.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//
import SwiftUI
import FactoryKit
import Combine
import OSLog
import KeyboardShortcuts
import Defaults


struct MenuBarComponent: View {
    
    @State var viewModel: MenuBarViewModel = .init()
    
    var body: some View {
        Group {
            Button {
                Logger.common.log("Screenshot")
                viewModel.takeScreenshot()
            } label: {
                HStack {
                    Image(systemName: "camera.on.rectangle")
                    Text("Take Screenshot")
                }
            }
            .buttonStyle(.plain)
            .onGlobalKeyboardShortcut(KeyboardShortcuts.Name.takeScreenshot, type: .keyUp, perform: {
                viewModel.takeScreenshot()
            })
            
            Button {
                viewModel.toggleRecording()
            } label: {
                HStack {
                    Image(systemName: viewModel.isScreenRecording ? "stop.circle.fill" : "record.circle")
                    Text(viewModel.isScreenRecording ? "Stop recording" : "Start recording")
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(viewModel.isScreenRecording ? .red : .primary)
            .onGlobalKeyboardShortcut(KeyboardShortcuts.Name.toggleRecording, type: .keyUp, perform: {
                viewModel.toggleRecording()
            })
            
            if viewModel.isCloudEnabled {
                Button {
                    
                } label: {
                    HStack {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.page.on.clipboard")
                        Text("Upload from clipboard")
                    }
                }
            }
            
            Divider()
        }
        Group {
            SettingsLink(){
                HStack {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            }
            
            if viewModel.isCloudEnabled {
                Button{
                    
                } label: {
                    HStack {
                        Image(systemName: "externaldrive.badge.icloud")
                        Text("Cloud History")
                    }
                }
            }
            
            Divider()
        }
        
        Group {
            Button() {
                
            } label: {
                HStack {
                    Image(systemName: "info")
                    Text("About")
                }
            }
            
            Button() {
                NSApplication.shared.terminate(nil)
            } label: {
                HStack{
                    Image(systemName: "xmark.circle")
                    Text("Quit")
                }
            }
        }
    }
}

@Observable class MenuBarViewModel {
    
    @ObservationIgnored private var logger: Logger = Logger.create()
    @ObservationIgnored private var cancellables: Set<AnyCancellable> = []
    @ObservationIgnored @Injected(\.screenRecordService) private var screenRecordingService
    @ObservationIgnored @Injected(\.screenshotService) private var screenshotService
    
    
    
    var isScreenRecording: Bool
    var isCloudEnabled: Bool;
    
    init() {
        self.isScreenRecording = false
        self.isCloudEnabled = false
        self.initialize()
    }
    
    private func initialize() {
        screenRecordingService.screenRecordings
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                if value == nil {
                    self?.logger.info("Screen recording has been stopped, Updating UI")
                    self?.isScreenRecording = false
                } else {
                    self?.logger.info("Screen recording has been started, Updating UI")
                    self?.isScreenRecording = true
                }
            })
            .store(in: &cancellables)
        
        Defaults.publisher(.cloudProvider, options: [.initial])
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] change in
                self?.isCloudEnabled = change.newValue != CloudProviders.none.id
                self?.logger.info("Cloud provider changed to \(String(describing: change.newValue))")
            })
            .store(in: &cancellables)
    }
    
    func takeScreenshot() {
        Task {
           let _ = await screenshotService.capture();
        }
    }
    
    func toggleRecording() {
        if isScreenRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        logger.info("Starting screen recording")
    }
    
    private func stopRecording() {
        logger.info("Stopping screen recording")
    }
}
