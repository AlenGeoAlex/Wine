//
//  CloudUploadProgress.swift
//  Wine
//
//  Created by Alen Alex on 06/07/25.
//

import SwiftUI

struct CloudUploadProgress: View {
    
   @StateObject public var model: CloudUploadProgressModel = CloudUploadProgressModel()
    
    var body: some View {
        VStack {
            ProgressView(value: model.current, total: 100, label: {
                Text("Uploading...")
                    .padding(.bottom, 5)
            }, currentValueLabel: {
                Text("\(Int(model.current))%")
            })
        }.frame(width: 200, height: 200)
            .padding(20)
            .progressViewStyle(.circular)
            .onReceive(model.timer) { _ in
                model.updateProgress()
            }
    }
    
    
}

#Preview {
    CloudUploadProgress()
}

class CloudUploadProgressModel: ObservableObject {
    @Published var current: Double = 0
    let total: Double = 100

    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    public func updateProgress(progress: Double = 0) {
        if current < total {
            current += progress
        } else {
            timer.upstream.connect().cancel()
        }
    }
    
    
    
}
