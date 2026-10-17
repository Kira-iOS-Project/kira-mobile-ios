import Domain

/** The REN operations' outputs, mapped to values or to the problem they carry. */

extension Operations.GetPlan.Output {
    func plan() throws -> PlanOverview {
        switch self {
        case .ok(let response): return try PlanOverview(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.GetGoal.Output {
    func goal() throws -> GoalDetail {
        switch self {
        case .ok(let response): return try GoalDetail(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.CreateGoal.Output {
    func goal() throws -> GoalDetail {
        switch self {
        case .created(let response): return try GoalDetail(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .conflict(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.AddGoalDeposit.Output {
    func deposit() throws -> GoalDeposit {
        switch self {
        case .created(let response): return try GoalDeposit(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .conflict(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
