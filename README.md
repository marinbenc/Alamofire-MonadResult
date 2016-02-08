# Alamofire-MonadResult
An extension to Alamofire's Result type to make it a monad, i.e. to use map and flatMap on Results.

## Features
 - map (returns a new Result<T, Error> with applied transformation to the value)
 - flatMap (returns a new Result<T, Error> with applied transofrmation to the result)
 - errorOnNil (returns Result.Failure if the value inside a Result is nil)
 - errorOnEmpty (returns Result.Failure if the value insde a Result is an empty CollectionType)

## Examples

Before:
```
    func requestUsers(completion: (Result<[User], NSError> -> Void)) {
        manager.request(.Users)
            .responseJSON { response in
                switch response.result {
                case .Success(let JSON):
                    let users = JSONParser.usersFromJSON(JSON)
                    guard !users.isEmpty else {
                        completion(.Error(.NoUsersFound))
                        return
                    }
                    completion(.Success(users))
                    
                case .Failure(let error):
                    print("RequestLobbies failed with error: \(error)")
                    completion(.Error(.ServerError(error.domain)))
                }
        }
   }
```

After:
```
    func requestUsers(completion: (Result<[User], NSError> -> Void)) {
        manager.request(.Users)
        .responseJSON { response in 
            completion(
                response.result
                .map(JSONParser.usersFromJSON)
                .errorOnEmpty()
            ) 
        }
    }
```
