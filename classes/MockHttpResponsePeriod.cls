/**
 * Created by User on 7/26/2022.
 */

global class MockHttpResponsePeriod implements HttpCalloutMock {

    global HttpResponse respond(HttpRequest req) {
        System.assertEquals('GET', req.getMethod());
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{\n' +
                '    "motd": {\n' +
                '        "msg": "If you or your company use this project or like what we doing, please consider backing us so we can continue maintaining and evolving this project.",\n' +
                '        "url": "https://exchangerate.host/#/donate"\n' +
                '    },\n' +
                '    "success": true,\n' +
                '    "timeseries": true,\n' +
                '    "base": "GBP",\n' +
                '    "start_date": "2022-07-11",\n' +
                '    "end_date": "2022-07-13",\n' +
                '    "rates": {\n' +
                '        "2022-07-11": {\n' +
                '            "CAD": 1.546569,\n' +
                '            "EUR": 1.184548,\n' +
                '            "USD": 1.188308\n' +
                '        },\n' +
                '        "2022-07-12": {\n' +
                '            "CAD": 1.547747,\n' +
                '            "EUR": 1.183695,\n' +
                '            "USD": 1.188029\n' +
                '        },\n' +
                '        "2022-07-13": {\n' +
                '            "CAD": 1.542129,\n' +
                '            "EUR": 1.181477,\n' +
                '            "USD": 1.186954\n' +
                '        }\n' +
                '    }\n' +
                '}');
        res.setStatusCode(200);
        return res;
    }
}