// This is a generated Motoko binding.
// Please use `import service "ic:canister_id"` instead to call canisters on the IC if possible.

module {
  public type HeaderField = (Text, Text);
  public type Request = {
    url : Text;
    method : Text;
    body : [Nat8];
    headers : [HeaderField];
  };
  public type Response = {
    body : [Nat8];
    headers : [HeaderField];
    upgrade : ?Bool;
    streaming_strategy : ?StreamingStrategy;
    status_code : Nat16;
  };
  public type StreamingCallback = shared query StreamingCallbackToken -> async StreamingCallbackResponse;
  public type StreamingCallbackResponse = {
    token : ?StreamingCallbackToken;
    body : [Nat8];
  };
  public type StreamingCallbackToken = {
    key : Text;
    index : Nat;
    content_encoding : Text;
  };
  public type StreamingStrategy = {
    #Callback : {
      token : StreamingCallbackToken;
      callback : StreamingCallback;
    };
  };
  public type Self = actor {
    change_dao_text : shared Text -> async Text;
    get_dao_text : shared query () -> async Text;
    http_request : shared query Request -> async Response;
    http_request_update : shared Request -> async Response;
    whoami : shared query () -> async Principal;
  }
}