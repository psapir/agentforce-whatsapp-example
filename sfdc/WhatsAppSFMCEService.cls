public with sharing class WhatsAppSFMCEService {
  
	@InvocableMethod(label='Send WhatsApp Message' description='Sends a WhatsApp Message utilizing Marketing Cloud Engagement')
	public static void sendMessage(List<MessageRequest> requests)
	{
		for (MessageRequest req : requests) {
            sendWhatsAppFuture(req.message, req.mobileNumber);
        }
	}

	private static void sendMessage(String message, String mobileNumber) {
		String authToken = authenticate();
        String sfmceDomain = "YOUR_SFMCE_REST_DOMANI_HERE";
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        
        MessageSendRequest messageRequest = new MessageSendRequest('Test_sesion_bot');
                
        MessageRecipient r = new MessageRecipient();
        r.contactKey = mobileNumber;
        r.to = mobileNumber;
        r.attributes = new Attributes();
        r.attributes.body = message;
        
        messageRequest.recipients = new List<MessageRecipient> {r};
       
        Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint('https://'+sfmceDomain+'.rest.marketingcloudapis.com/messaging/v1/ott/messages');
		request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Authorization', 'Bearer ' + authToken);
		request.setBody(JSON.serialize(messageRequest));
		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 202) {
			System.debug('#### WhatsApp API response: '+response.getBody());
		} else {
			System.debug('WhatsApp SFMCE API Error: ' + response.getStatusCode() + ' ' + response.getStatus());
		}
	}
  
    public static String authenticate() {
		// You can also retrieve this information from Custom Metadata Objects (recommended)
		String sfmceDomain = "YOUR_SFMCE_REST_DOMANI_HERE";
		String clientID = "YOUR_SFMCE_CLIENT_ID";
		String clientSecret = "YOUR_SFMCE_CLIENT_ID";
		String mid = "YOUR_SFMCE_ACCOUNT_ID";

		MarketingCloudAuthRequest authRequest = new MarketingCloudAuthRequest(clientID,clientSecret,mid);
		

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint('https://'+sfmceDomain+'.auth.marketingcloudapis.com/v2/token');
		request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json');
		request.setBody(JSON.serialize(authRequest));
		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 200) {
            MarketingCloudAuthResponse resp = (MarketingCloudAuthResponse) JSON.deserialize(response.getBody(), MarketingCloudAuthResponse.class);
            System.debug('#### MKT AUTH RESPONSE: '+resp);
            return resp.access_token;
		} else {
			System.debug('The status code returned by the Marketing Cloud auth API was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
			return null;
		}

	}

	@future(callout=true)
	public static void sendWhatsAppFuture(String message, String mobileNumber) {
    	sendMessage(message, mobileNumber);
	}
	
    public class MarketingCloudAuthRequest {
		String client_id;
		String client_secret;
		String grant_type;
        String account_id;

		public MarketingCloudAuthRequest(String clientId, String clientSecret, String accountId) {
			this.client_id = clientId;
			this.client_secret = clientSecret;
			this.grant_type = 'client_credentials';
            this.account_id = accountId;
		}
	}

	public class MarketingCloudAuthResponse {
		String access_token;
		String token_type;
		String expires_in;
		String scope;
		String soap_instance_url;
		String rest_instance_url;
	}
    
    public  class MessageSendRequest {
		public String definitionKey;
		List<MessageRecipient> recipients;
        
        public MessageSendRequest(String definitionKey){
            this.definitionKey = definitionKey;
        }
	}

    public  class MessageRecipient {
		public String contactKey;
        public String to;
        public String messageKey;
		public Attributes attributes;
	}
    
    public class Attributes {
        public String body;
    }
    
    public class MessageRequest {
    @InvocableVariable(label='Message' required=true)
    public String message;

    @InvocableVariable(label='Mobile Number' required=true)
    public String mobileNumber;
	}
}