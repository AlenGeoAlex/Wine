//
//  AudioDevice.swift
//  Wine
//
//  Created by Alen Alex on 23/06/25.
//
struct AudioDevice : Identifiable, Hashable {
    var name: String
    var uniqueID: String
    
    var id : String {
        return uniqueID
    }
    
    static func current() -> [AudioDevice] {
        return AVDeviceHelper.getAudioDevices()
            .map({ x in
                return AudioDevice(name: x.localizedName, uniqueID: x.uniqueID)
            })
    }
    
    static func first() -> AudioDevice? {
        return current().first
    }
    
    static func empty() -> [AudioDevice] {
        return []
    }
}
