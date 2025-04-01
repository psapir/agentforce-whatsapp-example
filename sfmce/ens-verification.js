<script runat="server" language="JavaScript">
  Platform.Load("Core", "1");
  var jsonpost = Platform.Request.GetPostData();
 
  var json = Platform.Function.ParseJSON(jsonpost);
   
  var rows = Platform.Function.InsertData("TransactionalSendsVerificationKey",["VerificationKey"],[json.verificationKey]);
   
</script>