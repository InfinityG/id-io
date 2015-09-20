# id-io
Identity/registration service built on Sinatra

__PLEASE NOTE__: This code is still in alpha development. Some features are still in early development and some are still to be implemented.

## Features
- __RESTful API__
  - Supports:
    - Creation of trusts between id-io API and Relying Parties
    - Registration of user identities
    - Authentication of users, using a hybrid Oauth 2.0 workflow
        - *Although this already complies broadly with the [Oauth 2.0 specification](https://tools.ietf.org/html/rfc6749),
            work is ongoing to ensure full compliance*
    - Connecting to other users ('connection' requests)
    - Generation of signed and encrypted tokens for consumption by Relying Parties
- __Basic Single Sign-On functionality__
  - SSO authentication support for the following combinations:
    - username/password
    - username/signature
  - Signature type supported:
    - ECDSA
  - Payload encryption:
    - 256 bit AES encryption, using Relying Party's shared key (stored on trust creation)
- __Relying Party Support__
  - Tokens generated by the API can be parsed by relying parties using 'ig-identity-rp-validator' Ruby gem
- __Identity Storage__
  - Local: MongoDB is used as the backing store for identities
  - Blockchain: We've created a blockchain integration prototype branch (__blockchain1__) which uses the Ripple blockchain (there are other potential alternatives - see the [appendix](#blockchain-integration) at the end of this page).
- __Webhooks__
  - Registrations on the API support a Webhook callback mechanism on successful registration

## Dependencies
- The application is written in Ruby and Sinatra DSL
- Bundler is required for managing gem dependencies - just run __bundle install__
- MongoDB is required for the local backing store
- A Docker file is included for quick deployments - note that the default deployment installs MongoDB in the same image

## Signing

ID-IO relies heavily on the [Elliptical Curve Digital Signature](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm)
 __(ECDSA)__ algorithm to perform signing and signature validation 
operations. ECDSA is an __asymmetric encryption__ algorithm (or __public key encryption__ algorithm),
meaning that it uses public and private (or 'secret') keys. A good understanding of public key cryptography is required 
to perform signing operations correctly. 

### Libraries

#### Ruby

To make life easier, we have created a utility Ruby gem called 
[ig-crypto-utils](https://rubygems.org/gems/ig-crypto-utils) which is used extensively in ID-IO, and can be used in any
Ruby application to sign requests for use in ID-IO. 

#### Javascript

To sign requests on the front-end (ie: Javascript), we've also created a library called [ig-js-utils](https://github.com/InfinityG/ig-js-utils),
which is itself based on libraries produced by [CryptoCoinJS](http://cryptocoinjs.com/).

#### Objective-C

A third party library for Objective-C by Richard Moore can be found at [GMEllipticCurveCrypto](https://github.com/ricmoo/GMEllipticCurveCrypto).

## API documentation

### Trust creation
This endpoint is used to create a trust between id-io and the relying party. The relying party provides a shared AES key
which is used for symmetrical encryption of login payloads. *This is an administrative endpoint and so requires a valid
authorization header.*

- Uri: /trusts
- Method: POST
- Headers: Authorization: [auth_token]
- Sample payload: 

  ```
  {
    "domain":"www.testdomain.com",
    "aes_key":"ky4xgi0+KvLYmVp1J5akqkJkv8z5rJsHTo9FcBc0hgo="
  }
  ```
  
- Result:
  
  ```
  {
    "id":"5533a8c1b85a5467eb000016"
  }
  ```

### User Registration
This endpoint is used to register a user. Besides a standard username and password, an EC (asymmetric) public key is also
registered. Asymmetric (public/private) key pairs can be generated on a client with the use of the CryptocoinJS library
'coinkey' (http://cryptocoinjs.com/modules/currency/coinkey/). It is up to the client application to securely store 
the private (secret) key on behalf of the user.

- Uri: /users
- Method: POST
- Headers: none
- Sample payload: 
  
  ```
  {
    "first_name":"Johnny",
    "last_name":"Mnemonic",
    "username":"johnny_mnemonic@test.com",
    "password":"passwOrd1!",
    "public_key":"Ag7PunGy2BmnAi+PGE4/Dm9nCg1URv8wLZwSOggyfmAn"
  }
  ```
  
- Result:
    - The registration of a new user returns the user id, username, and a challenge that can be used for a subsequent 
    login (see [Login with a signed challenge](#login-with-signed-challenge))
  
  ```
  {
      "id": "5533a64db85a5467eb000001",
      "username": "johnny_mnemonic@test.com",
      "challenge": {
          "data": "e1dfa83a-fafb-4be9-bba2-aaa7c77e12e7"
      }
  }
  ```
  
### Update User details
This endpoint is used to update the user's details - it is currently restricted to the __public key__ only. This means that
a user can regenerate their public/secret key pairs (in the case of key compromise) and ensure that ID-IO has updated
public keys.

- Prerequisites:
    - User must be registered
    - User must have logged in (see login process below) and obtained an auth token
- Uri: /users/{username}
- Method: POST
- Headers: Authorization: [auth token]
- Sample payload: 
  
  ```
  {
    "public_key":"Ag7PunGy2BmnAi+PGE4/Dm9nCg1URv8wLZwSOggyfmAn"
  }
  ```
  
- Result:
    - The registration of a new user returns the user id, username, and a challenge that can be used for a subsequent 
    login (see [Login with a signed challenge](#login-with-signed-challenge))
  
  ```
  {
    "id":"559e7b7bb85a54456f00005d",
    "username":"johnny_mnemonic@test.com"
  }
  ```
    
### Create login challenge (for signature-based login)
This endpoint is used to generate a new challenge, which must be signed for use in the subsequent login step. 

- Prerequisites:
  - User must be registered
- Uri: /challenge
- Method: POST
- Headers: none
- Sample payload: 
  
  ```
  {
    "username":"johnny_mnemonic@test.com"
  }
  ```
  
- Result:
  
  ```
  {
    "data":"a755ccfd-9809-49ad-8990-1020c96024c7"
  }
  ```

### Login with signed challenge
This endpoint is used to login using a signed challenge. It is up to the client/app to implement the signing logic using
 an ECDSA algorithm.

- Prerequisites:
  - User must have registered a public ECDSA key on id-io
  - User must have the matching ECDSA secret in order to sign the challenge
  - Client-side (javascript) signing can be done using the CryptocoinJS ECDSA library: http://cryptocoinjs.com/modules/crypto/ecdsa/#usage
    - Note that this is a NodeJS library but can be converted for use in the browser with the aid of Browserify (http://browserify.org/)
  - User must first create a challenge (see above step)
  - a digest must first be created from the challenge data (sha256 hash, base64 encoded), before signing
- Uri: /login
- Method: POST
- Headers: none
- Sample payload: 
  
  ```
  {
    "username":"johnny_mnemonic@test.com",
    "challenge":{
      "digest":"YTc1NWNjZmQtOTgwOS00OWFkLTg5OTAtMTAyMGM5NjAyNGM3\n",
      "signature":"MEUCIBQ87YyGpFp97iVlVez5WuUGCnTeVd4hctArzma0pOe4AiEAuIEPWnea\nd4xYHaOXPDFECZdQRXrFMEsS2oNYLsShLB8=\n"
      },
    "fingerprint":"9f6e26a098b8db4a09b843ca9b074ccb",
    "domain":"www.testdomain.com"
  }
  ```
  
- Result:
  
  ```
  {
    "auth":"e0t0ibnTg6EnDS/z5bDTYiikJO/97M07/XFQf0iB2XYdxxJoMYD9WGqC/zVO\nTm5d9DAz6MsPNmD1GX/L5g3DMs9ZZH4B4/dkeuGume/myIYrBLsd2j4V3qKM\n3Aw0bP+tdu8PweFwW7q/me6DH1z+ZlXS4Vz/K1ZjBabgETZ06n4+anjcYbAn\nAduYF30hpOhDGi+UAzhkhCXRQe/O1AbxqsHVgW+bIl/3FVECWxUsrQYOhIZn\noZhC2dRNawhK0tcb063s3ZxhoEDiFwOnBjUdPwLJFrZsWsOJ1ebJpAZp09XZ\nfB4FIrG5v3CaaDcCdI1Uxwsdpy7kV4qLWWgEmspbwadhL1lyh++U4qc9sMvD\n6G/Nf4RlOQkg09CRCe0k0VHfUvamiTstDuP0HmCevYeOz+2TKKXIta5XOnkJ\n0XU6S+uXr02KbU9vnMllLeZkjCFxkgblsFxZPaAwTLezAakv0asWbwWWhuZ4\naOkTwTLRTYbsmSejZLd7y8GHkGIFTJL5QcbfxexWj9BblZWXNWfwOgKhj8pa\nTgRB6CHqwH/pBmovCHN9tsQkNQLcZin0mOxE4tcc4Gpc6HdD3kFMEsJ+X3Zi\nWanqpK/28wPfCjwrMiI=\n",
    "iv":"h8pVugEhW4jg+FNGoPZTxQ==\n"
  }
  ``` 

### Login without challenge (ie: username/password combination)
- Prerequisites:
  - User must be registered
- Uri: /login
- Method: POST
- Headers: none
- Sample payload: 
  
  ```
  {
    "username":"johnny_mnemonic@test.com",
    "password":"passwOrd1!",
    "domain":"www.testdomain.com",
    "fingerprint":"9f6e26a098b8db4a09b843ca9b074ccb"
  }
  ```
  
- Result:
  
  ```
  {
    "auth":"gvZWzBj7zrbTovwCDutSIv4vQVENi0HcyGvQp6yLCSUjgi2lIpgr3BUfiqzr\n3SV4HXznIzrIctgek60V0TGOaS/ZcF6Ikl5RLPSRlb5dgOA/r2fewZk5cdnA\n5C6qE+1zjko+wwiSqNCDadXGGHOEMWo/yDvR+SKjEYmoiE24yQd1mNk6EFRC\nazf1yhDHe5Hghi9x6Zl8WbwZ++KDkWdLRO43/qhOy3tr34O0KiNNX2ERH60G\nv27wiAp5nvFjXHdWHN8qlVg8oWfUe8bce7/IF6T8qPP9WCYAFuoyO9sGbrET\n9Qw08/8fnSQ3RbUW5twqhSW7XFeMXwuIwk5U3IBsiHpuKX3lKLYSqGiFzZOT\niQ1M1sF0UW3ULpKQ1KG/1Rlr7N8CS2hwapXKlri8uMKLIleEQPPoURpHrusW\nz4dXHb6/CW2QinqbbhrA0WRBAE0dWknjE/jL18CHrYDWM2vCY4S2Qk4P5rWd\nUSZlWw/UBFow6PIaJpCebTI9S3kwmA3MkVRoRKksX3ZYo+i144KKOv69LUgt\nj1+S+J+k5Qo2bSslrODg1OpY2cX3HTg+2wsChGPSB3MRS2+cjEnnhmHjq0yI\n6iD8NWaWcL/OktDWEaU=\n",
    "iv":"EHoV2Y2hEOr93QXt0c9o5w==\n"
  }
  ```

### Create a connection with another user
This endpoint is used to request a 'connection' to another registered user (much like a 'friend' request). 
The 'origin' user is the one who initiates the request; the 'target' user is the user who needs to approve the 
request, and thus becomes added to the origin user's connections.

- Prerequisites:
  - Origin user must be registered
  - The target user must also be registered
- Uri: /connections
- Method: POST
- Headers: Authorization [auth_token] (this is the login token of the __origin user__)
- Sample payload:
  - username: the username of the target user
  - digest: the base64 encoded, sha256 hash of the username that will be signed
  - signature: the signed digest (signed using the secret key of the __origin user__)
  
```
  {
    "username":"mranderson@matrix.com", 
    "digest":"YTc1NWNjZmQtOTgwOS00OWFkLTg5OTAtMTAyMGM5NjAyNGM3\n",
    "signature":"MEUCIBQ87YyGpFp97iVlVez5WuUGCnTeVd4hctArzma0pOe4AiEAuIEPWnea\nd4xYHaOXPDFECZdQRXrFMEsS2oNYLsShLB8=\n"
  }
```
  
- Result:
    - The response represents a connection
    - As this will not have been confirmed yet by the connection, the 'confirmed' field value is false
  
```
{
    "id": "7628aecfb85a54687c000001",
    "status": "pending",
    "user": {
        "type":"target",
        "username": "mranderson@matrix.com",
        "first_name": "Neo",
        "last_name": "Anderson"
    }
}
```

### Get connections
This endpoint retrieves all connections for a particular user.  

- Prerequisites:
  - User must be registered
- Uri: /connections?status={'pending'/'connected'/'rejected'/'disconnected'}
- Method: GET
- Headers: Authorization [auth_token]
  
- Result:
    - The response contains a collection of connections, filtered by the 'status' parameter (if present) 
    - Unconfirmed connections do not contain public signing keys
  
```
[
    {
        "id": "7628aecfb85a54687c000001",
        "status": "pending",
        "user": {
            "type":"target",
            "username": "mranderson@matrix.com",
            "first_name": "Neo",
            "last_name": "Anderson"
        }
    },
    {
        "id": "559a9db889e26c1a9a000014",
        "status": "connected",
        "user": {
            "type":"target",
            "username": "clark_kent@test.com",
            "first_name": "Clark",
            "last_name": "Kent",
            "public_key": "AmWKxZpx8p8wiU70KOPGIc/2qdnfxyh4fMzit6aiMmjb\n"
        }
    }
]
```

### Confirm a connection request
This endpoint is used to confirm a 'connection' request. This is initiated by the __target__ user, who decides whether or
not to approve a connection requested by another user(__origin__ user).

- Prerequisites:
  - The user must be registered
  - A connection request must have been submitted by another user (the __origin__ user)
  - Pending connections can be retrieved using the 'GET /connections?status=pending' endpoint
- Uri: /connections/{connection_id}
- Method: POST
- Headers: Authorization [auth_token]
- Sample payload:
  - digest: sha256 hashed, base64 encoded username of the connection origin user (in this case johnnymnemonic@test.com) 
  that will be signed
  - signature: the signed digest (signed using the secret key of the __target user__)
  
```
  { 
    "digest":"YTc1NWNjZmQtOTgwOS00OWFkLTg5OTAtMTAyMGM5NjAyNGM3\n",
    "signature":"MEUCIBQ87YyGpFp97iVlVez5WuUGCnTeVd4hctArzma0pOe4AiEAuIEPWnea\nd4xYHaOXPDFECZdQRXrFMEsS2oNYLsShLB8=\n",
    "status":"connected"
  }
```
  
- Result:
    - The response contains:
        - the connection id and status
        - the user type (in this case the __origin__ user)
        - the __origin__ user's details
    - The 'status' field value will be 'connected' if successful 
  
```
{
    "id": "7628aecfb85a54687c000001",
    "status": "connected",
    "user": {
        "type":"origin",
        "username": "johnnymnemonic@matrix.com",
        "first_name": "Johnny",
        "last_name": "Mnemonic"
    }
}   
```
    
## Relying Party Support
- The encrypted payload that is generated by id-io (and passed to the relying party by an intermediate client app)
can be read using a utility Ruby gem: https://rubygems.org/gems/ig-identity-rp-validator
- The gem will decrypt the payload using the shared AES key:

```
  {
    "id":"5533aecfb85a54687c000001",
    "username":"johnny_mnemonic@test.com",
    "digest":"ZTM1NDU4MmMtMzgyYi00ZmI0LWEwOTAtODM2YmEwYzIxZjQ0\n",
    "signature":"MEUCIH6v57kL9fFFJ3Gnbb3pMVw3PEUX3Pr2Ux3JdACMUj9iAiEAxPnN2Ouw\n8NMpk7w22vpabFJhuVboQ9ekUBfNWOu4Z6c=\n",
    "fingerprint":"9f6e26a098b8db4a09b843ca9b074ccb",
    "expiry_date":1429454047,
    "ip_address":"0.0.0.0"
  }
```

- The signature present in the decrypted payload is then validated using the public ECDSA key of id-io. If this validates
 true then the payload is deemed OK.

## MITM and replay attack mitigation
- Although a good degree of security can be achieved using a combination of AES encryption and ECDSA signatures to 
protect payloads, there is still the issue of man-in-the-middle (MITM) and replay attacks. Hijacking of auth payloads 
could allow an attacker to login to the relying party.
- To help mitigate this, the encrypted auth payload contains:
  - An *expiry_date* field, which is configurable on id-io and allows a short lifetime for the auth payload
  - An *ip_address* field, which represents the IP of the client.
  - A *fingerprint* field - the client fingerprint, which is included in the original login payload from the client.
    - It is up to the client application to generate the fingerprint - a library such as __fingerprint2js__ 
    can be used for this (https://github.com/Valve/fingerprintjs2).
  - The relying party can then compare the payload information with the requesting client to ensure that it is the same client. 

## Appendix

### Why blockchain?

When a user registers on ID-IO, the action of creating a record (in a NoSQL or DHT datastore) is recorded in a __blockchain transaction__.

Each blockchain transaction will hold (in addition to the default information generated by the blockchain) very small pieces of additional, critical information about the user, namely:
 
 - username
 - a public ECDSA signing key (__not__ related to the crypto wallet public key, but used by ID-IO to authenticate a user based on a signature)
 - a code representing the reason for the transaction, eg: USER_REG
 
 A permanent record is thus created on the blockchain and is highly resistant to tampering. The transaction is publicly visible and the public key
 can be used by anyone (by use of the ECDSA signature verification algorithm) to validate any signatures independently created by this user (ie: using his/her __secret__ key).
 
 The __federated authentication__ mechanism [Login with signed challenge](#login-with-signed-challenge) feature requires the use of a user's secret
 ECDSA signing key to generate a signature. This signature is sent to ID-IO and verification (and thus authentication) of the user is carried out using the public key that the user
 originally registered with (which as described above, is embedded in the blockchain transaction).

### Blockchain integration

The choice of blockchain is still in flux, with the following options:

- __Bitcoin__: The original blockchain, which allows for the storage of small pieces of information in transaction records (in our case the "master" identity record)
 - Uses "proof of work" (performed by "mining") as transaction verification mechanism
 - Strong focus on the currency itself (BTC) - a single decentralised currency on the Bitcoin network
 - Has the longest track record, and is the most widely used
 - The "proof of work" mechanism is highly energy intensive (and thus costly) and slower than some other mechanisms (such as "consensus" in Ripple)
 - An identity and DNS ownership platform that currently uses Bitcoin is __Namecoin__ 

- __Ripple__: A newer blockchain network, which also allows for the storage of small pieces of information in transaction records (in our case the "master" identity record)
  - Uses a "consensus" mechanism to verify transactions, which is faster than "proof of work" and more energy efficient
  - Strong focus on the transaction network and protocol, rather than a specific currency. Any currency can be issued and transacted (including custom currencies and Bitcoin itself), although Ripple's native currency, XRP, is required in very small amounts to perform transactions (this is to prevent DDOS-type attacks on the network)
  
- __Ethereum__: A decentralised network of computational services on a blockchain
  - Focus is on decentralised, executable code (contracts) deployed to a blockchain
  - Uses a native cryptocurrency called Ether, used to pay for these computational services
  - A relative newcomer, this offers very interesting options for ID-IO, including potentially porting the ID-IO to run on Ethereum itself
