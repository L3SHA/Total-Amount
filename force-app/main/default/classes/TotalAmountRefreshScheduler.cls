global class TotalAmountRefreshScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        TotalAmountBatchRefresh totalAmountRefresh = new TotalAmountBatchRefresh();
        Id batchId = Database.executeBatch(totalAmountRefresh, 200);
    }
}
