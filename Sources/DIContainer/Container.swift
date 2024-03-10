public class Container {
    public typealias Factory = (Container) -> Any
    
    public static var shared: Container = .init()
    
    private var instances: [String: Factory] = [:]
    
    public init() {
    }
    
    public init(instances: [String : Factory]) {
        self.instances = instances
    }
    
    @discardableResult
    public func register<T>(_ type: T.Type, factory: @escaping Factory) -> Self {
        let key = String(describing: type)
        instances[key] = factory
        return self
    }
    
    public func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        
        guard let factory = instances[key] else {
            fatalError()
        }
        
        guard let result = factory(self) as? T else {
            fatalError()
        }
        return result
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
    
    public func merging(_ other: Container) -> Container {
        Container(instances: instances.merging(other.instances) { _, rhs in rhs })
    }
}

public protocol DIContainerInjectable {
    static func diContainer() -> Container
}
