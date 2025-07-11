//
//  ServerProtocol.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import Foundation
protocol ServerProtocol {
    
    /// Pings the server
    func ping(url: URL) -> Result<Bool, Error>;
    
}
