/**
 * Created by User on 7/25/2022.
 */
@IsTest
public with sharing class ExchangeRateControllerTest {

//    @TestSetup
//    public static void methodName() {
//        Log__c testLog = new Log__c(Name = 'a015i00000OLRe8', Response_Body__c = 'test', Status_Code__c = 'Not Found');
//        insert testLog;
//    }

    @IsTest
    public static void testCalloutByLatest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map<String, Decimal> result = ExchangeRateController.doGetByLatest();
        Decimal expectedResult = 1.547225;
        System.debug(result);
        System.assertEquals(result.get('CAD'), expectedResult);
    }

    @IsTest
    public static void testCalloutByBaseCurrency() {
        String base = 'CAD';
        Map<String, Decimal> rates = new Map<String, Decimal>();
        rates.put('CAD', 1.559339);
        rates.put('EUR', 1.190965);
        rates.put('GBP', 1);
        rates.put('NZD', 1.939254);
        rates.put('USD', 1.214772);
        Map<String, Decimal> result = ExchangeRateController.getRatesByNewBase(base, rates);
        Decimal expectedResult = 0.7638;
        System.assertEquals(result.get('EUR'), expectedResult);
    }


    @IsTest
    public static void testCalloutByHistoricalRate() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String base = 'GBP';
        Date d = Date.newInstance(2022, 7, 26);
        Map<String, Decimal> result = ExchangeRateController.doGetByHistoricalRate(d, base);
        Decimal expectedResult = 1.178429;
        System.debug(result);
        System.assertEquals(result.get('EUR'), expectedResult);
    }

    @IsTest
    public static void testCalloutByPeriod() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponsePeriod());
        String base = 'GBP';
        Date startDate = Date.newInstance(2022, 7, 11);
        Date endDate = Date.newInstance(2022, 7, 13);
        List <Exchange_Rate__c> result = ExchangeRateController.doGetByPeriod(base, startDate, endDate);
        System.debug(result[0].Date__c);
        System.assertEquals(startDate, result[0].Date__c);
    }

    @IsTest
    public static void testCalloutNotFound() {
//        Log__c testLog = new Log__c(Name = 'a015i00000OLRe8', Response_Body__c = 'test', Status_Code__c = 'Not Found');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseNotFound());
//        insert testLog;
        Test.startTest();
        ExchangeRateController.insertExchangeRate();
        Test.stopTest();
        System.debug([SELECT Name, Status_Code__c FROM Log__c]);
    }


    @IsTest
    public static void testCallout() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        ExchangeRateController.insertExchangeRate();
        Test.stopTest();
    }
}