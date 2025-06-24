//
//  TUSWrapper.swift
//  Wine
//
//  Created by Alen Alex on 25/06/25.
//

import Foundation
import TUSKit
import SwiftUI
import OSLog

enum UploadStatus {
    case paused(bytesUploaded: Int, totalBytes: Int)
    case uploading(bytesUploaded: Int, totalBytes: Int)
    case failed(error: Error)
    case uploaded(url: URL)
}

class TUSWrapper: ObservableObject {
    var client: TUSClient?
    let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "TUSWrapper")
    
    @MainActor
    @Published private(set) var uploads: [UUID: UploadStatus] = [:]
    
    init() {
        self.tusClient();
    }
    
    private func tusClient() {
        do {
            let client = try TUSClient(
                            server: URL(string: "http://localhost:3000/file")!,
                            sessionIdentifier: "TUS DEMO",
                            sessionConfiguration: .background(withIdentifier: AppConstants.reversedDomain),
                            storageDirectory: URL(string: "/TUS")!,
                            chunkSize: 0
            );
            self.client = client;
            self.client?.delegate = self
        }
        catch
        {
            logger.error("An error happened while creating TUS client: \(error)");
        }
    }
    
    @MainActor
    func pauseUpload(id: UUID) {
        if(client == nil) {
            return;
        }
        
        try? client!.cancel(id: id)
        
        if case let .uploading(bytesUploaded, totalBytes) = uploads[id] {
            withAnimation {
                uploads[id] = .paused(bytesUploaded: bytesUploaded, totalBytes: totalBytes)
            }
        }
    }
    
    @MainActor
    func resumeUpload(id: UUID) {
        if(client == nil) {
            return;
        }
        

        _ = try? client!.resume(id: id)
        
        if case let .paused(bytesUploaded, totalBytes) = uploads[id] {
            withAnimation {
                uploads[id] = .uploading(bytesUploaded: bytesUploaded, totalBytes: totalBytes)
            }
        }
    }
    
    @MainActor
    func clearUpload(id: UUID) {
        if(client == nil) {
            return;
        }
        
        _ = try? client!.cancel(id: id)
        _ = try? client!.removeCacheFor(id: id)
        
        withAnimation {
            uploads[id] = nil
        }
    }
    
    @MainActor
    func removeUpload(id: UUID) {
        if(client == nil) {
            return;
        }
        
        _ = try? client!.removeCacheFor(id: id)
        
        withAnimation {
            uploads[id] = nil
        }
    }
}


// MARK: - TUSClientDelegate


extension TUSWrapper: TUSClientDelegate {
    func progressFor(id: UUID, context: [String: String]?, bytesUploaded: Int, totalBytes: Int, client: TUSClient) {
        Task { @MainActor in
            print("progress for \(id): \(bytesUploaded) / \(totalBytes) => \(Int(Double(bytesUploaded) / Double(totalBytes) * 100))%")
            uploads[id] = .uploading(bytesUploaded: bytesUploaded, totalBytes: totalBytes)
        }
    }
    
    func didStartUpload(id: UUID, context: [String : String]?, client: TUSClient) {
        Task { @MainActor in
            withAnimation {
                uploads[id] = .uploading(bytesUploaded: 0, totalBytes: Int.max)
            }
        }
    }
    
    func didFinishUpload(id: UUID, url: URL, context: [String : String]?, client: TUSClient) {
        Task { @MainActor in
            withAnimation {
                uploads[id] = .uploaded(url: url)
            }
        }
    }
    
    func uploadFailed(id: UUID, error: Error, context: [String : String]?, client: TUSClient) {
        Task { @MainActor in
            
            withAnimation {
                uploads[id] = .failed(error: error)
            }
            
            if case TUSClientError.couldNotUploadFile(underlyingError: let underlyingError) = error,
               case TUSAPIError.failedRequest(let response) = underlyingError {
                print("upload failed with response \(response)")
            }
        }
    }
    
    func fileError(error: TUSClientError, client: TUSClient) { }
    func totalProgress(bytesUploaded: Int, totalBytes: Int, client: TUSClient) {
        print("total progress: \(bytesUploaded) / \(totalBytes) => \(Int(Double(bytesUploaded) / Double(totalBytes) * 100))%")
    }
}

