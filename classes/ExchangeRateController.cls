
public with sharing class ExchangeRateController {

    public static void insertExchangeRate() {
        String defaultBaseCurrency = getDefaultBaseCurrency();
        String formatSymbols = getFormatFields(defaultBaseCurrency);
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.exchangerate.host/latest/?base=' + defaultBaseCurrency + '&symbols=' + formatSymbols);
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);
        String responseBody = response.getBody();
        Id logId = insertLog(response.getStatus(), responseBody);
        if (response.getStatusCode() == 200) {
            Wrapper wrapper = (Wrapper) JSON.deserialize(responseBody, Wrapper.class);
            Exchange_Rate__c exchangeRate = new Exchange_Rate__c(Date__c = Date.today(), Log__c = logId);
            List<String> fields = getCurrencyFields();
            for (String field : fields) {
                String f = field + '__c';
                exchangeRate.put(f, wrapper.rates.get(field));
            }
            checkNotFoundLog();
            insert exchangeRate;
        }

    }

    public static void checkNotFoundLog() {
        String defaultBaseCurrency = getDefaultBaseCurrency();
        String formatSymbols = getFormatFields(defaultBaseCurrency);
        List<Log__c> logs = [SELECT Status_Code__c, Response_Body__c, CreatedDate FROM Log__c WHERE Status_Code__c = 'Not Found'];
        System.debug('ddfgdhxf');
        System.debug(logs);
        if (logs.size() > 0) {
            for (Log__c log : logs) {
                Datetime d = log.CreatedDate;
                HttpRequest request = new HttpRequest();
                request.setEndpoint('https://api.exchangerate.host/' + Date.newInstance(d.year(), d.month(), d.day()) + '?base=' + defaultBaseCurrency + '&symbols=' + formatSymbols);
                request.setMethod('GET');
                Http http = new Http();
                HttpResponse response = http.send(request);
                String responseBody = response.getBody();
                Id logId = insertLog(response.getStatus(), responseBody);
                Wrapper wrapper = (Wrapper) JSON.deserialize(responseBody, Wrapper.class);
//                Id newLogId = insertLog(response.getStatus(), responseBody);
                Exchange_Rate__c exchangeRate = new Exchange_Rate__c(Date__c = d.date(), Log__c = logId);
                List<String> fields = getCurrencyFields();
                for (String field : fields) {
                    String formatField = field + '__c';
                    exchangeRate.put(formatField, wrapper.rates.get(field));
                }
                insert exchangeRate;
            }
        }
        update logs;
    }

    @AuraEnabled
    public static Map<String, Decimal> doGetByLatest() {
        String defaultBaseCurrency = getDefaultBaseCurrency();
        String formatSymbols = getFormatFields(defaultBaseCurrency);
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.exchangerate.host/latest/?base=' + defaultBaseCurrency + '&symbols=' + formatSymbols);
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);
        String responseBody = response.getBody();
        insertLog(response.getStatus(), responseBody);
        Map<String, Decimal> rates;
        if (response.getStatusCode() == 200) {
            rates = getExchangeRate(responseBody);
        }
        System.debug(rates);
        return rates;
    }

    @AuraEnabled
    public static Map<String, Decimal> getRatesByNewBase(String newBase, Map<String, Decimal> rates) {
        String defaultBase = getDefaultBaseCurrency();
        rates.put(defaultBase, 1);
        System.debug(newBase);
        System.debug(rates);
        Decimal previousRate = rates.get(newBase);
        System.debug(previousRate);
        Map<String, Decimal> newRates = new Map<String, Decimal>();
        for (String field : getCurrencyFields()) {
            if (field != newBase) {
                Decimal convertedValue = rates.get(field).divide(previousRate, 4);
                System.debug(field + '---' + convertedValue);
                newRates.put(field, convertedValue);
            }
        }
        System.debug(newRates);
        return newRates;
    }

    @AuraEnabled
    public static Map<String, Decimal> doGetByHistoricalRate(Date historicalDate, String baseCurrency) {
        HttpRequest request = new HttpRequest();
        String formatSymbols = getFormatFields(baseCurrency);
        request.setEndpoint('https://api.exchangerate.host/' + historicalDate + '?base=' + baseCurrency + '&symbols=' + formatSymbols);
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);
        String responseBody = response.getBody();
        insertLog(response.getStatus(), responseBody);
        Wrapper wrapper;
        if (response.getStatusCode() == 200) {
            wrapper = (Wrapper) JSON.deserialize(responseBody, Wrapper.class);
            Exchange_Rate__c exchangeRate = new Exchange_Rate__c(Date__c = historicalDate);
            List<String> fields = getCurrencyFields();
            for (String field : fields) {
                String formatField = field + '__c';
                exchangeRate.put(formatField, wrapper.rates.get(field));
            }
        }
        return wrapper.rates;
    }

    @AuraEnabled
    public static List <Exchange_Rate__c> doGetByPeriod(String base, Date startDate, Date endDate) {
//        System.debug(base);
//        System.debug(startDate);
//        System.debug(endDate);
//        Date s = Date.newInstance(2022, 07, 17);
//        Date e = Date.newInstance(2022, 07, 19);
        List<Date> dates = new List<Date>();
        Date counter = startDate;
        while (counter <= endDate) {
            dates.add(counter);
            counter = counter.addDays(1);
        }
        List<Exchange_Rate__c> existExchangeRates = Database.query('SELECT Base_Currency__c, Date__c,' +
                String.join(getFormatFieldsByQuery(), ',') +
                ' FROM Exchange_Rate__c ' +
                'WHERE Base_Currency__c =: base AND Date__c IN :dates ORDER BY Date__c');
        System.debug('exist' + existExchangeRates);
        if (dates.size() == existExchangeRates.size()) {
            for (Exchange_Rate__c rate : existExchangeRates) {
                rate.Base_Currency__c = null;
            }
            return existExchangeRates;
        } else {

            System.debug('new');
            HttpRequest request = new HttpRequest();
            String formatSymbols = getFormatFields(base);
            request.setEndpoint('https://api.exchangerate.host/timeseries?start_date=' + startDate + '&end_date=' + endDate + '&base=' + base + '&symbols=' + formatSymbols);
            request.setMethod('GET');
            Http http = new Http();
            HttpResponse response = http.send(request);
            String responseBody = response.getBody();
            Id logId = insertLog(response.getStatus(), responseBody);
            List <Exchange_Rate__c> exchangeRates = new List<Exchange_Rate__c>();
            if (response.getStatusCode() == 200) {
                WrapperByPeriod wrapper = (WrapperByPeriod) JSON.deserialize(responseBody, WrapperByPeriod.class);
                Map<Date, Map<String, Decimal>> rates = wrapper.rates;
                List<String> fields = getCurrencyFields();
                for (Date d : rates.keySet()) {
                    Map<String, Decimal> mapRates;
                    Exchange_Rate__c exchangeRate = new Exchange_Rate__c(Date__c = d, Log__c = logId, Base_Currency__c = base);
                    mapRates = rates.get(d);
                    for (String field : fields) {
                        String formatField = field + '__c';
                        exchangeRate.put(formatField, rates.get(d).get(field));
                    }
                    exchangeRates.add(exchangeRate);
                }
                System.debug(exchangeRates);
                insert exchangeRates;
            }
            for (Exchange_Rate__c exchangeRate : exchangeRates) {
                exchangeRate.Base_Currency__c = null;
                exchangeRate.Log__c = null;
            }
            return exchangeRates;
        }
    }

    @AuraEnabled
    public static Id insertLog(String status, String responseBody) {
        Log__c log = new Log__c(Status_Code__c = status, Response_Body__c = responseBody);
        insert log;
        return log.Id;
    }

    @AuraEnabled
    public static Map<String, Decimal> getExchangeRate (String responseBody) {
        Wrapper wrapper = (Wrapper) JSON.deserialize(responseBody, Wrapper.class);
        Exchange_Rate__c exchangeRate = new Exchange_Rate__c(Date__c = Date.today());
        List<String> fields = getCurrencyFields();
        for (String field : fields) {
            String f = field + '__c';
            exchangeRate.put(f, wrapper.rates.get(field));
        }
        return wrapper.rates;
    }

    @AuraEnabled(Cacheable=false)
    public static List<String> getCurrencyFields() {
        List<String> fields = new List<String>();
        SObjectType objType = Schema.getGlobalDescribe().get('Exchange_Rate__c');
        Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();
        for (Schema.SObjectField fld : fieldsMap.values()) {
            if (fld.getDescribe().getType() == Schema.DisplayType.CURRENCY) {
                fields.add(fld.getDescribe().getName().replace('__c', ''));
            }
        }
        return fields;
    }

    @AuraEnabled
    public static List<String> getFormatFieldsByQuery() {
        List<String> symbols = getCurrencyFields();
        List<String> formatSymbols = new List<String>();
        for (String str : symbols) {
            formatSymbols.add(str + '__c') ;
        }
        formatSymbols.sort();
        return formatSymbols;
    }

    @AuraEnabled
    public static String getFormatFields(String baseString) {
        List<String> symbols = getCurrencyFields();
        String formatSymbols = symbols.toString().replace(' ', '').replace('(', '').replace(')', '').replace(baseString, '').replace(',,', ',');
        return formatSymbols;
    }

    @AuraEnabled
    public static String getDefaultBaseCurrency() {
        String defaultVal;
        Schema.DescribeFieldResult field = Exchange_Rate__c.Base_Currency__c.getDescribe();
        List <Schema.PicklistEntry> pickValues = field.getPicklistValues();
        for (Schema.PicklistEntry pv : pickValues) {
            if (pv.isDefaultValue()) {
                defaultVal = pv.getValue();
            }
        }
        return defaultVal;
    }

    public class Wrapper {
        public Map<String, Decimal> rates { get; set; }
    }

    public class WrapperByPeriod {
        public Map<Date, Map<String, Decimal>> rates { get; set; }
    }
}


