public class TotalAmountFieldRefresh implements Database.Batchable<sObject> {
   
    public Database.QueryLocator start(Database.BatchableContext batchableContext){

        return Database.getQueryLocator([SELECT Opportunities_Sum__c, ParentId FROM Account]);

    }

    public void execute(Database.BatchableContext context, List<Account> accounts){
        Map<Id, Decimal> parentUpdates = new Map<Id,Decimal>();

        for(Account account: accounts) {
            if(account.ParentId != null) {
                Decimal value = getNewUpdateValue(parentUpdates, account, account.Opportunities_Sum__c); 
                
                parentUpdates.put(account.parentId, value);
            }
        } 

        Map<Id, Account> accsToUpdate = new Map<Id, Account>();

        updateParentsTotal(accsToUpdate, parentUpdates);

        update accsToUpdate.values();
    }

    public void finish(Database.BatchableContext context){
    }

    private void updateParentsTotal(Map<Id, Account> accsToUpdate, Map<Id, Decimal> parentUpdates) {
        Map<Id, Decimal> grandParentUpdates = new Map<Id, Decimal>();

        for(Id parentId: parentUpdates.keySet()) { 
            if(accsToUpdate.containsKey(parentId)) {
                Account parent = accsToUpdate.get(parentId);
                parent.Total_Amount__c += parentUpdates.get(parentId);

                if(parent.ParentId != null) {
                    Decimal value = getNewUpdateValue(grandParentUpdates, parent, parentUpdates.get(parent.Id));
                    grandParentUpdates.put(parent.ParentId, value);
                }

                parentUpdates.remove(parentId);
            }
        }

        for(Account a: [SELECT Total_Amount__c, ParentId FROM Account WHERE ID IN :parentUpdates.keySet()]) {
            a.Total_Amount__c += parentUpdates.get(a.Id);

            accsToUpdate.put(a.Id, a);

            if(a.ParentId != null) {
                Decimal value = getNewUpdateValue(grandParentUpdates, a, parentUpdates.get(a.Id));
                grandParentUpdates.put(a.ParentId, value);
            }
        }

        if(!grandParentUpdates.isEmpty()) {
            updateParentsTotal(accsToUpdate, grandParentUpdates);
        }

    }

    private Decimal getNewUpdateValue(Map<Id, Decimal> parentUpdates, Account child, Decimal prefUpdate) {
        Decimal newUpdate = prefUpdate;

        if(parentUpdates.containsKey(child.ParentId)) {
            newUpdate += parentUpdates.get(child.ParentId);
        }

        return newUpdate;
    }

}
