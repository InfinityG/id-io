# id-io
Identity/registration service built on Sinatra

__PLEASE NOTE__: This code is still in alpha development. Some features are still in early development and some are still to be implemented.

## Features
- __RESTful API__
  - Supports:
    - Creation of trusts between id-io API and Relying Parties
    - Registration of user identities
    - Authentication of users
    - Connecting to other users ('friend' requests)
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
  - Blockchain: ~~NameCoin~~ Ripple [will be] used for master record of public ECDSA keys of identities
- __Webhooks__
  - Registrations on the API support a Webhook callback mechanism on successful registration

## Dependencies
- The application is written in Ruby and Sinatra DSL
- Bundler is required for managing gem dependencies - just run __bundle install__
- MongoDB is required for the local backing store
- A Docker file is included for quick deployments - note that the default deployment installs MongoDB in the same image

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
  
  ```
  {
    "id":"5533a64db85a5467eb000001"
  }
  ```
    
### Create login challenge (for signature-based login)
This endpoint is used to generate a challenge, which is must be signed for use in the subsequent login step. 

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
  - User must have created a challenge (see above step)
- Uri: /login
- Method: POST
- Headers: none
- Sample payload: 
  
  ```
  {
    "username":"johnny_mnemonic@test.com",
    "challenge":{
      "data":"YTc1NWNjZmQtOTgwOS00OWFkLTg5OTAtMTAyMGM5NjAyNGM3\n",
      "signature":"MEUCIBQ87YyGpFp97iVlVez5WuUGCnTeVd4hctArzma0pOe4AiEAuIEPWnea\nd4xYHaOXPDFECZdQRXrFMEsS2oNYLsShLB8=\n"
      },
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
    "domain":"www.testdomain.com"
  }
  ```
  
- Result:
  
  ```
  {
    "auth":"gvZWzBj7zrbTovwCDutSIv4vQVENi0HcyGvQp6yLCSUjgi2lIpgr3BUfiqzr\n3SV4HXznIzrIctgek60V0TGOaS/ZcF6Ikl5RLPSRlb5dgOA/r2fewZk5cdnA\n5C6qE+1zjko+wwiSqNCDadXGGHOEMWo/yDvR+SKjEYmoiE24yQd1mNk6EFRC\nazf1yhDHe5Hghi9x6Zl8WbwZ++KDkWdLRO43/qhOy3tr34O0KiNNX2ERH60G\nv27wiAp5nvFjXHdWHN8qlVg8oWfUe8bce7/IF6T8qPP9WCYAFuoyO9sGbrET\n9Qw08/8fnSQ3RbUW5twqhSW7XFeMXwuIwk5U3IBsiHpuKX3lKLYSqGiFzZOT\niQ1M1sF0UW3ULpKQ1KG/1Rlr7N8CS2hwapXKlri8uMKLIleEQPPoURpHrusW\nz4dXHb6/CW2QinqbbhrA0WRBAE0dWknjE/jL18CHrYDWM2vCY4S2Qk4P5rWd\nUSZlWw/UBFow6PIaJpCebTI9S3kwmA3MkVRoRKksX3ZYo+i144KKOv69LUgt\nj1+S+J+k5Qo2bSslrODg1OpY2cX3HTg+2wsChGPSB3MRS2+cjEnnhmHjq0yI\n6iD8NWaWcL/OktDWEaU=\n",
    "iv":"EHoV2Y2hEOr93QXt0c9o5w==\n"
  }
  ```

### Request a connection with another user ('friend' request)
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
  - data: the base64 encoded username that will be signed
  - signature: the signed data (signed using the secret key of the __origin user__)
  
```
  {
    "username":"mranderson", 
    "data":"YTc1NWNjZmQtOTgwOS00OWFkLTg5OTAtMTAyMGM5NjAyNGM3\n",
    "signature":"MEUCIBQ87YyGpFp97iVlVez5WuUGCnTeVd4hctArzma0pOe4AiEAuIEPWnea\nd4xYHaOXPDFECZdQRXrFMEsS2oNYLsShLB8=\n"
  }
```
  
- Result:
    - The response represents a connection
    - As this will not have been confirmed yet by the connection, the 'confirmed' field value is false
  
```
  {
    "id":"7628aecfb85a54687c000001",
    "origin_user_id":"12390aecfb85a54687c000001",
    "origin_username":"johnnymnemonic@test.com",
    "target_user_id":"80808aecfb85a54687c000001",
    "target_username":"mranderson@matrix.com", 
    "confirmed":false
  }
```

### Get connections
This endpoint retrieves all connections for a particular user.  

- Prerequisites:
  - User must be registered
- Uri: /connections?confirmed={true/false}
  - Parameters: 
      - confirmed (optional) = [true/false]
- Method: GET
- Headers: Authorization [auth_token] (this is the login token of the __origin user__)
  
- Result:
    - The response contains the a collection of connections, filtered by the 'confirmed' parameter if present 
  
```
  [
      {
          "id":"7628aecfb85a54687c000001",
          "origin_id":"12390aecfb85a54687c000001",
          "origin_username":"johnnymnemonic@test.com",
          "target_user_id":"80808aecfb85a54687c000001",
          "target_username":"mranderson@matrix.com", 
          "confirmed":true
       },
       ...
  ]
```

### Confirm a connection request ('friend' request)
This endpoint is used to confirm a 'connection' request. This is initiated by the target user, who decides whether or
not to approve a connection requested by another user.

- Prerequisites:
  - The user must be registered
  - A connection request must have been submitted by another user
  - Pending connections can be retrieved using the 'GET /connections?confirmed=false' endpoint
- Uri: /connections/{connection_id}
- Method: POST
- Headers: Authorization [auth_token]
- Sample payload:
  - data: the base64 encoded username of the connection origin user (in this case johnnymnemonic@test.com) that will be signed
  - signature: the signed data (signed using the secret key of the __target user__)
  
```
  { 
    "data":"YTc1NWNjZmQtOTgwOS00OWFkLTg5OTAtMTAyMGM5NjAyNGM3\n",
    "signature":"MEUCIBQ87YyGpFp97iVlVez5WuUGCnTeVd4hctArzma0pOe4AiEAuIEPWnea\nd4xYHaOXPDFECZdQRXrFMEsS2oNYLsShLB8=\n"
  }
```
  
- Result:
    - The response contains the newly created connected user id and username
    - The 'confirmed' field value will be true if successfully confirmed 
  
```
  {
      "id":"7628aecfb85a54687c000001",
      "origin_user_id":"12390aecfb85a54687c000001",
      "origin_username":"johnnymnemonic@test.com",
      "target_user_id":"80808aecfb85a54687c000001",
      "target_username":"mranderson@matrix.com", 
      "confirmed":true
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
    "token":"ZTM1NDU4MmMtMzgyYi00ZmI0LWEwOTAtODM2YmEwYzIxZjQ0\n",
    "signature":"MEUCIH6v57kL9fFFJ3Gnbb3pMVw3PEUX3Pr2Ux3JdACMUj9iAiEAxPnN2Ouw\n8NMpk7w22vpabFJhuVboQ9ekUBfNWOu4Z6c=\n",
    "role":"administrator",
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
  - An *ip_address* field, which represents the IP of the client. This will be expanded to try and create a more reliable
  client fingerprint.
  - The relying party can then compare the payload information with the requesting client to ensure that it is the same client. 
