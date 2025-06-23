//
//  S3HostedSetting.swift
//  Wine
//
//  Created by Alen Alex on 24/06/25.
//

import SwiftUI

struct S3HostedSetting: View {

    @Binding var s3Setting : S3Settings;
    
    var body: some View {
        VStack {
            SettingsGroup {
                HStack {
                    Image(systemName: "network")
                    VStack(alignment: .leading) {
                        Text("Endpoint").fontWeight(.medium)
                        Text("The endpoint of the s3 storage bucket").font(.callout).foregroundColor(.secondary)
                    }
                    Spacer()
                    TextField("https://us-east-1.amazonaws.com/", text: $s3Setting.endpoint)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        //.border(selfhostedWineViewModel.lastServerAddressErrorMessage != nil ? Color.red : Color.clear, width: 1)
                        
                }
                
                Divider()
                HStack {
                    Spacer()
                    Text("The valid endpoint is used to connect to the S3 storage bucket.")
                }.padding(.top, 4)
            }
            
            SettingsGroup {
                HStack {
                    Image(systemName: "person.text.rectangle")
                    VStack(alignment: .leading) {
                        Text("Access Key ID").fontWeight(.medium)
                        Text("The access key associated with the S3 storage bucket").font(.callout).foregroundColor(.secondary)
                    }
                    Spacer()
                    TextField("Access Key", text: $s3Setting.accessKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        //.border(selfhostedWineViewModel.lastServerAddressErrorMessage != nil ? Color.red : Color.clear, width: 1)
                        
                }
                
                Divider()
                HStack {
                    Spacer()
                    Text("Access key used to authenticate the S3 storage bucket connection.")
                }.padding(.top, 4)
            }
            
            SettingsGroup {
                HStack {
                    Image(systemName: "key")
                    VStack(alignment: .leading) {
                        Text("Secret Key").fontWeight(.medium)
                        Text("The secret key associated with the S3 storage bucket").font(.callout).foregroundColor(.secondary)
                    }
                    Spacer()
                    SecureField("Secret Key", text: $s3Setting.accessKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        //.border(selfhostedWineViewModel.lastServerAddressErrorMessage != nil ? Color.red : Color.clear, width: 1)
                        
                }
                
                Divider()
                HStack {
                    Spacer()
                    Text("Secret key used to authenticate the S3 storage bucket.")
                }.padding(.top, 4)
            }
            
            SettingsGroup {
                HStack {
                    Image(systemName: "externaldrive.connected.to.line.below")
                    VStack(alignment: .leading) {
                        Text("Bucket Name").fontWeight(.medium)
                        Text("Name of the bucket").font(.callout).foregroundColor(.secondary)
                    }
                    Spacer()
                    TextField("wine-bucket", text: $s3Setting.accessKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        //.border(selfhostedWineViewModel.lastServerAddressErrorMessage != nil ? Color.red : Color.clear, width: 1)
                        
                }
                
                Divider()
                HStack {
                    Spacer()
                    Text("Name of the bucket where the images are stored.")
                }.padding(.top, 4)
            }
            
            SettingsGroup {
                HStack {
                    Image(systemName: "network")
                    VStack(alignment: .leading) {
                        Text("Custom domain").fontWeight(.medium)
                        Text("Custom domain of the application to be replaced with the S3 buckets key").font(.callout).foregroundColor(.secondary)
                    }
                    Spacer()
                    TextField("wine-bucket", text: $s3Setting.accessKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        //.border(selfhostedWineViewModel.lastServerAddressErrorMessage != nil ? Color.red : Color.clear, width: 1)
                        
                }
                
                Divider()
                HStack {
                    Spacer()
                    Text("The domain of the s3 bucket url will be replaced with the custom domain")
                }.padding(.top, 4)
            }
        }
    }
}

#Preview {
    S3HostedSetting(s3Setting: Binding.constant(S3Settings()))
}
