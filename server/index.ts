// Message handlers
import identifyResHandler from '@/modules/handlers/identifyResHandler';
import sendHandler from '@/modules/handlers/sendHandler';

import { generateNonce } from '@/modules/identity';

import type { BaseIncomingMessage, IncomingIdentifyMessage, IncomingSendMessage } from '@/types/message';
import type { Client } from '@/types/client';
import { identityGuard } from './modules/guards/identityGuard';

const clients: Client[] = [];

Bun.serve({
  port: 3000,
  hostname: "0.0.0.0", // Listen on all interfaces
  fetch(req, server) {
    // upgrade the request to a WebSocket
    if (server.upgrade(req)) {
      return; // do not return a Response
    }
    return new Response("Upgrade failed", { status: 500 });
  },
  websocket: {
    async message(ws, message) {
      // A message is received
      console.log('Message received', message);

      let parsedMessage: BaseIncomingMessage;
      try {
        const messageString =
          message instanceof Buffer ? message.toString() : message;
        parsedMessage = JSON.parse(messageString);
      } catch (e) {
        console.error("Invalid JSON received:", message);
        ws.close(1003, "Invalid JSON"); // 1003: Unsupported Data
        return;
      }

      const client = clients.find((client) => client.ws === ws);

      if (!client) {
        console.error("Client not found");
        ws.close(4002, "Client not found");
        return;
      }

      // Handle different message types
      switch (parsedMessage.type) {
        case "identify-res":
          identifyResHandler(client, parsedMessage as IncomingIdentifyMessage);
          break;
        case "send":
          if (!identityGuard(client)) break; // Ensure the client's identity is verified
          sendHandler(clients, client, parsedMessage as IncomingSendMessage);
          break;
      }

    },
    open(ws) {
      // A socket is opened
      console.log('Connection opened');

      const clientNonce = generateNonce();

      // Add the new client to the clients array
      clients.push({
        publicKey: "",
        nonce: clientNonce,
        publicKeyVerified: false,
        ws,
      });

      // Send identify message with nonce
      ws.send(JSON.stringify({
        type: "identify",
        nonce: clientNonce,
      }));
    },
    close(ws, code, message) {
      // A socket is closed
      console.log('Connection closed');

      // Remove the client from the clients array
      const clientIndex = clients.findIndex((client) => client.ws === ws);

      if (clientIndex !== -1) {
        clients.splice(clientIndex, 1);
      }
    },
    drain(ws) {}, // the socket is ready to receive more data
  },
});