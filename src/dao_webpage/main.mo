import Principal "mo:base/Principal";
import Text "mo:base/Text";

import HTTP "./Http";

actor {
    public shared query (msg) func whoami() : async Principal {
        return msg.caller;
    };

    stable var dao_text : Text = "A purely peer-to-peer version of electronic cash would allow online payments to be sent directly from one party to another without going through a financial institution. Digital signatures provide part of the solution, but the main benefits are lost if a trusted third party is still required to prevent double-spending. We propose a solution to the double-spending problem using a peer-to-peer network. The network timestamps transactions by hashing them into an ongoing chain of hash-based proof-of-work, forming a record that cannot be changed without redoing the proof-of-work. The longest chain not only serves as proof of the sequence of events witnessed, but proof that it came from the largest pool of CPU power. As long as a majority of CPU power is controlled by nodes that are not cooperating to attack the network, they'll generate the longest chain and outpace attackers. The network itself requires minimal structure. Messages are broadcast on a best effort basis, and nodes can leave and rejoin the network at will, accepting the longest proof-of-work chain as proof of what happened while they were gone.";

    public query func get_dao_text() : async Text {
        return dao_text;
    };

    public func change_dao_text(updatedDaoText : Text) : async Text {
        // TODO: add dao_backend as only controller

        dao_text := updatedDaoText;
        return dao_text;
    };

// HTTP interface
  public query func http_request(request : HTTP.Request) : async HTTP.Response {
    if (Text.contains(request.url, #text("daotext"))) {
      return {
        upgrade = false;
        status_code = 200;
        headers = [ ("content-type", "text/plain") ];
        body = Text.encodeUtf8(dao_text);
        streaming_strategy = null;
      };
    } else {
      /* return {
        upgrade = false; // ← If this is set to true, the request will be sent to http_request_update()
        status_code = 200;
        headers = [ ("content-type", "text/plain") ];
        body = "It does not work";
        streaming_strategy = null;
      }; */
      return {
        upgrade = false;
        status_code = 200;
        headers = [ ("content-type", "text/plain") ];
        body = Text.encodeUtf8(dao_text);
        streaming_strategy = null;
      };
    };
  };

};