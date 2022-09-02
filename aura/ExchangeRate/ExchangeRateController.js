/**
 * Created by User on 7/18/2022.
 */

({
    doInit: function (component, event, helper) {
        helper.getFields(component, event);
        helper.getRatesByLatest(component, event);
    },

    changeAction: function (component, event, helper) {
        var selectCurrency = event.getSource().get("v.value");

        component.set("v.selectBase", selectCurrency);
        component.set("v.anotherBaseCurrency", true);

        helper.getRatesByBaseCurrency(component);
        helper.getByPeriod(component, event);
    },
    changeHistoricalDate: function (component, event, helper) {
        var historicalDate = event.getSource().get("v.value");
        var todayDate = component.set('v.todayDate', new Date().toISOString().split('T')[0]);

        component.set("v.historicalDate", historicalDate);

        helper.getByHistoricalRate(component, event);
    },
    changeStartDate: function (component, event, helper) {
        var startDate = event.getSource().get("v.value");
        component.set("v.startDate", startDate);
    },
    changeEndDate: function (component, event, helper) {
        var endDate = event.getSource().get("v.value");
        component.set("v.endDate", endDate);
        helper.getByPeriod(component, event);
    },
    handleSelect: function (component, event) {
        var selectedValue = component.find("radioGrp").get("v.value");
        if (selectedValue === 'option1') {
            component.set("v.radioByDate", selectedValue)
            component.set("v.period", null)
        } else if (selectedValue === 'option2') {
            component.set("v.radioByDate", null)
            component.set("v.period", selectedValue)
        }
    }
});

