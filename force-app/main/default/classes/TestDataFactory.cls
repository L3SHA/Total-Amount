public class TestDataFactory {

    private static final String ACCOUNT_BASE_NAME = 'Account Test';
    private static final String OPPORTUNITY_BASE_NAME = 'Opportunity Test';
    private static final String OPPORTUNITY_STATUS = 'Closed Won';

    public static List<Account> getAccHierarchy(Integer depth, Integer inOneLevelCount) {
    
        List<Account> accounts = new List<Account>();

        Account parentAcc = null;

        for(Integer i = 0; i < depth; i++){
            for(Integer j = 0; j < inOneLevelCount; j++){

                Account newAcc = new Account(Name = ACCOUNT_BASE_NAME + i + j, ParentId = parentAcc != null ? parentAcc.Id : null);

                insert newAcc;

                accounts.Add(newAcc);
            }
            parentAcc = accounts.get((i + 1) * inOneLevelCount - 1);
            //System.debug(parentId);
        }

        return accounts;
    }

    public static List<Opportunity> getOpportunitiesForAccs(List<Account> accounts, Integer oppsAmount, Integer dealAmount) {

        List<Opportunity> opps = new List<Opportunity>();

        for(Account account : accounts){
            for(Integer i = 0; i < oppsAmount; i++){
                opps.add(new Opportunity(Name = OPPORTUNITY_BASE_NAME, StageName = OPPORTUNITY_STATUS, CloseDate = Date.newInstance(2020, 12, 1), Amount = dealAmount, AccountId = account.Id));
            }
        }

        return opps;
    }
}
