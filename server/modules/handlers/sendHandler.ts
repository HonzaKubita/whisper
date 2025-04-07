import type { Client } from "@/types/client";
import type { IncomingSendMessage } from "@/types/message";
import prisma from "@/modules/prisma";

export default async function sendHandler(connectedClients: Client[], client: Client, message: IncomingSendMessage) {
  const recipientClient = connectedClients.find((c) => c.publicKey == message.forPublicKey);

  // If the recipient client is online send the message directly
  if (recipientClient) {
    console.log("Client found online, sending message");

    recipientClient.ws.send(JSON.stringify({
      type: "receive",
      data: message.data,
    }));
  } else {
    console.log("Client offline, storing message in database");
    await prisma.package.create({
      data: {
        forPublicKey: message.forPublicKey,
        payload: message.data,
      }
    });
  }
}