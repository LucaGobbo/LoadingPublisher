//
//  File.swift
//
//
//  Created by Luca Gobbo on 26/01/2021.
//

import Combine
import Foundation

public typealias AnyLoadingPublisher<LoadingOutput, LoadingFailure: Swift.Error> = AnyPublisher<LoadingState<LoadingOutput, LoadingFailure>, Never>

public extension AnyLoadingPublisher {
    static func loaded<LoadingOutput, LoadingFailure: Swift.Error>(_ output: LoadingOutput) -> AnyLoadingPublisher<LoadingOutput, LoadingFailure> {
        Just(.loaded(output)).eraseToAnyPublisher()
    }

    static func loading<LoadingOutput, LoadingFailure: Swift.Error>() -> AnyLoadingPublisher<LoadingOutput, LoadingFailure> {
        Just(.loading).eraseToAnyPublisher()
    }

    static func failure<LoadingOutput, LoadingFailure: Swift.Error>(_ failure: LoadingFailure) -> AnyLoadingPublisher<LoadingOutput, LoadingFailure> {
        Just(.failure(failure)).eraseToAnyPublisher()
    }
}
