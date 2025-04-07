import { subtle, getRandomValues } from "node:crypto";

function _pemToUint8Array(pem: string): Uint8Array {
  const base64 = pem
    .replace(/-----BEGIN.*?-----/, "")
    .replace(/-----END.*?-----/, "")
    .replace(/\s/g, "");
  const binaryString = atob(base64);
  const len = binaryString.length;
  const bytes = new Uint8Array(len);
  for (let i = 0; i < len; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes;
}

function _bufferSourceToBase64(buffer: BufferSource): string {
  let bytesView: Uint8Array;
  if (buffer instanceof ArrayBuffer) {
    bytesView = new Uint8Array(buffer);
  } else if (ArrayBuffer.isView(buffer)) {
    if (buffer instanceof Uint8Array) {
      bytesView = buffer;
    } else {
      bytesView = new Uint8Array(
        buffer.buffer,
        buffer.byteOffset,
        buffer.byteLength,
      );
    }
  } else {
    throw new Error("Invalid input type for bufferSourceToBase64");
  }
  let binary = "";
  const len = bytesView.byteLength;
  for (let i = 0; i < len; i++) {
    binary += String.fromCharCode(bytesView[i]);
  }
  return btoa(binary);
}

function _base64ToUint8Array(base64: string): Uint8Array {
  const binaryString = atob(base64);
  const len = binaryString.length;
  const bytes = new Uint8Array(len);
  for (let i = 0; i < len; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes;
}

export function generateNonce(length: number = 32): string {
  const nonceBytes = new Uint8Array(length);
  getRandomValues(nonceBytes);
  return _bufferSourceToBase64(nonceBytes);
}

export async function verifyNonce(
  publicKey: string, // Expecting SPKI format (PEM or Base64)
  nonceB64: string,
  signatureB64: string,
): Promise<boolean> {
  try {
    const publicKeyBytes = publicKey.startsWith("-----BEGIN")
      ? _pemToUint8Array(publicKey)
      : _base64ToUint8Array(publicKey);
    const nonceBytes = _base64ToUint8Array(nonceB64);
    const signatureBytes = _base64ToUint8Array(signatureB64);

    // Import the Ed25519 public key
    const publicKeyObj = await subtle.importKey(
      "raw",
      publicKeyBytes,
      { name: "Ed25519" }, // Specify Ed25519 algorithm
      true, // Key is extractable (usually true for public keys)
      ["verify"], // Usage is for verification
    );

    // Verify the signature using Ed25519
    const isValid = await subtle.verify(
      { name: "Ed25519" }, // Specify Ed25519 algorithm (no extra params needed)
      publicKeyObj,
      signatureBytes,
      nonceBytes,
    );

    return isValid;
  } catch (error) {
    console.error("Ed25519 Verification failed:", error);
    return false;
  }
}
