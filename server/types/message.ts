// Outgoing message
export type OutgoingMessageType = "identify" | "pickup-res" | "receive";

export interface BaseOutgoingMessage {
  type: OutgoingMessageType;
}

export interface OutgoingIdentifyMessage extends BaseOutgoingMessage {
  type: "identify";
  nonce: string;
}

export interface OutgoingPickupResMessage extends BaseOutgoingMessage {
  type: "pickup-res";
  data: string[];
}

export interface OutgoingReceiveMessage extends BaseOutgoingMessage {
  type: "receive";
  data: string;
}

// Incoming message
export type IncomingMessageType = "identify-res" | "pickup" | "send";

export interface BaseIncomingMessage {
  type: IncomingMessageType;
}

export interface IncomingIdentifyMessage extends BaseIncomingMessage {
  type: "identify-res";
  signature: string;
  publicKey: string;
}

export interface IncomingPickupMessage extends BaseIncomingMessage {
  type: "pickup";
}

export interface IncomingSendMessage extends BaseIncomingMessage {
  type: "send";
  forPublicKey: string;
  data: string;
}