//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Radosław Serek on 15/11/2022.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "Invalid request", code: 400)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}
