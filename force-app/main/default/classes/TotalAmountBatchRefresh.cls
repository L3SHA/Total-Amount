global class TotalAmountBatchRefresh implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext batchableContext){

        return Database.getQueryLocator([SELECT Opportunities_Sum__c FROM Account]);

    }

    public void execute(Database.BatchableContext context, List<Account> accounts){
       for(Account account : accounts) {
           account.Total_Amount__c = account.Opportunities_Sum__c;
       }

       update accounts;

    }

    public void finish(Database.BatchableContext context){
        Database.executeBatch(new TotalAmountFieldRefresh());
    }
}
