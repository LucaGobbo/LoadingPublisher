![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-green.svg)

# LoadingPublisher
Loading abstraction for Combine Publishers

based on [ReactiveKit](https://github.com/DeclarativeHub/ReactiveKit)'s LoadingSignal

## Installation

LoadingPublisher is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a project, simply add it as a dependency within your Package.swift manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/LucaGobbo/LoadingPublisher", from: "0.0.1"),
    ],
    ...
)
```

Then import LoadingPublisher wherever you'd like to use it:

```
import LoadingPublisher
```

## Usage

LoadingPublisher adds the ability to add a generic loading state to a publisher. To indicate loading we've added the `LoadingState` enum, which can be in 3 states, loading, loaded and loading failed.

A publisher with elements of LoadingState type is typealiased as AnyLoadingPublisher

`typealias AnyLoadingPublisher<LoadingOutput, LoadingFailure: Swift.Error> = AnyPublisher<LoadingState<LoadingOutput, LoadingFailure>, Never>`

A publisher can easily be converted into an `AnyLoadingPublisher` by calling `eraseToAnyLoadingPublisher` on any publisher.

```
    fetchImage.eraseToAnyLoadingPublisher().sink { value in 
        switch value {
            case .loading: 
                // display loading indicator
            case .loaded(let image):
                // display image
                // stop loading indicator
            case .failure(let error):
                // display the error
                // stop loading indicator
        }
    
    }
``` 

LoadingPublisher also adds operators on `AnyLoadingPublisher`, `mapLoadingOutput`, `isLoading`, `flatMapLatestLoading`, `dematerializeLoadingState` and more. It also adds the `LoadingPublishers` namespace where we've defined some default Publishers like `Zip`, `CombineLatests`. New ones can be requested when needed
