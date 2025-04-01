<script runat="server" language="JavaScript">
  Platform.Load("core", "1");
  try{
    HTTPHeader.SetValue('Access-Control-Allow-Methods','POST');
    HTTPHeader.SetValue('Access-Control-Allow-Origin','*');
    var jsonpost = Platform.Request.GetPostData(0);
    var json = Platform.Function.ParseJSON(jsonpost);
    var message = "ENS_Whatsapp_event";
    var insertResponse = Platform.Function.InsertData("ENS_Whatsapp",["message","jsonpost"],[message,jsonpost]);
    var messageKey = json[0].eventCategoryType;
    if (messageKey == "EngagementEvents.OttMobileOriginated") {
      var mobileNumber = json[0].mobileNumber;
      var contactId = json[0].contactId;
      var body = json[0].messageBody.text.body;
      var timestampUTC = json[0].timestampUTC;
      timestampUTC = new Date(timestampUTC);
      
      Variable.SetValue("@contactId",contactId);
      Variable.SetValue("@mobileNumber",mobileNumber);
      Variable.SetValue("@body",body);
             
    }
  }
  catch (e) {
    Write("<br>" + Stringify(e))}
</script>
%%[
set @subscriberRows = LookupRows("WhatsAppLog","MobileNumber",@mobileNumber)
if RowCount(@subscriberRows) == 0 then
  insertData("WhatsAppLog","MobileNumber", @mobileNumber)
  set @createSFMO = CreateSalesforceObject("WhatsAppConversation__c", 3,"Name", concat("MO from ",@contactId),"MobileNumber__c", @mobileNumber,"Body__c", @body)
endif
]%%