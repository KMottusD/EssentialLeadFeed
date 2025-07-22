//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by KM on 22.07.2025.
//

import Foundation
import EssentialFeed

public class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
        
        let decoratee: FeedImageDataLoader
        let imageCache: FeedImageDataCache
        
        private class TaskWrapper: FeedImageDataLoaderTask {
            var wrapped: FeedImageDataLoaderTask?
            
            func cancel() {
                wrapped?.cancel()
            }
        }
        
        public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
            self.decoratee = decoratee
            self.imageCache = cache
        }
        
        public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            let task = TaskWrapper()
            task.wrapped = decoratee.loadImageData(from: url) { [weak self] result in
                completion(result.map { imageData in
                    self?.imageCache.saveIgnoreResult(imageData, for: url)
                    return imageData
                })
            }
            return task
        }
    }
