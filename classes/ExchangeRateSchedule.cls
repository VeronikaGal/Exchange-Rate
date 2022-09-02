
global class ExchangeRateSchedule implements Schedulable{

    global void execute(SchedulableContext sc) {
        ExchangeRateController.insertExchangeRate();
    }
}

