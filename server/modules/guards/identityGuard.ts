import type { Client } from "@/types/client";
import type { BaseIncomingMessage } from "@/types/message";

export function identityGuard(client: Client) {
  // Check if the client is identified
  return client.publicKeyVerified;
}