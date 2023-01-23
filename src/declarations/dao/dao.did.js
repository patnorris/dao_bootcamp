export const idlFactory = ({ IDL }) => {
  const List = IDL.Rec();
  const List_1 = IDL.Rec();
  const Tokens = IDL.Record({ 'amount_e8s' : IDL.Nat });
  const SystemParams = IDL.Record({
    'transfer_fee' : Tokens,
    'proposal_vote_threshold' : Tokens,
    'proposal_submission_deposit' : Tokens,
  });
  const User = IDL.Record({ 'user_name' : IDL.Text });
  const Account = IDL.Record({ 'owner' : IDL.Principal, 'user' : User });
  List.fill(IDL.Opt(IDL.Tuple(IDL.Principal, List)));
  const ProposalState = IDL.Variant({
    'open' : IDL.Null,
    'rejected' : IDL.Null,
    'executing' : IDL.Null,
    'accepted' : IDL.Null,
    'failed' : IDL.Text,
    'succeeded' : IDL.Null,
  });
  const ProposalPayload = IDL.Record({
    'method' : IDL.Text,
    'canister_id' : IDL.Principal,
    'message' : IDL.Vec(IDL.Nat8),
  });
  const Proposal = IDL.Record({
    'id' : IDL.Nat,
    'votes_no' : Tokens,
    'voters' : List,
    'state' : ProposalState,
    'timestamp' : IDL.Int,
    'proposer' : IDL.Principal,
    'votes_yes' : Tokens,
    'proposal_text' : IDL.Text,
    'payload' : ProposalPayload,
  });
  const BasicDaoStableStorage = IDL.Record({
    'system_params' : SystemParams,
    'accounts' : IDL.Vec(Account),
    'proposals' : IDL.Vec(Proposal),
  });
  const TokenId = IDL.Nat64;
  List_1.fill(IDL.Opt(IDL.Tuple(IDL.Tuple(IDL.Text, IDL.Text), List_1)));
  const AssocList = IDL.Opt(IDL.Tuple(IDL.Tuple(IDL.Text, IDL.Text), List_1));
  const MetadataVal = IDL.Variant({
    'Nat64Content' : IDL.Nat64,
    'Nat32Content' : IDL.Nat32,
    'Nat8Content' : IDL.Nat8,
    'NatContent' : IDL.Nat,
    'Nat16Content' : IDL.Nat16,
    'TextArrayContent' : IDL.Vec(IDL.Text),
    'BlobContent' : IDL.Vec(IDL.Nat8),
    'PrincipalContent' : IDL.Principal,
    'TextToTextAssocListContent' : AssocList,
    'TextContent' : IDL.Text,
  });
  const MetadataKeyVal = IDL.Record({ 'key' : IDL.Text, 'val' : MetadataVal });
  const MetadataPurpose = IDL.Variant({
    'Preview' : IDL.Null,
    'Rendered' : IDL.Null,
  });
  const MetadataPart = IDL.Record({
    'data' : IDL.Vec(IDL.Nat8),
    'key_val_data' : IDL.Vec(MetadataKeyVal),
    'purpose' : MetadataPurpose,
  });
  const MetadataDesc = IDL.Vec(MetadataPart);
  const Nft = IDL.Record({
    'id' : TokenId,
    'owner' : IDL.Principal,
    'metadata' : MetadataDesc,
  });
  const Result_4 = IDL.Variant({
    'ok' : IDL.Opt(IDL.Vec(Nft)),
    'err' : IDL.Text,
  });
  const Result_3 = IDL.Variant({ 'ok' : IDL.Opt(IDL.Text), 'err' : IDL.Text });
  const Result_2 = IDL.Variant({ 'ok' : Account, 'err' : IDL.Text });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const UpdateSystemParamsPayload = IDL.Record({
    'transfer_fee' : IDL.Opt(Tokens),
    'proposal_vote_threshold' : IDL.Opt(Tokens),
    'proposal_submission_deposit' : IDL.Opt(Tokens),
  });
  const Vote = IDL.Variant({ 'no' : IDL.Null, 'yes' : IDL.Null });
  const VoteArgs = IDL.Record({ 'vote' : Vote, 'proposal_id' : IDL.Nat });
  const Result = IDL.Variant({ 'ok' : ProposalState, 'err' : IDL.Text });
  const DAO = IDL.Service({
    'account_balance' : IDL.Func([], [IDL.Nat], []),
    'call_spaces_canister' : IDL.Func([ProposalPayload], [Result_4], []),
    'call_webpage_canister' : IDL.Func([ProposalPayload], [Result_3], []),
    'create_account' : IDL.Func([IDL.Text], [Result_2], []),
    'get_proposal' : IDL.Func([IDL.Nat], [IDL.Opt(Proposal)], ['query']),
    'get_system_params' : IDL.Func([], [SystemParams], ['query']),
    'get_username' : IDL.Func([], [IDL.Opt(IDL.Text)], ['query']),
    'list_accounts' : IDL.Func([], [IDL.Vec(Account)], ['query']),
    'list_open_proposals' : IDL.Func([], [IDL.Vec(Proposal)], ['query']),
    'list_proposals' : IDL.Func([], [IDL.Vec(Proposal)], ['query']),
    'submit_proposal' : IDL.Func([ProposalPayload, IDL.Text], [Result_1], []),
    'update_system_params' : IDL.Func([UpdateSystemParamsPayload], [], []),
    'update_token_canister' : IDL.Func([IDL.Text], [], []),
    'update_token_requirements' : IDL.Func(
        [IDL.Record({ 'variable' : IDL.Text, 'requirement' : IDL.Nat })],
        [],
        [],
      ),
    'vote' : IDL.Func([VoteArgs], [Result], []),
    'whoami' : IDL.Func([], [IDL.Principal], ['query']),
  });
  return DAO;
};
export const init = ({ IDL }) => {
  const List = IDL.Rec();
  const Tokens = IDL.Record({ 'amount_e8s' : IDL.Nat });
  const SystemParams = IDL.Record({
    'transfer_fee' : Tokens,
    'proposal_vote_threshold' : Tokens,
    'proposal_submission_deposit' : Tokens,
  });
  const User = IDL.Record({ 'user_name' : IDL.Text });
  const Account = IDL.Record({ 'owner' : IDL.Principal, 'user' : User });
  List.fill(IDL.Opt(IDL.Tuple(IDL.Principal, List)));
  const ProposalState = IDL.Variant({
    'open' : IDL.Null,
    'rejected' : IDL.Null,
    'executing' : IDL.Null,
    'accepted' : IDL.Null,
    'failed' : IDL.Text,
    'succeeded' : IDL.Null,
  });
  const ProposalPayload = IDL.Record({
    'method' : IDL.Text,
    'canister_id' : IDL.Principal,
    'message' : IDL.Vec(IDL.Nat8),
  });
  const Proposal = IDL.Record({
    'id' : IDL.Nat,
    'votes_no' : Tokens,
    'voters' : List,
    'state' : ProposalState,
    'timestamp' : IDL.Int,
    'proposer' : IDL.Principal,
    'votes_yes' : Tokens,
    'proposal_text' : IDL.Text,
    'payload' : ProposalPayload,
  });
  const BasicDaoStableStorage = IDL.Record({
    'system_params' : SystemParams,
    'accounts' : IDL.Vec(Account),
    'proposals' : IDL.Vec(Proposal),
  });
  return [BasicDaoStableStorage];
};
