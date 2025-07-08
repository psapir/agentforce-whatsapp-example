@isTest
private class WhatsAppSFMCEServiceTest {

    @isTest
    static void testSendMessage() {
        // Mock response for authentication
        HttpResponse authResponse = new HttpResponse();
        authResponse.setHeader('Content-Type', 'application/json');
        authResponse.setBody('{"access_token":"dummy_token","token_type":"Bearer","expires_in":"3600","scope":"","soap_instance_url":"","rest_instance_url":""}');
        authResponse.setStatusCode(200);

        // Mock response for message send
        HttpResponse msgResponse = new HttpResponse();
        msgResponse.setHeader('Content-Type', 'application/json');
        msgResponse.setBody('{"message":"Message accepted"}');
        msgResponse.setStatusCode(202);

        // Register the multi-callout mock
        Test.setMock(HttpCalloutMock.class, new MultiCalloutMock(authResponse, msgResponse));

        // Create test message request
        WhatsAppSFMCEService.MessageRequest req = new WhatsAppSFMCEService.MessageRequest();
        req.message = 'Test Message';
        req.mobileNumber = '+1234567890';

        List<WhatsAppSFMCEService.MessageRequest> requests = new List<WhatsAppSFMCEService.MessageRequest>{ req };

        // Execute
        Test.startTest();
        WhatsAppSFMCEService.sendMessage(requests);
        Test.stopTest();
    }

    // Multi-callout mock for both auth and message API
    class MultiCalloutMock implements HttpCalloutMock {
        HttpResponse authResp;
        HttpResponse msgResp;
        Integer count = 0;

        MultiCalloutMock(HttpResponse authResp, HttpResponse msgResp) {
            this.authResp = authResp;
            this.msgResp = msgResp;
        }

        public HTTPResponse respond(HTTPRequest req) {
            count++;
            if (count == 1) {
                return authResp;
            } else {
                return msgResp;
            }
        }
    }
}