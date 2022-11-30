//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Radosław Serek on 06/10/2022.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    /// The completion handler can be invoked on any thread.
    /// Clients are responsible for dispatching to appropriate threads, if needed.
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
