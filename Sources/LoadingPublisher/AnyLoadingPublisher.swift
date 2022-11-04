//
//  AnyLoadingPublisher.swift
//
//
//  Created by Luca Gobbo on 26/01/2021.
//
import Combine
import Foundation

/// A publisher that performs type erasure by wrapping another publisher which has it's values wrapped in an
/// ``LoadingState``, and has the a `failure` type of `Never`
public typealias AnyLoadingPublisher<LoadingOutput, LoadingFailure: Swift.Error> = AnyPublisher<LoadingState<LoadingOutput, LoadingFailure>, Never>

public extension AnyLoadingPublisher {
    /// easily create a ``AnyLoadingPublisher`` instance where the given element is wrapped in a ``LoadingState/loaded``
    /// - Parameters:
    ///   - output: the value you want to wrap in the publisher
    static func loaded<LoadingOutput, LoadingFailure: Swift.Error>(_ output: LoadingOutput) -> AnyLoadingPublisher<LoadingOutput, LoadingFailure> {
        Just(.loaded(output)).eraseToAnyPublisher()
    }

    /// returns a ``AnyLoadingPublisher`` which is in a ``LoadingState/loading`` state
    static func loading<LoadingOutput, LoadingFailure: Swift.Error>() -> AnyLoadingPublisher<LoadingOutput, LoadingFailure> {
        Just(.loading).eraseToAnyPublisher()
    }

    /// returns a ``AnyLoadingPublisher`` which is in a ``LoadingState/failure`` state
    /// - Parameters:
    ///   - failure: the error failure
    static func failure<LoadingOutput, LoadingFailure: Swift.Error>(_ failure: LoadingFailure) -> AnyLoadingPublisher<LoadingOutput, LoadingFailure> {
        Just(.failure(failure)).eraseToAnyPublisher()
    }
}
