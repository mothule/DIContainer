public class DIContainer {
    public static var shared: DIContainer = .init()
    
    public typealias Factory = (DIContainer) -> Any
    
    private var instances: [String: Factory] = [:]
    
    @discardableResult
    public func register<T>(_ type: T.Type, factory: @escaping Factory) -> Self {
        let key = String(describing: type)
        instances[key] = factory
        return self
    }
    
    public func resolve<T>() -> T {
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

