AKASH_NET := https://raw.githubusercontent.com/ovrclk/net/master/mainnet
AKASH_VERSION=$(shell curl -s "$(AKASH_NET)/version.txt")
AKASH_NODE=$(shell curl -s "$(AKASH_NET)/rpc-nodes.txt" | sort -R | head -1)
AKASH_CHAIN_ID=$(shell curl -s "$(AKASH_NET)/chain-id.txt")

# Local akash installation
#DEPLOY_ROOT := $(shell pwd)
#AKASH_BIN := akash

# Docker akash installation
DEPLOY_ROOT := /root/deploy
AKASH_BIN := docker run -it -v $(shell pwd):$(DEPLOY_ROOT) --rm ghcr.io/ovrclk/akash:$(AKASH_VERSION) akash

KEY_NAME := deploy
KEYRING_OPT := --keyring-backend "file" --home "$(DEPLOY_ROOT)/akash"

FEES := 5000uakt

OSEQ := 1
GSEQ := 1

info:
	$(AKASH_BIN) status --node "$(AKASH_NODE)"

address:
	$(AKASH_BIN) keys show $(KEY_NAME) $(KEYRING_OPT) -a

events:
	$(AKASH_BIN) events --node "$(AKASH_NODE)"

create_wallet:
	$(AKASH_BIN) keys add "$(KEY_NAME)" ${KEYRING_OPT}

recover_wallet:
	$(AKASH_BIN) keys add "$(KEY_NAME)" --recover ${KEYRING_OPT}

balance:
	@test $${AKASH_ADDRESS?Please set environment variable AKASH_ADDRESS}
	$(AKASH_BIN) query bank balances "$(AKASH_ADDRESS)" --node "$(AKASH_NODE)"

create_certificate:
	$(AKASH_BIN) tx cert create client --chain-id=$(AKASH_CHAIN_ID) --from=$(KEY_NAME) --node=$(AKASH_NODE) --fees=$(FEES) ${KEYRING_OPT}

revoke_certificate:
	$(AKASH_BIN) tx cert revoke --chain-id=$(AKASH_CHAIN_ID) --from=$(KEY_NAME) --node=$(AKASH_NODE) --fees=$(FEES) ${KEYRING_OPT}

create_deployment:
	$(AKASH_BIN) tx deployment create $(DEPLOY_ROOT)/deploy.yml --from $(KEY_NAME) --node $(AKASH_NODE) --chain-id $(AKASH_CHAIN_ID) --fees $(FEES) ${KEYRING_OPT}

update_deployment:
	$(AKASH_BIN) tx deployment update $(DEPLOY_ROOT)/deploy.yml --from $(KEY_NAME) --node $(AKASH_NODE) --chain-id $(AKASH_CHAIN_ID) --fees $(FEES) ${KEYRING_OPT} --dseq ${DSEQ}

close_deployment:
	$(AKASH_BIN) tx deployment close --from $(KEY_NAME) --node $(AKASH_NODE) --chain-id $(AKASH_CHAIN_ID) --fees $(FEES) ${KEYRING_OPT} --dseq ${DSEQ} --gas=auto

list_bid:
	@test $${AKASH_ADDRESS?Please set environment variable AKASH_ADDRESS}
	$(AKASH_BIN) query market bid list --owner $(AKASH_ADDRESS) --chain-id $(AKASH_CHAIN_ID) --node $(AKASH_NODE)

create_lease:
	@test $${AKASH_ADDRESS?Please set environment variable AKASH_ADDRESS}
	$(AKASH_BIN) tx market lease create --from $(KEY_NAME) --owner $(AKASH_ADDRESS) --chain-id $(AKASH_CHAIN_ID) --node $(AKASH_NODE) --dseq $(DSEQ) --oseq $(OSEQ) --gseq $(GSEQ) --provider $(PROVIDER) --fees=$(FEES) $(KEYRING_OPT)

list_lease:
	@test $${AKASH_ADDRESS?Please set environment variable AKASH_ADDRESS}
	$(AKASH_BIN) query market lease list --owner $(AKASH_ADDRESS) --chain-id $(AKASH_CHAIN_ID) --node $(AKASH_NODE)

get_lease:
	@test $${AKASH_ADDRESS?Please set environment variable AKASH_ADDRESS}
	$(AKASH_BIN) query market lease get --owner $(AKASH_ADDRESS) --dseq $(DSEQ) --oseq $(OSEQ) --gseq $(GSEQ) --provider $(PROVIDER) --chain-id $(AKASH_CHAIN_ID) --node $(AKASH_NODE)

lease_status:
	$(AKASH_BIN) provider lease-status --node $(AKASH_NODE) --from $(KEY_NAME) --dseq $(DSEQ) --oseq $(OSEQ) --gseq $(GSEQ) --provider $(PROVIDER) ${KEYRING_OPT}

send_manifest:
	$(AKASH_BIN) provider send-manifest $(DEPLOY_ROOT)/deploy.yml --node $(AKASH_NODE) --dseq $(DSEQ)  --from $(KEY_NAME) --provider $(PROVIDER) $(KEYRING_OPT)
