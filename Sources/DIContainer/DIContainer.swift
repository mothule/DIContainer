public class DIContainer {
    static var shared: DIContainer = .init()
    
    typealias Factory = (DIContainer) -> Any
    
    private var instances: [String: Factory] = [:]
    
    @discardableResult
    func register<T>(_ type: T.Type, factory: @escaping Factory) -> Self {
        let key = String(describing: type)
        instances[key] = factory
        return self
    }
    
    func resolve<T>() -> T {
        let key = String(describing: T.self)
        
        guard let factory = instances[key] else {
            fatalError()
        }
        
        guard let result = factory(self) as? T else {
            fatalError()
        }
        return result
    }
}

