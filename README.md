# id-io
Identity/registration service built on Sinatra

__PLEASE NOTE__: This code is still in a Beta development phase. Some features are still in early development and some are still to be implemented.

## Features
- __RESTful API__
  - Supports:
    - Creation of trusts between id-io API and Relying Parties
    - Registration of user identities
    - Authentication of users
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
  - Blockchain: NameCoin [will be] used for master record of public ECDSA keys of identities
- __Webhooks__
  - Registrations on the API support a Webhook callback mechanism on successful registration

## API documentation
 - __COMING SOON!__
 
## Relying Party Support
- The encrypted payload that is generated by id-io (and passed to the relying party by an intermediate client app) \n
can be read using a utility gem called __ig-identity-rp-validator__ (just add a gem dependency to your project).
- Usage details [TODO]