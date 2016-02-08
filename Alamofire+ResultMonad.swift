//
//  Alamofire+ResultMonad.swift
//
//  Created by Marin Bencevic on 08/02/16.
//  https://github.com/marinbenc/Alamofire-MonadResult
//

import Foundation
import Alamofire

extension Result {
    func map<U>(transform: Value -> U)-> Result<U, Error> {
        switch self {
        case .Failure(let error): return Result<U, Error>.Failure(error)
        case .Success(let value): return Result<U, Error>.Success(transform(value))
        }
    }
    
    func flatMap<U>(transform: Value -> Result<U, Error>)-> Result<U, Error> {
        switch self {
        case .Failure(let error): return Result<U, Error>.Failure(error)
        case .Success(let value): return transform(value)
        }
    }
}

// Credit to Artsy and @ashfurrow
// And @thanegill

public protocol OptionalType {
    typealias Wrapped
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    /// Cast `Optional<Wrapped>` to `Wrapped?`
    public var value: Wrapped? {
        return self
    }
}

extension Result where Value: OptionalType {
    func errorOnNil()-> Result<Value.Wrapped, Error> {
        return self.flatMap { optionalValue -> Result<Value.Wrapped, Error> in
            if let unwrappedValue = optionalValue.value {
                return Result<Value.Wrapped, Error>.Success(unwrappedValue)
            } else {
                let error = NSError(domain: "Value \(optionalValue) is nil", code: 0, userInfo: nil)
                return Result<Value.Wrapped, Error>.Failure(error as! Error)
            }
        }
    }
}

extension Result where Value: CollectionType {
    func errorOnEmpty()-> Result<Value, Error> {
        return self.flatMap { collection -> Result<Value, Error> in
            if collection.isEmpty {
                let error = NSError(domain: "Collection \(collection) is empty", code: 0, userInfo: nil)
                return Result<Value, Error>.Failure(error as! Error)
            } else {
                return Result<Value, Error>.Success(collection)
            }
        }
    }
}
