# Backup your OTPs

This is a Rails GraphQL API to backup OTPs. After registering, a user can create OTPs by providing a password (for example a 6 digit PIN) the server will encrypt the OTPs' secret. The underlying cryptography primitives are based on [libsodium's](https://download.libsodium.org/doc/) [sealed boxes](https://download.libsodium.org/doc/public-key_cryptography/sealed_boxes).

## How it works
- The user registers and gets back a `Bearer` token.
- The user registers a device (a client) and provides a password (for example a 6 digit PIN).
	- The server generates a `master_key` to encrypt the user's OTPs' secrets.
	- The server derives a 32byte key from the user's password using `scrypt`.
	- The server encrypts the `master_key` with the `derived_key`
- The user adds an OTP and provides the same password used when registering the device.
	- The server derives a 32byte key from the user's password using `scrypt`.
	- The server decrypts the device's `master_key` with the `derived_key`.
	- The server encrypts the OTP secret with the `master_key`.

## Cryptography
- Libsodium's Sealed Boxes use the [Authenticated Encryption](https://en.wikipedia.org/wiki/Authenticated_encryption) primitives `XSalsa20-Poly1305`.
- The device's `master_key` is derived using the [scrypt](https://en.wikipedia.org/wiki/Scrypt) [Key Derivation Function](https://en.wikipedia.org/wiki/Key_derivation_function).

## Examples of `queries` and `mutations` and `responses`

### Register a `User`

**Request**
```graphql
curl -H "Content-Type: application/json" \
-d '{"query": "mutation { registerUser(email: \"some.user@gmail.com\", password: \"s3cr37!p4ssw0r\") { email } }"}' \
-X POST http://localhost:3000/graphql
```

**Response**
```json
{"data":{"registerUser":{"email":"some.user@gmail.com"}}}
```

### Sign in

**Request**
```graphql
curl -H "Content-Type: application/json" \
-d '{"query": "mutation { signInUser(email: \"some.user@gmail.com\", password: \"s3cr37!p4ssw0r\") { token user { email } } }"}' \
-X POST http://localhost:3000/graphql
```

**Response**
```json
{"data":{"signInUser":{"token":"efd1omhwCtkVv7CUumW/LrcU--9H6EQkJ6mwmPqvqX--jyD13UTP0hKvZ6ZCvBun9A==","user":{"email":"some.user@gmail.com"}}}}
```

### Add a new Device

**Request**
```graphql
curl -H "Content-Type: application/json" \
-H "Authorization: Bearer efd1omhwCtkVv7CUumW/LrcU--9H6EQkJ6mwmPqvqX--jyD13UTP0hKvZ6ZCvBun9A==" \
-d '{"query": "mutation { addDevice(name: \"iPhone XS Max\", password: \"123456\") { id name } }"}' \
-X POST http://localhost:3000/graphql
```

**Response**
```json
{"data":{"addDevice":{"id":"1","name":"iPhone XS Max"}}}
```

### Add a new OTP

**Request**
```graphql
curl -H "Content-Type: application/json" \
-H "Authorization: Bearer efd1omhwCtkVv7CUumW/LrcU--9H6EQkJ6mwmPqvqX--jyD13UTP0hKvZ6ZCvBun9A==" \
-d '{"query": "mutation { addOtp(account: \"Okta\", secret: \"LhBcxADNq0NrcPlxwP5skw\", device_id: 1, password: \"123456\") { id account } }"}' \
-X POST http://localhost:3000/graphql
```

**Response**
```json
{"data":{"addOtp":{"id":"1","account":"Okta"}}}
```

### Get the list of Devices for the current user

**Request**
```graphql
curl -H "Content-Type: application/json" \
-H "Authorization: Bearer efd1omhwCtkVv7CUumW/LrcU--9H6EQkJ6mwmPqvqX--jyD13UTP0hKvZ6ZCvBun9A==" \
-d '{"query": "{ devices { id name } }"}' \
-X POST http://localhost:3000/graphql
```

**Response**
```json
{"data":{"devices":[{"id":"1","name":"iPhone XS Max"}]}}
```

### Get the list of OTPs from a specific device

**Request**
```graphql
curl -H "Content-Type: application/json" \
-H "Authorization: Bearer efd1omhwCtkVv7CUumW/LrcU--9H6EQkJ6mwmPqvqX--jyD13UTP0hKvZ6ZCvBun9A==" \
-d '{"query": "{ otps(device_id: 1, password: \"123456\") { id account secret } }"}' \
-X POST http://localhost:3000/graphql
```

**Response**
```json
{"data":{"otps":[{"id":"1","account":"Gmail","secret":"LhBcxADNq0NrcPlxwP5skw"}]}}
```

### License

The MIT License

Further resources on the MIT License
Copyright 2018 Ivan Rodriguez

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.