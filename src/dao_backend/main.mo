import Trie "mo:base/Trie";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Error "mo:base/Error";
import ICRaw "mo:base/ExperimentalInternetComputer";
import List "mo:base/List";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Char "mo:base/Char";
import Debug "mo:base/Debug";

import Types "./Types";
import ICRC1 "./ICRC-1";
import Webpage "./Webpage";
import Spaces "./Spaces";

shared actor class DAO(init : Types.BasicDaoStableStorage) = Self {
    public shared query (msg) func whoami() : async Principal {
        return msg.caller;
    };

    stable var accounts = Types.accounts_fromArray(init.accounts);
    stable var proposals = Types.proposals_fromArray(init.proposals);
    stable var next_proposal_id : Nat = 0;
    stable var system_params : Types.SystemParams = init.system_params;

    // token used by DAO (only updateable by proposal)
    stable var token_canister_principal : Text = "db3eq-6iaaa-aaaah-abz6a-cai"; // points to MBT canister
    let token_canister : ICRC1.Self = actor (token_canister_principal);

    stable var min_token_requirement_to_submit_proposal : Nat = 10000; // only updateable by proposal

    // stable var community_funds : Nat = 0;
    // stable var variable_fee_percentage : Nat = 10; // in %
    //let n = 21600; // execute heartbeat every 12h
    let n = 5;
    stable var count = 0;
    system func heartbeat() : async () {
        if (count % n == 0) {
            count := 0;
            await execute_accepted_proposals();
        };
        count += 1;
    };

    func account_get(id : Principal) : ?Types.User = Trie.get(accounts, Types.account_key(id), Principal.equal);
    func account_put(id : Principal, user : Types.User) {
        accounts := Trie.put(accounts, Types.account_key(id), Principal.equal, user).0;
    };
    func proposal_get(id : Nat) : ?Types.Proposal = Trie.get(proposals, Types.proposal_key(id), Nat.equal);
    func proposal_put(id : Nat, proposal : Types.Proposal) {
        proposals := Trie.put(proposals, Types.proposal_key(id), Nat.equal, proposal).0;
    };

    /* /// Transfer tokens from the caller's account to another account
    public shared({caller}) func transfer(transfer: Types.TransferArgs) : async Types.Result<(), Text> {
        switch (account_get caller) {
        case null { #err "Caller needs an account to transfer funds" };
        case (?from_tokens) {
            let fixed_fee = system_params.transfer_fee.amount_e8s; // Min fee for successful transfer
            let amount = transfer.amount.amount_e8s;
            if (from_tokens.amount_e8s < amount + fixed_fee) {
                #err ("Caller's account has insufficient funds to transfer " # debug_show(amount));
            } else {
                // Caluclate variable fee of amount
                let variable_fee = amount * variable_fee_percentage / 100;
                // Final fee is higher of fixed or variable fee
                var fee = fixed_fee;
                if (variable_fee > fixed_fee) {
                    fee := variable_fee;
                };
                // Transfer fee to dao reserve
                community_funds += fee;
                // and complete transfer between accounts
                let from_amount : Nat = from_tokens.amount_e8s - amount - fee;
                account_put(caller, { amount_e8s = from_amount });
                let to_amount = Option.get(account_get(transfer.to), Types.zeroToken).amount_e8s + amount - fee;
                account_put(transfer.to, { amount_e8s = to_amount });
                #ok;
            };
        };
      };
    }; */

    /// Create account for the caller
    public shared ({caller}) func create_account(username : Text) : async Types.Result<Types.Account, Text> {
        switch (account_get(caller)) {
        case null { 
            account_put(caller, { user_name = username; });
            switch (account_get(caller)) {
            case null { return #err("Could not create account. Please try again."); };
            case (?user) { return #ok({ owner = caller; user = user}); };
            };
        };
        case (?account) { return #err("You already have an account."); };
        };
    };

    /// Return the username of the caller
    public shared query ({caller}) func get_username() : async ?Text {
        switch (account_get(caller)) {
        case null { return null; };
        case (?user) { return ?user.user_name; };
        };
    };

    /// Return the account balance of the caller
    public shared ({caller}) func account_balance() : async Nat {
        let caller_balance = await token_canister.icrc1_balance_of({owner = caller; subaccount = null});
        return caller_balance;
    };

    /// Lists all accounts
    public query func list_accounts() : async [Types.Account] {
        Iter.toArray(
          Iter.map(Trie.iter(accounts),
                   func ((owner : Principal, user : Types.User)) : Types.Account = { owner; user }))
    };

    /// Submit a proposal
    ///
    /// A proposal contains a canister ID, method name and method args. If enough users
    /// vote "yes" on the proposal, the given method will be called with the given method
    /// args on the given canister.
    public shared({caller}) func submit_proposal(payload: Types.ProposalPayload, proposalText : Text) : async Types.Result<Nat, Text> {
        // Caller must have an account
        switch (account_get(caller)) {
        case null { #err("You need an account to submit a proposal") };
        case (?account) {
            // Check that caller has min required number of tokens on token_canister
            let caller_balance = await token_canister.icrc1_balance_of({owner = caller; subaccount = null});
            if (caller_balance >= min_token_requirement_to_submit_proposal) {
                let proposal_id = next_proposal_id;
                next_proposal_id += 1;

                let proposal : Types.Proposal = {
                    id = proposal_id;
                    timestamp = Time.now();
                    proposer = caller;
                    payload;
                    state = #open;
                    votes_yes = Types.zeroToken;
                    votes_no = Types.zeroToken;
                    voters = List.nil();
                    proposal_text = proposalText;
                };
                proposal_put(proposal_id, proposal);
                #ok(proposal_id)
            } else {
                #err("You need at least " # debug_show(min_token_requirement_to_submit_proposal) # " tokens to submit a proposal")
            };
        };
        };
    };

    /// Return the proposal with the given ID, if one exists
    public query func get_proposal(proposal_id: Nat) : async ?Types.Proposal {
        proposal_get(proposal_id)
    };

    /// Return the list of all proposals
    public query func list_proposals() : async [Types.Proposal] {
        Iter.toArray(Iter.map(Trie.iter(proposals), func (kv : (Nat, Types.Proposal)) : Types.Proposal = kv.1))
    };

    // Retrieve open proposals
    public query func list_open_proposals() : async [Types.Proposal] {
        func only_open(kv : (Nat, Types.Proposal)) : Bool {
            if (kv.1.state == #open) {
                return true;
            };
            return false;
        };
        Iter.toArray(Iter.map(Iter.filter(Trie.iter(proposals), only_open), func (kv : (Nat, Types.Proposal)) : Types.Proposal = kv.1))
    };

    // Vote on an open proposal
    public shared({caller}) func vote(args: Types.VoteArgs) : async Types.Result<Types.ProposalState, Text> {
        switch (proposal_get(args.proposal_id)) {
        case null { #err("No proposal with ID " # debug_show(args.proposal_id) # " exists") };
        case (?proposal) {
                var state = proposal.state;
                if (state != #open) {
                    return #err("Proposal " # debug_show(args.proposal_id) # " is not open for voting");
                };

                switch (account_get(caller)) {
                case null { return #err("You need an account to vote"); };
                case (?account) {
                    let caller_balance = await token_canister.icrc1_balance_of({owner = caller; subaccount = null});
                    if (caller_balance > 0) {
                        if (List.some(proposal.voters, func (e : Principal) : Bool = e == caller)) {
                            return #err("Already voted");
                        };

                        var votes_yes = proposal.votes_yes.amount_e8s;
                        var votes_no = proposal.votes_no.amount_e8s;
                        switch (args.vote) {
                        case (#yes) { votes_yes += caller_balance };
                        case (#no) { votes_no += caller_balance };
                        };
                        let voters = List.push(caller, proposal.voters);

                        if (votes_yes >= system_params.proposal_vote_threshold.amount_e8s) {
                            state := #accepted;
                        };
                        
                        if (votes_no >= system_params.proposal_vote_threshold.amount_e8s) {
                            state := #rejected;
                        };

                        let updated_proposal = {
                            id = proposal.id;
                            votes_yes = { amount_e8s = votes_yes };                              
                            votes_no = { amount_e8s = votes_no };
                            voters;
                            state;
                            timestamp = proposal.timestamp;
                            proposer = proposal.proposer;
                            payload = proposal.payload;
                            proposal_text = proposal.proposal_text;
                        };
                        proposal_put(args.proposal_id, updated_proposal);
                    } else {
                        return #err("You don't have any tokens to vote with");
                    };
                };
                };
                #ok(state)
            };
        };
    };

    /// Get the current system params
    public query func get_system_params() : async Types.SystemParams { system_params };

    /// Update system params
    ///
    /// Only callable via proposal execution
    public shared({caller}) func update_system_params(payload: Types.UpdateSystemParamsPayload) : async () {
        if (caller != Principal.fromActor(Self)) {
            return;
        };
        system_params := {
            transfer_fee = Option.get(payload.transfer_fee, system_params.transfer_fee);
            proposal_vote_threshold = Option.get(payload.proposal_vote_threshold, system_params.proposal_vote_threshold);
            proposal_submission_deposit = Option.get(payload.proposal_submission_deposit, system_params.proposal_submission_deposit);
        };
    };

    /// Update token Dao uses
    ///
    /// Only callable via proposal execution
    public shared({caller}) func update_token_canister(payload: Text) : async () {
        if (caller != Principal.fromActor(Self)) {
            return;
        };
        try {
            let principal = Principal.fromText(payload);
        }
        catch (e) { return; }; 
        token_canister_principal := payload;    
    };

    /// Update min number of tokens required to submit proposal
    ///
    /// Only callable via proposal execution
    public shared({caller}) func update_token_requirements(payload: {variable : Text; requirement : Nat}) : async () {
        if (caller != Principal.fromActor(Self)) {
            return;
        };
        if (payload.variable == "min_token_requirement_to_submit_proposal") {
            min_token_requirement_to_submit_proposal := payload.requirement;
        } else {
            return;
        };   
    };

    /* /// Deduct the proposal submission deposit from the caller's account
    func deduct_proposal_submission_deposit(caller : Principal) : Types.Result<(), Text> {
        switch (account_get(caller)) {
        case null { #err "Caller needs an account to submit a proposal" };
        case (?from_tokens) {
                let threshold = system_params.proposal_submission_deposit.amount_e8s;
                if (from_tokens.amount_e8s < threshold) {
                    #err ("Caller's account must have at least " # debug_show(threshold) # " to submit a proposal")
                } else {
                    let from_amount : Nat = from_tokens.amount_e8s - threshold;
                    account_put(caller, { amount_e8s = from_amount });
                    #ok
                };
            };
        };
    }; */

    stable var dev_errors : List.List<Text> = List.nil();
    public query func get_dev_errors() : async [Text] {return List.toArray(dev_errors)};

    /// Execute all accepted proposals
    func execute_accepted_proposals() : async () {
        let accepted_proposals = Trie.filter(proposals, func (_ : Nat, proposal : Types.Proposal) : Bool = proposal.state == #accepted);
        // Update proposal state, so that it won't be picked up by the next heartbeat
        for ((id, proposal) in Trie.iter(accepted_proposals)) {
            update_proposal_state(proposal, #executing);
        };

        for ((id, proposal) in Trie.iter(accepted_proposals)) {
            switch (await execute_proposal(proposal)) {
            case (#ok) { update_proposal_state(proposal, #succeeded); };
            case (#err(err)) { 
                if (Text.contains(err, #text "development___err42")) {
                    dev_errors := List.push(err, dev_errors);
                } 
                else {
                    dev_errors := List.push(err, dev_errors);
                    update_proposal_state(proposal, #failed(err));
                }; 
            };
            };
        };
    };

    func textToNat64(txt : Text) : Nat64 {
        assert(txt.size() > 0);
        let chars = txt.chars();

        var num : Nat = 0;
        for (v in chars){
            if (v != '\'') {
                let charToNum = Nat32.toNat(Char.toNat32(v)-48);
                assert(charToNum >= 0 and charToNum <= 9);
                num := num * 10 +  charToNum;
            };     
        };

        Nat64.fromNat(num);
    };

    var updatedSpaceData : Text = "initial";
    stable var updatedSpaceName : Text = "initial";
    stable var updatedSpaceDescription : Text = "initial";
    stable var updatedOwnerContactInfo : Text = "initial";
    stable var updatedOwnerName : Text = "initial";
    stable var spaceId : Text = "initial";

    stable var proposalTextExecuted : Text = "initial";

    //public query func get_update_params_debug() : async [Text] { [proposalTextExecuted, spaceId, updatedOwnerName, updatedOwnerContactInfo, updatedSpaceDescription, updatedSpaceName, updatedSpaceData] };

    public query func test_extracting_from_string(string : Text) : async [Text] {
        var remainer : [Text] = Iter.toArray(Text.tokens(string, #text("updatedSpaceData\":\"")));
        Debug.print(debug_show(remainer));
        updatedSpaceData := Iter.toArray(Text.tokens(remainer[1], #text("\"}")))[0];
        Debug.print(debug_show(updatedSpaceData));
        remainer := Iter.toArray(Text.tokens(remainer[0], #text("updatedSpaceName\":\"")));
        Debug.print(debug_show(remainer));
        updatedSpaceName := Iter.toArray(Text.tokens(remainer[1], #text("\",")))[0];
        Debug.print(debug_show(updatedSpaceName));
        remainer := Iter.toArray(Text.tokens(remainer[0], #text("updatedSpaceDescription\":\"")));
        Debug.print(debug_show(remainer));
        updatedSpaceDescription := Iter.toArray(Text.tokens(remainer[1], #text("\",")))[0];
        Debug.print(debug_show(updatedSpaceDescription));
        remainer := Iter.toArray(Text.tokens(remainer[0], #text("updatedOwnerContactInfo\":\"")));
        Debug.print(debug_show(remainer));
        updatedOwnerContactInfo := Iter.toArray(Text.tokens(remainer[1], #text("\",")))[0];
        Debug.print(debug_show(updatedOwnerContactInfo));
        remainer := Iter.toArray(Text.tokens(remainer[0], #text("updatedOwnerName\":\"")));
        Debug.print(debug_show(remainer));
        updatedOwnerName := Iter.toArray(Text.tokens(remainer[1], #text("\",")))[0];
        Debug.print(debug_show(updatedOwnerName));
        remainer := Iter.toArray(Text.tokens(remainer[0], #text("id\":")));
        Debug.print(debug_show(remainer));
        spaceId := Iter.toArray(Text.tokens(remainer[1], #text(",")))[0];
        Debug.print(debug_show(spaceId));
        let id = textToNat64(spaceId);
        Debug.print(debug_show(id));
                        
        return [updatedSpaceData, updatedSpaceName, updatedSpaceDescription, updatedOwnerContactInfo, updatedOwnerName, spaceId];
    };

    /// Execute the given proposal
    func execute_proposal(proposal: Types.Proposal) : async Types.Result<(), Text> {
        try {
            let payload = proposal.payload;
            if (payload.canister_id == Principal.fromText("vee64-zyaaa-aaaai-acpta-cai")) {
                if (payload.method == "createSpace") {
                    let spaces_canister : Spaces.Self = actor ("vee64-zyaaa-aaaai-acpta-cai");
                    //ignore await ICRaw.call(payload.canister_id, payload.method, to_candid(payload.message));
                    ignore await spaces_canister.createSpace(proposal.proposal_text);
                    #ok
                } else if (payload.method == "updateUserSpace") {
                    // proposal.proposal_text for updateUserSpace looks like:
                     /* {
                        id: spaceId,
                        updatedOwnerName,
                        updatedOwnerContactInfo,
                        updatedSpaceDescription,
                        updatedSpaceName,
                        updatedSpaceData: proposalText,
                     } */
                    proposalTextExecuted := proposal.proposal_text;
                    try {
                        var remainer : [Text] = Iter.toArray(Text.tokens(proposal.proposal_text, #text("updatedSpaceData\":\"")));
                        updatedSpaceData := Iter.toArray(Text.tokens(remainer[1], #text("\"}")))[0];
                        remainer := Iter.toArray(Text.tokens(remainer[0], #text("updatedSpaceName\":\"")));
                        updatedSpaceName := Iter.toArray(Text.tokens(remainer[1], #text("\",")))[0];
                        remainer := Iter.toArray(Text.tokens(remainer[0], #text("updatedSpaceDescription\":\"")));
                        updatedSpaceDescription := Iter.toArray(Text.tokens(remainer[1], #text("\",")))[0];
                        remainer := Iter.toArray(Text.tokens(remainer[0], #text("updatedOwnerContactInfo\":\"")));
                        updatedOwnerContactInfo := Iter.toArray(Text.tokens(remainer[1], #text("\",")))[0];
                        remainer := Iter.toArray(Text.tokens(remainer[0], #text("updatedOwnerName\":\"")));
                        updatedOwnerName := Iter.toArray(Text.tokens(remainer[1], #text("\",")))[0];
                        remainer := Iter.toArray(Text.tokens(remainer[0], #text("id\":")));
                        spaceId := Iter.toArray(Text.tokens(remainer[1], #text(",")))[0];
                        let updateMetadataValuesInput = {
                            id = textToNat64(spaceId);
                            updatedOwnerName = updatedOwnerName;
                            updatedOwnerContactInfo = updatedOwnerContactInfo;
                            updatedSpaceDescription = updatedSpaceDescription;
                            updatedSpaceName = updatedSpaceName;
                            updatedSpaceData = updatedSpaceData;
                        };

                        let spaces_canister : Spaces.Self = actor ("vee64-zyaaa-aaaai-acpta-cai");
                        ignore await spaces_canister.updateUserSpace(updateMetadataValuesInput);
                        #ok
                    }
                    //catch (e) { #err(Error.message e # "development___err42") };
                    catch (e) { #err(Error.message e) };
                } else {
                    #err("Not supported")
                };
            } else if (payload.canister_id == Principal.fromText("uajro-ayaaa-aaaai-acpva-cai")) {
                if (payload.method == "change_dao_text") {
                    let webpage_canister : Webpage.Self = actor ("uajro-ayaaa-aaaai-acpva-cai");
                    ignore await webpage_canister.change_dao_text(proposal.proposal_text);
                    #ok
                } else {
                    #err("Not supported")
                };
            } else {
                #err("Not supported")
            };
        }
        catch (e) { #err(Error.message e) };
    };

    func update_proposal_state(proposal: Types.Proposal, state: Types.ProposalState) {
        let updated = {
            state;
            id = proposal.id;
            votes_yes = proposal.votes_yes;
            votes_no = proposal.votes_no;
            voters = proposal.voters;
            timestamp = proposal.timestamp;
            proposer = proposal.proposer;
            payload = proposal.payload;
            proposal_text = proposal.proposal_text;
        };
        proposal_put(proposal.id, updated);
    };

    /// Call whitelisted external canister functions (not needing accepted proposal)
    stable let whitelisted_canisters = ["vee64-zyaaa-aaaai-acpta-cai", "uajro-ayaaa-aaaai-acpva-cai"];
    stable let whitelisted_methods = ["getCallerSpaces", "getSpace", "get_dao_text"];
    public shared({caller}) func call_spaces_canister(payload: Types.ProposalPayload) : async Types.Result<?([Types.Nft]), Text> {
        switch (account_get(caller)) {
        case null { return #err("Not allowed"); };
        case (?account) {
            switch(Array.find<Text>(whitelisted_canisters, func x = Principal.fromText(x) == payload.canister_id)){
            case null { return #err("Not allowed"); };
            case (?whitelisted_canister) {
                switch(Array.find<Text>(whitelisted_methods, func x = x == payload.method)){
                case null { return #err("Not allowed"); };
                case (?whitelisted_method) {
                    try {
                        let result = await ICRaw.call(payload.canister_id, payload.method, to_candid(payload.message));
                        #ok(from_candid(result))
                    }
                    catch (e) { #err(Error.message e) };
                };
                };
            };
            };
        };
        };
    };

    public shared({caller}) func call_webpage_canister(payload: Types.ProposalPayload) : async Types.Result<?(Text), Text> {
        switch (account_get(caller)) {
        case null { return #err("Not allowed"); };
        case (?account) {
            switch(Array.find<Text>(whitelisted_canisters, func x = Principal.fromText(x) == payload.canister_id)){
            case null { return #err("Not allowed"); };
            case (?whitelisted_canister) {
                switch(Array.find<Text>(whitelisted_methods, func x = x == payload.method)){
                case null { return #err("Not allowed"); };
                case (?whitelisted_method) {
                    try {
                        let result = await ICRaw.call(payload.canister_id, payload.method, to_candid(payload.message));
                        #ok(from_candid(result))
                    }
                    catch (e) { #err(Error.message e) };
                };
                };
            };
            };
        };
        };
    };
};