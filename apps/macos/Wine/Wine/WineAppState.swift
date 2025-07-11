//
//  AppState.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import Foundation
import Combine
import FactoryKit
import KeyboardShortcuts
import OSLog

@MainActor
@Observable
final class WineAppState {

    let listener: WineListener;
    
    init(){
        self.listener = .init();
    }
    
    
}
