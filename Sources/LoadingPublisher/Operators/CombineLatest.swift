//
//  CombineLatest.swift
//
//
//  Created by Luca Gobbo on 20/09/2021.
//

import Combine
import Foundation

// swiftlint:disable identifier_name

@available(macOS 12.0, *)
@available(iOS 14.0, *)
public extension LoadingPublishers {
    /// A publisher that receives and combines the latest elements from two publishers.
    struct CombineLatest<A, B>: Publisher
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

        public let a: A
        public let b: B

        // MARK: - init

        /// Creates a publisher that receives and combines the latest elements from two publishers.
        /// - Parameters:
        ///   - a: The first upstream publisher.
        ///   - b: The second upstream publisher.
        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }

        // MARK: - Publisher

        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Output {
            Publishers.CombineLatest(a, b)
                .flatMap(transform(lhs:rhs:))
                .receive(subscriber: subscriber)
        }

        // MARK: Private

        private func transform(lhs: A.Output, rhs: B.Output) -> AnyPublisher<Output, Never> {
            switch (lhs.asLoadingState, rhs.asLoadingState) {
            case let (.loaded(lhs), .loaded(rhs)): return .loaded((lhs, rhs))

            case let (.failure(error), _): return .failure(error)
            case let (_, .failure(error)): return .failure(error)
            default: return .loading()
            }
        }
    }

    /// A publisher that receives and combines the latest elements from three publishers.
    struct CombineLatest3<A, B, C>: Publisher
        where A: Publisher, B: Publisher, C: Publisher,
        A.Output: LoadingStateProtocol,
        B.Output: LoadingStateProtocol,
        C.Output: LoadingStateProtocol,
        A.Failure == B.Failure,
        A.Failure == C.Failure,
        A.Failure == Never,
        A.Output.LoadingFailure == B.Output.LoadingFailure,
        A.Output.LoadingFailure == C.Output.LoadingFailure
    {
        // MARK: - Types

        public typealias Output = LoadingState<
            (A.Output.LoadingOutput, B.Output.LoadingOutput, C.Output.LoadingOutput),
            LoadingFailure
        >
        public typealias LoadingFailure = A.Output.LoadingFailure
        public typealias LoadingOutput = Output.LoadingOutput
        public typealias Failure = Never

        // MARK: - Properties

        public let a: A
        public let b: B
        public let c: C

        // MARK: - init

        /// Creates a publisher that receives and combines the latest elements from two publishers.
        /// - Parameters:
        ///   - a: The first upstream publisher.
        ///   - b: The second upstream publisher.
        ///   - c: The third upstream publisher.
        public init(_ a: A, _ b: B, _ c: C) {
            self.a = a
            self.b = b
            self.c = c
        }

        // MARK: - Publisher

        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Output {
            Publishers.CombineLatest3(a, b, c)
                .flatMap(transform)
                .receive(subscriber: subscriber)
        }

        // MARK: Private

        private func transform(a: A.Output, b: B.Output, c: C.Output) -> AnyPublisher<Output, Never> {
            switch (a.asLoadingState, b.asLoadingState, c.asLoadingState) {
            case let (.loaded(a), .loaded(b), .loaded(c)): return .loaded((a, b, c))

            case let (.failure(error), _, _): return .failure(error)
            case let (_, .failure(error), _): return .failure(error)
            case let (_, _, .failure(error)): return .failure(error)

            default: return .loading()
            }
        }
    }

    /// A publisher that receives and combines the latest elements from four publishers.
    struct CombineLatest4<A, B, C, D>: Publisher
        where
        A: Publisher,
        B: Publisher,
        C: Publisher,
        D: Publisher,

        A.Failure == Never,

        A.Output: LoadingStateProtocol,
        B.Output: LoadingStateProtocol,
        C.Output: LoadingStateProtocol,
        D.Output: LoadingStateProtocol,

        A.Failure == B.Failure,
        A.Failure == C.Failure,
        A.Failure == D.Failure,

        A.Output.LoadingFailure == B.Output.LoadingFailure,
        A.Output.LoadingFailure == C.Output.LoadingFailure,
        A.Output.LoadingFailure == D.Output.LoadingFailure
    {
        // MARK: - Types

        public typealias Output = LoadingState<
            (
                A.Output.LoadingOutput,
                B.Output.LoadingOutput,
                C.Output.LoadingOutput,
                D.Output.LoadingOutput
            ),
            LoadingFailure
        >

        public typealias LoadingFailure = A.Output.LoadingFailure
        public typealias LoadingOutput = Output.LoadingOutput
        public typealias Failure = Never

        // MARK: - Properties

        public let a: A
        public let b: B
        public let c: C
        public let d: D

        // MARK: - init

        /// Creates a publisher that receives and combines the latest elements from two publishers.
        /// - Parameters:
        ///   - a: The first upstream publisher.
        ///   - b: The second upstream publisher.
        public init(_ a: A, _ b: B, _ c: C, _ d: D) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
        }

        // MARK: - Publisher

        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Output {
            Publishers.CombineLatest4(a, b, c, d)
                .flatMap(transform)
                .receive(subscriber: subscriber)
        }

        // MARK: Private

        private func transform(a: A.Output, b: B.Output, c: C.Output, d: D.Output) -> AnyPublisher<Output, Never> {
            switch (a.asLoadingState, b.asLoadingState, c.asLoadingState, d.asLoadingState) {
            case let (.loaded(a), .loaded(b), .loaded(c), .loaded(d)): return .loaded((a, b, c, d))

            case let (.failure(error), _, _, _): return .failure(error)
            case let (_, .failure(error), _, _): return .failure(error)
            case let (_, _, .failure(error), _): return .failure(error)
            case let (_, _, _, .failure(error)): return .failure(error)

            default: return .loading()
            }
        }
    }
}
