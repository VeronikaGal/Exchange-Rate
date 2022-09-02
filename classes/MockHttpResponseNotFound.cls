/**
 * Created by User on 7/29/2022.
 */

global class MockHttpResponseNotFound implements HttpCalloutMock {

    global HttpResponse respond(HttpRequest req) {
        System.assertEquals('GET', req.getMethod());
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{\n' +
                '    "motd": {\n' +
                '        "msg": "If you or your company use this project or like what we doing, ' +
                'please consider backing us so we can continue maintaining and evolving this project.",\n' +
                '        "url": "https://exchangerate.host/#/donate"\n' +
                '    },\n' +
                '    "success": false,\n' +
                '    "base": "GBP",\n' +
                '    "date": "2022-07-26",\n' +
                '    "rates": {\n' +
                '        "CAD": 1.547225,\n' +
                '        "EUR": 1.178429,\n' +
                '        "USD": 1.205305\n' +
                '    }\n' +
                '}');
        res.setStatus('Not Found');
        res.setStatusCode(404);
        return res;
    }

}