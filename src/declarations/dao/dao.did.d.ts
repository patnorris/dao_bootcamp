import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Account { 'owner' : Principal, 'user' : User }
export type AssocList = [] | [[[string, string], List_1]];
export interface BasicDaoStableStorage {
  'system_params' : SystemParams,
  'accounts' : Array<Account>,
  'proposals' : Array<Proposal>,
}
export interface DAO {
  'account_balance' : ActorMethod<[], bigint>,
  'call_spaces_canister' : ActorMethod<[ProposalPayload], Result_4>,
  'call_webpage_canister' : ActorMethod<[ProposalPayload], Result_3>,
  'create_account' : ActorMethod<[string], Result_2>,
  'get_proposal' : ActorMethod<[bigint], [] | [Proposal]>,
  'get_system_params' : ActorMethod<[], SystemParams>,
  'get_username' : ActorMethod<[], [] | [string]>,
  'list_accounts' : ActorMethod<[], Array<Account>>,
  'list_open_proposals' : ActorMethod<[], Array<Proposal>>,
  'list_proposals' : ActorMethod<[], Array<Proposal>>,
  'submit_proposal' : ActorMethod<[ProposalPayload, string], Result_1>,
  'update_system_params' : ActorMethod<[UpdateSystemParamsPayload], undefined>,
  'update_token_canister' : ActorMethod<[string], undefined>,
  'update_token_requirements' : ActorMethod<
    [{ 'variable' : string, 'requirement' : bigint }],
    undefined
  >,
  'vote' : ActorMethod<[VoteArgs], Result>,
  'whoami' : ActorMethod<[], Principal>,
}
export type List = [] | [[Principal, List]];
export type List_1 = [] | [[[string, string], List_1]];
export type MetadataDesc = Array<MetadataPart>;
export interface MetadataKeyVal { 'key' : string, 'val' : MetadataVal }
export interface MetadataPart {
  'data' : Uint8Array,
  'key_val_data' : Array<MetadataKeyVal>,
  'purpose' : MetadataPurpose,
}
export type MetadataPurpose = { 'Preview' : null } |
  { 'Rendered' : null };
export type MetadataVal = { 'Nat64Content' : bigint } |
  { 'Nat32Content' : number } |
  { 'Nat8Content' : number } |
  { 'NatContent' : bigint } |
  { 'Nat16Content' : number } |
  { 'TextArrayContent' : Array<string> } |
  { 'BlobContent' : Uint8Array } |
  { 'PrincipalContent' : Principal } |
  { 'TextToTextAssocListContent' : AssocList } |
  { 'TextContent' : string };
export interface Nft {
  'id' : TokenId,
  'owner' : Principal,
  'metadata' : MetadataDesc,
}
export interface Proposal {
  'id' : bigint,
  'votes_no' : Tokens,
  'voters' : List,
  'state' : ProposalState,
  'timestamp' : bigint,
  'proposer' : Principal,
  'votes_yes' : Tokens,
  'proposal_text' : string,
  'payload' : ProposalPayload,
}
export interface ProposalPayload {
  'method' : string,
  'canister_id' : Principal,
  'message' : Uint8Array,
}
export type ProposalState = { 'open' : null } |
  { 'rejected' : null } |
  { 'executing' : null } |
  { 'accepted' : null } |
  { 'failed' : string } |
  { 'succeeded' : null };
export type Result = { 'ok' : ProposalState } |
  { 'err' : string };
export type Result_1 = { 'ok' : bigint } |
  { 'err' : string };
export type Result_2 = { 'ok' : Account } |
  { 'err' : string };
export type Result_3 = { 'ok' : [] | [string] } |
  { 'err' : string };
export type Result_4 = { 'ok' : [] | [Array<Nft>] } |
  { 'err' : string };
export interface SystemParams {
  'transfer_fee' : Tokens,
  'proposal_vote_threshold' : Tokens,
  'proposal_submission_deposit' : Tokens,
}
export type TokenId = bigint;
export interface Tokens { 'amount_e8s' : bigint }
export interface UpdateSystemParamsPayload {
  'transfer_fee' : [] | [Tokens],
  'proposal_vote_threshold' : [] | [Tokens],
  'proposal_submission_deposit' : [] | [Tokens],
}
export interface User { 'user_name' : string }
export type Vote = { 'no' : null } |
  { 'yes' : null };
export interface VoteArgs { 'vote' : Vote, 'proposal_id' : bigint }
export interface _SERVICE extends DAO {}
