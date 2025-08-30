-- scripts/bank.lua

ResourceDebt = {}

function ProcessDebtPayment(teamId)
    if not ResourceDebt[teamId] then return end

    local debt = ResourceDebt[teamId]
    local currentRes = GetTeamResources(teamId)

    local metalToPay = math.min(currentRes.metal, debt.Metal)
    local energyToPay = math.min(currentRes.energy, debt.Energy)

    if metalToPay > 0 or energyToPay > 0 then
        AddResources(teamId, Value(-metalToPay, -energyToPay), false, Vec3())
        Log(string.format("  - Debt Payment (Team %d): Paid M=%.2f, E=%.2f", teamId, metalToPay, energyToPay))
    end

    debt.Metal = debt.Metal - metalToPay
    debt.Energy = debt.Energy - energyToPay

    if debt.Metal < 0.01 and debt.Energy < 0.01 then
        Log("  - Debt fully paid for Team " .. teamId)
        ResourceDebt[teamId] = nil
    else
        Log(string.format("  - Remaining debt for Team %d: M=%.2f, E=%.2f. Scheduling next payment.", teamId, debt.Metal, debt.Energy))
        ScheduleCall(0.1, ProcessDebtPayment, teamId)
    end
end

function ManageResourceDebt(teamId, metalDebt, energyDebt)
    if metalDebt <= 0 and energyDebt <= 0 then return end

    if ResourceDebt[teamId] then
        ResourceDebt[teamId].Metal = ResourceDebt[teamId].Metal + metalDebt
        ResourceDebt[teamId].Energy = ResourceDebt[teamId].Energy + energyDebt
        Log(string.format("  - Added to existing debt for Team %d: M=%.2f, E=%.2f. Total debt: M=%.2f, E=%.2f",
            teamId, metalDebt, energyDebt, ResourceDebt[teamId].Metal, ResourceDebt[teamId].Energy))
    else
        ResourceDebt[teamId] = { Metal = metalDebt, Energy = energyDebt }
        Log(string.format("  - New debt created for Team %d: M=%.2f, E=%.2f. Starting payment process.", teamId, metalDebt, energyDebt))
        ScheduleCall(0.1, ProcessDebtPayment, teamId)
    end
end