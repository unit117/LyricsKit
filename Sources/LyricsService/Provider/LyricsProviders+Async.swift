//
//  LyricsProviders+Async.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if canImport(Combine)
import Foundation
import Combine
import LyricsCore

// MARK: - Async/Await Extensions for LyricsProviders.Group

extension LyricsProviders.Group {
    
    /// Search for lyrics using Swift Concurrency
    /// - Parameter request: The lyrics search request
    /// - Returns: Array of found lyrics, sorted by quality
    public func searchLyrics(request: LyricsSearchRequest) async throws -> [Lyrics] {
        try await withCheckedThrowingContinuation { continuation in
            var results: [Lyrics] = []
            var hasCompleted = false
            
            let cancellable = lyricsPublisher(request: request)
                .collect()
                .sink(
                    receiveCompletion: { completion in
                        guard !hasCompleted else { return }
                        hasCompleted = true
                        switch completion {
                        case .finished:
                            continuation.resume(returning: results.sorted { $0.quality > $1.quality })
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { lyrics in
                        results = lyrics
                    }
                )
            
            // Store cancellable to keep subscription alive
            _ = cancellable
        }
    }
    
    /// Stream lyrics results as they arrive
    /// - Parameter request: The lyrics search request
    /// - Returns: AsyncThrowingStream that emits lyrics as they are found
    public func lyricsStream(request: LyricsSearchRequest) -> AsyncThrowingStream<Lyrics, Error> {
        AsyncThrowingStream { continuation in
            let cancellable = lyricsPublisher(request: request)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            continuation.finish()
                        case .failure(let error):
                            continuation.finish(throwing: error)
                        }
                    },
                    receiveValue: { lyrics in
                        continuation.yield(lyrics)
                    }
                )
            
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}

// MARK: - Async/Await Extensions for LyricsProvider

extension LyricsProvider {
    
    /// Search for lyrics using Swift Concurrency
    /// - Parameter request: The lyrics search request
    /// - Returns: Array of found lyrics
    public func searchLyrics(request: LyricsSearchRequest) async throws -> [Lyrics] {
        try await withCheckedThrowingContinuation { continuation in
            var results: [Lyrics] = []
            var hasCompleted = false
            
            let cancellable = lyricsPublisher(request: request)
                .collect()
                .sink(
                    receiveCompletion: { completion in
                        guard !hasCompleted else { return }
                        hasCompleted = true
                        switch completion {
                        case .finished:
                            continuation.resume(returning: results)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { lyrics in
                        results = lyrics
                    }
                )
            
            _ = cancellable
        }
    }
    
    /// Stream lyrics results as they arrive
    /// - Parameter request: The lyrics search request
    /// - Returns: AsyncThrowingStream that emits lyrics as they are found
    public func lyricsStream(request: LyricsSearchRequest) -> AsyncThrowingStream<Lyrics, Error> {
        AsyncThrowingStream { continuation in
            let cancellable = lyricsPublisher(request: request)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            continuation.finish()
                        case .failure(let error):
                            continuation.finish(throwing: error)
                        }
                    },
                    receiveValue: { lyrics in
                        continuation.yield(lyrics)
                    }
                )
            
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}

#endif
