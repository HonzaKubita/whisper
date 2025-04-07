export interface Client {
  publicKey: string;
  nonce: string;
  publicKeyVerified: boolean;

  ws: Bun.ServerWebSocket<unknown>;
}