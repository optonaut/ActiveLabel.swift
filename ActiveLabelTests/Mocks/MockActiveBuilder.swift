@testable import ActiveLabel

final class MockActiveBuilder: ActiveBuilderInterface {
    
    private let activeBuilder: ActiveBuilderInterface
    
    init(activeBuilder: ActiveBuilderInterface = ActiveBuilder(regexParser: RegexParser())) {
        self.activeBuilder = activeBuilder
    }
    
    var createElementsCallCount = 0
    func createElements(type: ActiveType, from text: String, range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        createElementsCallCount += 1
        // TODO: add mock method handler
        return activeBuilder.createElements(type: type, from: text, range: range, filterPredicate: filterPredicate)
    }
    
    var createURLElementsCallCount = 0
    func createURLElements(from text: String, range: NSRange, maximumLength: Int?) -> ([ElementTuple], String) {
        createURLElementsCallCount += 1
        // TODO: add mock method handler
        return activeBuilder.createURLElements(from: text, range: range, maximumLength: maximumLength)
    }
    
    
}
