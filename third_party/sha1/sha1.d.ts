// TypeScript definitions for crypto's sha1 module.

declare module 'crypto/sha1' {
  /**
   * All function arguments are interpreted as "binary strings" (e.g. as
   * returned by Buffer.toString("binary")) so to supply binary data or key you
   * can construct a string with the help of String.fromCharCode(), e.g. [0x44,
   * 0x5d, 0x75] -> 'D]u'.
   */

  /**
   * Computes the SHA1 hash of some data with the specified key.
   * Returns a binary string.
   */
  function str_sha1(data:string) : string

  /** As above but returns a hex-formatted string */
  function hex_sha1(data:string) : string

  /** As above but returns a base-64-formatted string */
  function b64_sha1(data:string) : string

  /**
   * Computes the HMAC-SHA1 of some data, with the specified key.
   * Returns a binary string.
   */
  function str_hmac_sha1(key:string, data:string) : string

  /** As str_hmac_sha1 but returns a hex-formatted string. */
  function hex_hmac_sha1(key:string, data:string) : string

  /** As above but returns a base-64-formatted string */
  function b64_hmac_sha1(key:string, data:string) : string
}
