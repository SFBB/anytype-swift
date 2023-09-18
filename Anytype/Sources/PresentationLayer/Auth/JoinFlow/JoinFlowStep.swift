enum JoinFlowStep: Int, CaseIterable {
    case creatingSoul
    case soul
    case key
    
    var next: JoinFlowStep? {
        let nextStepNumber = self.rawValue + 1
        guard let nextStep = JoinFlowStep(rawValue: nextStepNumber) else {
            return nil
        }
        return nextStep
    }
    
    var previous: JoinFlowStep? {
        let previousStepNumber = self.rawValue - 1
        guard let previousStep = JoinFlowStep(rawValue: previousStepNumber) else {
            return nil
        }
        return previousStep
    }
    
    static var firstStep: JoinFlowStep {
        JoinFlowStep.allCases.first ?? .creatingSoul
    }
    
    var isFirstCountable: Bool {
        self == JoinFlowStep.allCases.filter { $0.countableStep }.first
    }
    
    var isLast: Bool {
        self == JoinFlowStep.allCases.last
    }
    
    static var totalCount: Int {
        JoinFlowStep.allCases.filter { $0.countableStep }.count
    }
    
    var countableStep: Bool {
        switch self {
        case .creatingSoul:
            return false
        case .key, .soul:
            return true
        }
    }
}
