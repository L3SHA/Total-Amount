@isTest
private class TotalAmountBatchTest {

    private static final Integer HIERARCHY_DEPTH = 6;
    private static final Integer IN_ONE_LEVEL_COUNT = 2;
    private static final Integer OPPORTUNITIES_AMOUNT = 10;
    private static final Integer ONE_DEAL_AMOUNT = 100;
    private static final Integer EXPECTED_TOTAL_AMOUNT = 11000;

    @testSetup 
    static void setup() {
        List<Account> accounts = TestDataFactory.getAccHierarchy(HIERARCHY_DEPTH, IN_ONE_LEVEL_COUNT);
        List<Opportunity> opps = TestDataFactory.getOpportunitiesForAccs(accounts, OPPORTUNITIES_AMOUNT, ONE_DEAL_AMOUNT);
        insert opps;
    }

    @isTest
    static void positiveTotalAmountTest(){

        Test.startTest();
        Database.executeBatch(new TotalAmountBatchRefresh());
        Test.stopTest();

        List<AggregateResult> aggResults = [SELECT MAX(Total_Amount__c)total FROM Account WHERE ParentId = null];
        System.assertEquals(EXPECTED_TOTAL_AMOUNT, aggResults[0].get('total'));
        
    }

    @isTest
    static void positiveOppSumTest(){
        Test.startTest();
        Database.executeBatch(new TotalAmountBatchRefresh());
        Test.stopTest();

        List<AggregateResult> aggResults = [SELECT MIN(Total_Amount__c)total FROM Account WHERE ParentId = null];
        System.assertEquals(ONE_DEAL_AMOUNT * OPPORTUNITIES_AMOUNT, aggResults[0].get('total'));
    }

    @isTest
    static void negativeOppSumTest(){
        Test.startTest();
        Database.executeBatch(new TotalAmountBatchRefresh());
        Test.stopTest();

        List<AggregateResult> aggResults = [SELECT MIN(Total_Amount__c)total FROM Account];
        System.assertNotEquals(0, aggResults[0].get('total'));
    }
}
