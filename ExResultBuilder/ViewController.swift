//
//  ViewController.swift
//  ExResultBuilder
//
//  Created by 김종권 on 2023/08/10.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        combineAsyncResults { result in
            switch result {
            case .success(let combinedResult):
                print("Combined result:", combinedResult)
            case .failure(let error):
                print("Error:", error)
            }
        }
    }
}

@resultBuilder
enum Builder {
    static func buildBlock(_ components: Int...) -> Int {
        components.reduce(0, +)
    }
}

func combineAsyncResultsWithBuilder(completion: @escaping (Result<Int, Error>) -> Void) {
    DispatchQueue.global().async {
        let result1 = Result { try fetchData1() }
        let result2 = Result { try fetchData2() }
        
        let combinedResult = Builder.buildBlock(
            try! result1.get(), // 예제 편의를 위해 강제 unwrapping 사용
            try! result2.get()
        )
        
        completion(.success(combinedResult))
    }
}


// ex1
func combineAsyncResults(completion: @escaping (Result<Int, Error>) -> Void) {
    DispatchQueue.global().async {
        let result1 = Result { try fetchData1() }
        let result2 = Result { try fetchData2() }
        
        switch (result1, result2) {
        case (.success(let data1), .success(let data2)):
            let combinedResult = data1 + data2
            completion(.success(combinedResult))
        case (.failure(let error), _), (_, .failure(let error)):
            completion(.failure(error))
        }
    }
}

func fetchData1() throws -> Int {
    // Simulate fetching data asynchronously
    return 42
}

func fetchData2() throws -> Int {
    // Simulate fetching data asynchronously
    return 58
}

/* ex2
 @resultBuilder
 enum Builder<T> {
   static func buildBlock(_ component: T) -> T { component }
   static func buildEither(first component: T) -> T { component }
   static func buildEither(second component: T) -> T { component }
 }

 func builder<T>(@Builder<T> _ closure: () -> T) -> T { closure() }
 func builder<T>(_ type: T.Type, @Builder<T> _ closure: () -> T) -> T { closure() }
 */
