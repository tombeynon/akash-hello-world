# Akash Hello World

Example: http://22d57uuq1lbef9vgj04afiduvk.ingress.ewr1p0.mainnet.akashian.io/

This is an example of how to run a simple HTML/CSS/JS site on Akash. I wrote this to document the process for myself and it's my first time working with Akash, so please treat accordingly. 

Make sure you've read the [Akash docs](https://docs.akash.network/) first and use this as a working example. The included Makefile simplifies the process but you should have a look at it and understand what it's doing. 

Some issues I'm aware of:

- We don't verify the host with signedBy. I wasn't sure what to use here as the docs had testnet addresses
- Fees are probably set too high (5000 uakt / 0.005 akt) but I kept getting timeouts

I'll update this repo as I learn more.

## Setup

### Installation

The included Makefile defaults to using the Akash CLI in a docker container rather than a version on your machine. I did this because the CLI version should match the Akash version and the Homebrew version was outdated when I wrote this. Generally it's an easier way to pin the version and ensure it works on any machine, but note the comments at the top of the Makefile to change this.

All you should need to run this is `make` and `docker`. 

### Akash wallet

I setup a dedicated deploy wallet so have included instructions to do this. BE WARY of this, if you lose the private key you won't be able to access your deployment or funds. Particularly because the Akash binary runs in docker here, verify you have the private key/mneumonic safe.

We use `file` storage so an `akash` directory will be added to the project root with keys etc.

```
make create_wallet
# enter and confirm a passphrase to protect the private key

ls ./akash 
# verify the akash directory exists locally (and not just in the docker container)
```

We can then grab the account address, set the AKASH_ADDRESS env variable, and check our balance.

```
make address # copy the returned address
export AKASH_ADDRESS=**address**

make balance # should be empty
```

You should now fund the above address with at least 5.1 AKT. When you create a deployment, 5 AKT is added to escrow. Once you've sent your AKT, you can check your balance to confirm as above.

## Deployment

### Build and host the Docker image

The first thing you'll need to deploy on Akash is a docker image. This step will build a docker image from the Dockerfile and push it to Docker Hub. 

You can skip this if you already have a docker image you want to run on Akash. You can also fork this repo and setup Docker Hub to automatically build from GitHub.

Note Akash needs a public repository for now.

```
# Change below to your user/repo

docker build . -t tombeynon/akash-hello-world 
docker push tombeynon/akash-hello-world:latest
```

You can now update deploy.yml to use your user/repo.

### Deploying to Akash

First we need to create a deploy certificate. This will be used to send your deploy config to the provider later.

```
make create_certificate
```

Once your certificate has been created and stored on the Akash blockchain, we can create the deployment.

```
make create_deployment
```

Note the `dseq` value in the output. We will need this in the next steps.

Our deployment has now been created on the blockchain, and assuming everything is configured correctly, we should now get some bids from providers who want to host this deployment.

```
make list_bid
```

You should see a list of bids. I just use the last one in the list. Make sure the `dseq` value matches the one from our create_deployment.

We need the `provider` value from the bid you've chosen to create a lease with this provider.

```
make create_lease PROVIDER=**provider** DSEQ=**dseq**

make list_lease # to check your current leases
```

We have a lease! The final step is to upload our deploy.yml to the provider. This transparently uses the certificate we created at the start.

```
make send_manifest PROVIDER=**provider** DSEQ=**dseq**
# No output for me but it did work..
```

If all went well, you should have a hosted website! You can query for your hostname using lease_status

```
make lease_status PROVIDER=**provider** DSEQ=**dseq**
```

You should see a list of `uris` - the one and only value will be your website!
