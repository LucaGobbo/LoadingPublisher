//
//  Zip.swift
//
//
//  Created by Luca Gobbo on 26/08/2021.
//

import Combine
import Foundation

// swiftlint:disable identifier_name


public extension LoadingPublishers {
    /// A publisher created by applying the zip function to two upstream publishers. Where both of them are loading
    /// pubishers
    ///
    /// Use `LoadingPublishers.Zip` to combine the latest elements from two publishers and emit a tuple to the
    /// downstream. The returned publisher waits until both publishers have emitted an event, then delivers the oldest
    /// unconsumed event from each publisher together as a tuple to the subscriber.
    ///
    /// Much like a zipper or zip fastener on a piece of clothing pulls together rows of teeth to link the two sides,
    /// `LoadingPublishers.Zip` combines streams from two different publishers by linking pairs of elements from each
    /// side.
    ///
    /// If either upstream publisher finishes successfully or fails with an error, so too does the zipped publisher. if
    /// either of them emit a loading element the zipped publisher will emit this
    /// - Note: duplicate loading elements will be filtered out
    @available(macOS 11.0, *)
    struct Zip<A, B>: Publisher
        where A: Publisher, B: Publisher,
        A.Failure == B.Failure,
        A.Failure == Never,
        A.Output: LoadingStateProtocol,
        B.Output: LoadingStateProtocol,
        A.Output.LoadingFailure == B.Output.LoadingFailure
    {
        // MARK: - Types

        public typealias Output = LoadingState<(A.Output.LoadingOutput, B.Output.LoadingOutput), LoadingFailure>
        public typealias LoadingFailure = A.Output.LoadingFailure
        public typealias LoadingOutput = Output.LoadingOutput
        public typealias Failure = Never

        // MARK: - Properties

        /// A publisher to zip.
        public let a: A

        /// Another publisher to zip.
        public let b: B

        // MARK: - init

        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }

        // MARK: - Publisher

        public func receive<S>(
            subscriber: S
        ) where
            S: Subscriber, Never == S.Failure,
            LoadingState<(A.Output.LoadingOutput, B.Output.LoadingOutput), LoadingFailure> == S.Input
        {
            Publishers.Zip(a, b)
                .setFailureType(to: LoadingFailure.self)
                .flatMap(transform(lhs: rhs:))
                .map(\.output)
                .catch(transform(error:))
                .receive(subscriber: subscriber)
        }

        // MARK: Private


        private enum State {
            case loading
            case value(Output.LoadingOutput)

            var output: Output {
                switch self {
                case .loading: return .loading
                case let .value(output): return .loaded(output)
                }
            }
        }

        private func transform(lhs: A.Output, rhs: B.Output) -> AnyPublisher<State, LoadingFailure> {
            switch (lhs.asLoadingState, rhs.asLoadingState) {
            case let (.loaded(lhs), .loaded(rhs)):
                return Just(State.value((lhs, rhs)))
                    .setFailureType(to: LoadingFailure.self)
                    .eraseToAnyPublisher()

            case let (.failure(error), _):
                return Fail(outputType: State.self, failure: error).eraseToAnyPublisher()

            case let (_, .failure(error)):
                return Fail(outputType: State.self, failure: error).eraseToAnyPublisher()

            default:
                return Just(State.loading)
                    .setFailureType(to: LoadingFailure.self)
                    .eraseToAnyPublisher()
            }
        }

        private func transform(error: LoadingPublishers.Zip<A, B>.LoadingFailure) -> AnyPublisher<Output, Failure> {
            let state = LoadingState<Output.LoadingOutput, Output.LoadingFailure>.failure(error)
            return Just(state).eraseToAnyPublisher()
        }
    }
}
