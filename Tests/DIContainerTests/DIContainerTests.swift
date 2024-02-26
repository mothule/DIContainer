import XCTest
@testable import DIContainer

// XCTest Documentation
// https://developer.apple.com/documentation/xctest
// Defining Test Cases and Test Methods
// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
final class DIContainerTests: XCTestCase {
    func test_ユースケース() throws {
        
        let apiService = APIServiceImpl()
        DIContainer.shared.register(APIService.self) { _ in
            return apiService
        }
        .register(ClassService.self) { container in
            return ClassServiceImpl(api: container.resolve())
        }
        
        let instance: ClassService = DIContainer.shared.resolve()
        
        XCTAssertIdentical(apiService, instance.api as AnyObject)
    }
}

protocol ClassService {
    var api: APIService { get }
}

class ClassServiceImpl: ClassService {
    let api: APIService
    
    init(api: APIService) {
        self.api = api
    }
}

protocol APIService {}
class APIServiceImpl: APIService {
    
}
