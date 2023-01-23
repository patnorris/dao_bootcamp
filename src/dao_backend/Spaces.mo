// This is a generated Motoko binding.
// Please use `import service "ic:canister_id"` instead to call canisters on the IC if possible.

module {
  public type ApiError = {
    #ZeroAddress;
    #InvalidTokenId;
    #Unauthorized;
    #Other;
  };
  public type AssocList = ?((Text, Text), List);
  public type Dip721NonFungibleToken = {
    maxLimit : Nat16;
    logo : LogoResult;
    name : Text;
    symbol : Text;
  };
  public type ExtendedMetadataResult = {
    #Ok : { token_id : TokenId; metadata_desc : MetadataDesc };
    #Err : ApiError;
  };
  public type HeaderField = (Text, Text);
  public type InterfaceId = {
    #Burn;
    #Mint;
    #Approval;
    #TransactionHistory;
    #TransferNotification;
  };
  public type List = ?((Text, Text), List);
  public type LogoResult = { data : Text; logo_type : Text };
  public type MetadataDesc = [MetadataPart];
  public type MetadataKeyVal = { key : Text; val : MetadataVal };
  public type MetadataPart = {
    data : [Nat8];
    key_val_data : [MetadataKeyVal];
    purpose : MetadataPurpose;
  };
  public type MetadataPurpose = { #Preview; #Rendered };
  public type MetadataResult = { #Ok : MetadataDesc; #Err : ApiError };
  public type MetadataVal = {
    #Nat64Content : Nat64;
    #Nat32Content : Nat32;
    #Nat8Content : Nat8;
    #NatContent : Nat;
    #Nat16Content : Nat16;
    #TextArrayContent : [Text];
    #BlobContent : [Nat8];
    #PrincipalContent : Principal;
    #TextToTextAssocListContent : AssocList;
    #TextContent : Text;
  };
  public type MintReceipt = { #Ok : MintReceiptPart; #Err : ApiError };
  public type MintReceiptPart = { id : Nat; token_id : TokenId };
  public type Nft = {
    id : TokenId;
    owner : Principal;
    metadata : MetadataDesc;
  };
  public type NftResult = { #Ok : Nft; #Err : ApiError };
  public type OwnerResult = { #Ok : Principal; #Err : ApiError };
  public type Request = {
    url : Text;
    method : Text;
    body : [Nat8];
    headers : [HeaderField];
  };
  public type Response = {
    body : [Nat8];
    headers : [HeaderField];
    upgrade : Bool;
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
  public type TokenId = Nat64;
  public type TxReceipt = { #Ok : Nat; #Err : ApiError };
  public type UpdateMetadataValuesInput = {
    id : TokenId;
    updatedSpaceDescription : Text;
    updatedOwnerName : Text;
    updatedOwnerContactInfo : Text;
    updatedSpaceData : Text;
    updatedSpaceName : Text;
  };
  public type Self = actor {
    balanceOfDip721 : shared query Principal -> async Nat64;
    check_user_has_nft : shared query () -> async Bool;
    createSpace : shared Text -> async NftResult;
    getCallerSpaces : shared query () -> async [Nft];
    getMaxLimitDip721 : shared query () -> async Nat16;
    getMetadataDip721 : shared query TokenId -> async MetadataResult;
    getMetadataForUserDip721 : shared Principal -> async ExtendedMetadataResult;
    getSpace : shared query TokenId -> async NftResult;
    getTokenIdsForUserDip721 : shared query Principal -> async [TokenId];
    greet : shared Text -> async Text;
    http_request : shared query Request -> async Response;
    logoDip721 : shared query () -> async LogoResult;
    mintDip721 : shared (Principal, MetadataDesc) -> async MintReceipt;
    nameDip721 : shared query () -> async Text;
    ownerOfDip721 : shared query TokenId -> async OwnerResult;
    safeTransferFromDip721 : shared (
        Principal,
        Principal,
        TokenId,
      ) -> async TxReceipt;
    supportedInterfacesDip721 : shared query () -> async [InterfaceId];
    symbolDip721 : shared query () -> async Text;
    totalSupplyDip721 : shared query () -> async Nat64;
    transferFromDip721 : shared (
        Principal,
        Principal,
        TokenId,
      ) -> async TxReceipt;
    updateUserSpace : shared UpdateMetadataValuesInput -> async NftResult;
  }
}