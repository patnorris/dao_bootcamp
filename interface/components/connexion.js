import { principal, username } from "../stores"
import { daoActor } from "../stores"
import { idlFactory as idlFactoryDAO } from "../../src/declarations/dao/dao.did.js"
import { HttpAgent, Actor } from "@dfinity/agent"

const daoCanisterId = 
  process.env.NODE_ENV === "development" ? "ryjl3-tyaaa-aaaaa-aaaba-cai" : "ujk2s-wqaaa-aaaai-acpuq-cai"

// See https://docs.plugwallet.ooo/ for more informations
export async function plugConnection() {
  const result = await window.ic.plug.requestConnect({
    whitelist: [daoCanisterId],
  })
  if (!result) {
    throw new Error("User denied the connection")
  }
  const p = await window.ic.plug.agent.getPrincipal()

  const actor = await window.ic.plug.createActor({
    canisterId: daoCanisterId,
    interfaceFactory: idlFactoryDAO,
  })

  const user_name = await actor.get_username();

  principal.update(() => p)
  daoActor.update(() => actor)
  username.update(() => user_name[0])
}
