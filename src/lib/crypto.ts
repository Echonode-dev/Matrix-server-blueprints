export async function generateKeyFromPassword(password: string): Promise<CryptoKey> {
  const enc = new TextEncoder();
  const keyMaterial = await crypto.subtle.importKey(
    "raw",
    enc.encode(password),
    { name: "PBKDF2" },
    false,
    ["deriveBits", "deriveKey"]
  );

  return crypto.subtle.deriveKey(
    {
      name: "PBKDF2",
      salt: enc.encode("dendrite-matrix-salt"), // In production, use a unique, random salt
      iterations: 100000,
      hash: "SHA-256",
    },
    keyMaterial,
    { name: "AES-GCM", length: 256 },
    true,
    ["encrypt", "decrypt"]
  );
}

export async function encryptMessage(text: string, key: CryptoKey): Promise<{ content: string; iv: string }> {
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const enc = new TextEncoder();
  
  const ciphertext = await crypto.subtle.encrypt(
    {
      name: "AES-GCM",
      iv: iv,
    },
    key,
    enc.encode(text)
  );

  // Convert ArrayBuffer to Base64
  const contentBase64 = btoa(String.fromCharCode(...new Uint8Array(ciphertext)));
  const ivBase64 = btoa(String.fromCharCode(...iv));

  return { content: contentBase64, iv: ivBase64 };
}

export async function decryptMessage(contentBase64: string, ivBase64: string, key: CryptoKey): Promise<string> {
  try {
    const ciphertext = new Uint8Array(atob(contentBase64).split("").map((c) => c.charCodeAt(0)));
    const iv = new Uint8Array(atob(ivBase64).split("").map((c) => c.charCodeAt(0)));

    const decryptedBuffer = await crypto.subtle.decrypt(
      {
        name: "AES-GCM",
        iv: iv,
      },
      key,
      ciphertext
    );

    const dec = new TextDecoder();
    return dec.decode(decryptedBuffer);
  } catch (e) {
    return "[Encrypted Message - Unable to decrypt]";
  }
}
