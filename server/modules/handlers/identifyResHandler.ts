import type { IncomingIdentifyMessage } from "@/types/message";
import { verifyNonce } from "@/modules/identity";
import type { Client } from "@/types/client";

import prisma from "@/modules/prisma";

export default async function identifyResHandler(client: Client, message: IncomingIdentifyMessage) {
  console.log("Handling identify-res message");
  console.log("Client nonce:", client.nonce);
  console.log("Public key:", message.publicKey);
  console.log("Signature:", message.signature);

  try {
    if (await verifyNonce(message.publicKey, client.nonce, message.signature)) {
      client.publicKey = message.publicKey;
      client.publicKeyVerified = true;
      console.log("Public key verified successfully");

      // Send packages left for the client
      const packages = await prisma.package.findMany({
        where: {
          forPublicKey: client.publicKey,
        },
      });

      console.log("Packages found for client:", packages.length);

      if (packages.length > 0) {
        const data = packages.map((pkg) => pkg.payload);
        client.ws.send(JSON.stringify({
          type: "pickup-res",
          data,
        }));

        // Delete the packages from the database after sending
        await prisma.package.deleteMany({
          where: {
            forPublicKey: client.publicKey,
          },
        });
      }
    }
  }
  catch (error) {
    console.error("Error handling identify-res message:", error);
    client.ws.close(4001, "Error handling identify-res");
    return;
  }
}