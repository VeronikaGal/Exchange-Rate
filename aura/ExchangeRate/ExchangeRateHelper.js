/**
 * Created by User on 7/18/2022.
 */

({
    getFields: function (component, event) {
        var action = component.get("c.getCurrencyFields");
        action.setCallback(this, function (result) {
            var currencies = result.getReturnValue();
            console.log(currencies);
            component.set("v.currencies", currencies);
            window.setTimeout(
                $A.getCallback(function () {
                    component.find("a_opt").set("v.value", currencies[3]);
                }));
        });
        $A.enqueueAction(action);
    },

    getRatesByLatest: function (component, event) {
        var action = component.get("c.doGetByLatest");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result)
                var fieldMap = [];
                for (var key in result) {
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.rates", fieldMap);

            }
        });
        $A.enqueueAction(action);
    },

    getRatesByBaseCurrency: function (component, event) {
        var base = component.get("v.selectBase");
        var action = component.get("c.getRatesByNewBase");
        var theMap = component.get("v.rates");
        var mapToSend = theMap.reduce(function (map, obj) {
            map[obj.key] = obj.value;
            return map;
        }, {});
        console.log(mapToSend);
        action.setParams({newBase: base, rates: mapToSend});
        console.log(base);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for (var key in result) {
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.another", fieldMap);
            } else if (state === "ERROR") {
                console.log('Problem, response state: ' + state);
            } else {
                console.log('Unknown problem, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },

    getByHistoricalRate: function (component, event) {
        var startDate = component.get("v.historicalDate");
        var baseCurrency = component.get("v.selectBase");
        var action = component.get("c.doGetByHistoricalRate");
        action.setParams({historicalDate: startDate, baseCurrency: baseCurrency});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for (var key in result) {
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.another", fieldMap);
            } else if (state === "ERROR") {
                console.log('Problem, response state: ' + state);
            } else {
                console.log('Unknown problem, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },

    getByPeriod: function (component, event) {
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        var baseCurrency = component.get("v.selectBase");
        var action = component.get("c.doGetByPeriod");
        action.setParams({base: baseCurrency, startDate: startDate, endDate: endDate});
        action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    let result = response.getReturnValue();
                    let column = result.map(x => Object.keys(x));
                    console.log(column)
                    let str = column[0].map(item => item.replace('__c', ''));
                    console.log(str)
                    // str.shift()
                    str.pop()
                    // str.splice(1, 1)
                    // str.remove('Base_Currency');
                    // str.filter(function(e) { return e !== '"Base_Currency"' })
                    console.log(str)
                    component.set("v.columns", str);
                    let m = result.map(x => Object.values(x));
                    for (let mElement of m) {
                        // mElement.shift()
                        mElement.pop()
                        // mElement.splice(1, 1)
                    }
                    console.log(m)
                    component.set("v.data", m);
                } else if (state === "ERROR") {
                    console.log('Problem, response state: ' + state);
                } else {
                    console.log('Unknown problem, response state: ' + state);
                }
            }
        );
        $A.enqueueAction(action);
    }
})
