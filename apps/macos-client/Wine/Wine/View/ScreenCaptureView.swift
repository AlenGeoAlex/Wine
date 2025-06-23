//
//  ScreenCaptureOptions.swift
//  Wine
//
//  Created by Alen Alex on 23/06/25.
//

import SwiftUI
import AVFoundation;
import FactoryKit

@available(macOS 15.0, *)
struct ScreenCaptureView: View {
    
    @State var configuration: StreamConfiguration = StreamConfiguration();
    @InjectedObject(\.scVideoCapture) var scScreenCapture : SCVideoCapture;
    
    private var frameRateProxy : Binding<Int> {
        Binding<Int>(
            get: {
                return Int(self.configuration.frameRateInterval.timescale)
            }, set: {
                self.configuration.frameRateInterval = CMTime(value: 1, timescale: Int32($0))

            }
        )
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 2) {
                Text("Recording Configuration")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                
            }.padding(.top, 10)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 15) {
                VStack{
                    Text("Sound settings")
                        .font(.title2)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Configure the sound settings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                }
                            
                HStack {
                    HStack {
                        Image(systemName: "speaker.3")
                        Text("Record System Audio")
                    }
                    Spacer()
                    Toggle(isOn: $configuration.captureSystemAudio, label: { Text("") })
                        .labelsHidden()
                        .toggleStyle(.checkbox)
                }
                
                HStack {
                    HStack{
                        Image(systemName: "microphone")
                        Text("Record Microphone")
                    }
                    Spacer()
                    Toggle(isOn: $configuration.captureMicrophone, label: { Text("") })
                        .labelsHidden()
                        .toggleStyle(.checkbox)
                }


                HStack {
                    HStack{
                        Image(systemName: "microphone.square")
                        Text("Select Device")
                    }
                    Spacer()
                    Picker("Select Device", selection: $configuration.selectedAudioDevice) {
                        ForEach(AudioDevice.current()) { device in
                            Text(device.name)
                                .tag(device)
                        }
                    }
                    .labelsHidden()
                    .disabled(!configuration.captureMicrophone)
                    .frame(maxWidth: 100)
                }
                .opacity(configuration.captureMicrophone ? 1.0 : 0.5)
                }
                .padding()
            
            
            Divider()
            
            VStack(alignment: .leading, spacing: 15) {
                VStack{
                    Text("Video settings")
                        .font(.title2)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Configure the video settings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                }
                            
                HStack {
                    Image(systemName: "video")
                    Text("Sample Rate")
                    Spacer()
                    
                    TextField("Sample Rate", value: $configuration.sampleRate, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 100)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Image(systemName: "video.and.waveform")
                    Text("Frame Rate  (FPS)")
                    Spacer()
                    
                    TextField("Frame Rate", value: frameRateProxy, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 100)
                        .multilineTextAlignment(.trailing)
                }


                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Output format")
                    Spacer()
                    
                    Picker("", selection: $configuration.outputType) {
                        ForEach(StreamOutputType.allCases) { type in
                            Text(type.id)
                                .tag(type)
                        }
                    }
                    .labelsHidden()
                    .frame(maxWidth: 100)
                }
            }
            .padding()
            
            Divider()

            HStack {
                Button {
                    print("Pick Selection tapped")
                } label: {
                    HStack {
                        Image(systemName: "cursorarrow.click.2")
                        Text(isRecordingRunning ? "Update Selection" : "Pick Selection")
                    }
                }.disabled(true)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.blue)
                
                Button {
                    print("Select Source tapped")
                    if(isRecordingRunning){
                        scScreenCapture.stopRecording();
                    }else{
                        scScreenCapture.requestRecordingSource(conf: configuration);
                    }
                } label: {
                    HStack {
                        Image(systemName: "display")
                        Text(isRecordingRunning ? "Update Source" : "Pick Source")
                    }
                }
            }.padding(.top, 15)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.vibrantPurple)
            
            Spacer(minLength: 0)
            
        }.frame(width: 300, height: 500)
    }

    var isRecordingRunning :Bool {
        return scScreenCapture.isRecording
    }

}

@available(macOS 15.0, *)
#Preview {
    ScreenCaptureView()
}
