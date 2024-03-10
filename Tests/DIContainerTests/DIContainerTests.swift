import XCTest
@testable import DIContainer

// XCTest Documentation
// https://developer.apple.com/documentation/xctest
// Defining Test Cases and Test Methods
// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
final class DIContainerTests: XCTestCase {
    func test_usecase_using_shared() throws {
        DIContainer.shared.register(APIService.self) { _ in
            APIServiceImpl.shared
        }
        .register(DatabaseService.self) { container in
            DatabaseServiceImpl()
        }
        .register(ClassService.self) { container in
            ClassServiceImpl(
                api: container.resolve(APIService.self), 
                database: container.resolve(DatabaseService.self)
            )
        }
        let instance = DIContainer.shared.resolve(ClassService.self)
        XCTAssertIdentical(APIServiceImpl.shared as AnyObject, instance.api as AnyObject)
    }
    
    func test_usecase_not_using_shared() throws {
        let vc = AnyViewController.diContainer()
            .register(DatabaseService.self) { _ in DatabaseServiceFake() }
            .resolve(AnyViewController.self)
        _ = try XCTUnwrap(vc.viewModel.classService.database as? DatabaseServiceFake)
    }
    
    func test_merging() {
        let c = DIContainer().register(String.self, factory: { _ in "good" })
            .merging(.init().register(String.self, factory: { _ in "bad" }))
        XCTAssertEqual(c.resolve(String.self), "bad")
    }
}

private protocol ClassService {
    var api: APIService { get }
    var database: DatabaseService { get }
}

private class ClassServiceImpl: ClassService {
    let api: APIService
    var database: DatabaseService
    
    init(api: APIService, database: DatabaseService) {
        self.api = api
        self.database = database
    }
}

private protocol APIService {}
private class APIServiceImpl: APIService {
    static var shared: APIService = APIServiceImpl()
}

protocol DatabaseService {}
class DatabaseServiceImpl: DatabaseService {}
class DatabaseServiceFake: DatabaseService {}

private class AnyViewController: NSObject {
    var viewModel: AnyViewModel!
}

extension AnyViewController: DIContainerInjectable {
    static func diContainer() -> DIContainer {
        let container: DIContainer = {
            DIContainer()
                .register(APIService.self) { _ in
                    APIServiceImpl.shared
                }
                .register(DatabaseService.self) { _ in
                    DatabaseServiceImpl()
                }
                .register(ClassService.self) { c in
                    ClassServiceImpl(
                        api: c.resolve(APIService.self),
                        database: c.resolve(DatabaseService.self)
                    )
                }
                .register(AnyViewModel.self) { c in
                    AnyViewModel(classService: c.resolve())
                }
                .register(AnyViewController.self) { c in
                    let vc = AnyViewController()
                    vc.viewModel = c.resolve(AnyViewModel.self)
                    return vc
                }
        }()
        return container
    }
}


private class AnyViewModel {
    var classService: ClassService
    
    init(classService: ClassService) {
        self.classService = classService
    }
}
