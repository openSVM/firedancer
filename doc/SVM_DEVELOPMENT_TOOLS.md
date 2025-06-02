# SVM Development Tools for Firedancer

This document provides a comprehensive guide to Solana Virtual Machine (SVM) development tools available in the Firedancer development environment. These tools are automatically installed in the DevContainer and enable full-stack SVM application development.

## 🔧 Core Development Tools

### Solana CLI
The official Solana command-line tool for blockchain interaction.

```bash
# Check version
solana --version

# Connect to different clusters
solana config set --url https://api.mainnet-beta.solana.com    # Mainnet
solana config set --url https://api.devnet.solana.com         # Devnet
solana config set --url https://api.testnet.solana.com        # Testnet
solana config set --url http://localhost:8899                 # Local

# Generate keypairs
solana-keygen new --outfile ~/my-wallet.json
solana config set --keypair ~/my-wallet.json

# Get wallet info
solana address
solana balance
```

### Anchor Framework
Rust-based framework for Solana program development.

```bash
# Check installation
anchor --version

# Create new project
anchor init my-solana-program
cd my-solana-program

# Build program
anchor build

# Test program
anchor test

# Deploy program
anchor deploy
```

**Key Features:**
- IDL (Interface Definition Language) generation
- TypeScript client generation
- Integrated testing framework
- Account validation and serialization

## 🚀 Quick Start Tools

### Create Solana dApp
Scaffold for rapid dApp development with multiple framework options.

```bash
# Create new dApp with Next.js
npx create-solana-dapp my-dapp

# Available templates:
# - Next.js + React
# - React only
# - Vue.js
# - React Native (mobile)
```

### Seahorse (Python Framework)
Write Solana programs in Python instead of Rust.

```bash
# Install Seahorse
pip install seahorse-lang

# Create new project
seahorse init my-python-program
cd my-python-program

# Build program
seahorse build

# Example Python program:
cat > programs/my-python-program/src/main.py << 'EOF'
from seahorse.prelude import *

declare_id('11111111111111111111111111111112')

@instruction
def initialize(signer: Signer, new_account: Empty[MyAccount]):
    new_account.init(payer=signer, seeds=['my-account', signer])

@account
class MyAccount:
    value: u64
EOF
```

## 🧪 Testing and Development

### Amman (Local Test Environment)
Comprehensive testing framework for Solana programs.

```bash
# Start local validator with custom configuration
amman start

# Run tests with Amman
amman test

# Configuration file (amman.js):
cat > amman.js << 'EOF'
module.exports = {
  validator: {
    killRunningValidators: true,
    programs: [
      {
        label: 'My Program',
        programId: 'YourProgramId',
        deployPath: './target/deploy/my_program.so'
      }
    ],
    accounts: [
      {
        label: 'Test Account',
        accountId: 'TestAccountPubkey',
        executable: false,
        data: 'base64-encoded-data'
      }
    ]
  }
}
EOF
```

### Mollusk SVM Test Harness
Lightweight SVM testing framework for Solana programs.

```rust
// Example test with Mollusk
use mollusk_svm::Mollusk;

#[test]
fn test_my_program() {
    let mollusk = Mollusk::new(&my_program::id(), "my_program");

    let instruction = Instruction {
        program_id: my_program::id(),
        accounts: vec![
            AccountMeta::new(user_pubkey, true),
            AccountMeta::new(data_account, false),
        ],
        data: my_program::instruction::Initialize {}.data(),
    };

    let result = mollusk.process_instruction(&instruction, &accounts);
    assert!(result.program_result.is_ok());
}
```

## 🔍 Development and Debugging Tools

### Metaboss (NFT Swiss Army Knife)
Comprehensive tool for NFT operations and metadata management.

```bash
# Check installation
metaboss --version

# Create NFT collection
metaboss create collection \
  --name "My Collection" \
  --symbol "MC" \
  --uri "https://example.com/metadata.json" \
  --keypair ~/wallet.json

# Mint NFT
metaboss mint one \
  --collection <collection-mint> \
  --metadata-uri "https://example.com/nft-metadata.json" \
  --keypair ~/wallet.json

# Update metadata
metaboss update uri \
  --account <nft-mint> \
  --new-uri "https://example.com/updated-metadata.json" \
  --keypair ~/wallet.json
```

### SPL Token CLI
Tools for SPL token operations.

```bash
# Create new token
spl-token create-token --keypair ~/wallet.json

# Create token account
spl-token create-account <token-mint> --keypair ~/wallet.json

# Mint tokens
spl-token mint <token-mint> 1000 <token-account> --keypair ~/wallet.json

# Transfer tokens
spl-token transfer <token-mint> 100 <recipient-address> --keypair ~/wallet.json
```

## 📚 Client Libraries and SDKs

### Solana Web3.js (JavaScript/TypeScript)
```javascript
import { Connection, PublicKey, clusterApiUrl } from '@solana/web3.js';

const connection = new Connection(clusterApiUrl('devnet'));
const wallet = new PublicKey('YourWalletAddress');

// Get balance
const balance = await connection.getBalance(wallet);
console.log(`Balance: ${balance / 1e9} SOL`);

// Get recent transactions
const transactions = await connection.getSignaturesForAddress(wallet);
```

### Solathon (Python)
```python
from solathon import Client, Keypair

# Connect to Solana
client = Client("https://api.devnet.solana.com")

# Create keypair
keypair = Keypair()

# Get balance
balance = client.get_balance(keypair.public_key)
print(f"Balance: {balance} lamports")
```

### AnchorPy (Python)
```python
from anchorpy import Provider, Wallet, Program

# Load program
provider = Provider.local()
program = Program.load("./target/idl/my_program.json", provider)

# Call instruction
result = await program.rpc.initialize(
    ctx=Context(accounts={
        "user": provider.wallet.public_key,
        "system_program": SYS_PROGRAM_ID,
    })
)
```

## 🔄 Cross-Chain and Advanced Tools

### Wormhole SDK
For cross-chain functionality with other blockchains.

```bash
# Install Wormhole SDK
npm install @certusone/wormhole-sdk

# Example bridge transaction
import { getEmitterAddressEth, parseSequenceFromLogEth } from "@certusone/wormhole-sdk";
```

### Chainlink CCIP
Cross-Chain Interoperability Protocol for Solana.

```bash
# Install Chainlink dependencies
npm install @chainlink/contracts
```

## 🛠️ Specialized Development Tools

### SolSync
Tool for syncing off-chain data with on-chain applications.

```bash
# Install SolSync
cargo install solsync

# Configuration
solsync init
solsync sync --config solsync.toml
```

### Nonci
Durable nonce transaction queueing and execution.

```bash
# Install Nonci SDK
npm install @nonci/sdk

# Example usage
import { NonciClient } from '@nonci/sdk';
const client = new NonciClient('https://api.nonci.xyz');
```

### EventSnap
Infrastructure-less on-chain event tracking.

```rust
use event_snap::EventListener;

let listener = EventListener::new(program_id)
    .on_event("MyEvent", |event| {
        println!("Received event: {:?}", event);
    })
    .start()
    .await;
```

## 🎮 Gaming and NFT Tools

### Solana Unity SDK
```csharp
using Solana.Unity.SDK;

public class SolanaManager : MonoBehaviour
{
    void Start()
    {
        Web3.Instance.Initialize(RpcCluster.DevNet);
    }

    async void GetBalance()
    {
        var balance = await Web3.Instance.WalletBase.GetBalance();
        Debug.Log($"Balance: {balance} SOL");
    }
}
```

### Gamba (On-Chain Gaming)
```typescript
import { GambaProvider, useGamba } from 'gamba-react';

function GameComponent() {
    const gamba = useGamba();

    const playGame = async () => {
        const result = await gamba.play([50, 0, 200], 1000000); // 1 SOL bet
        console.log('Game result:', result);
    };
}
```

## 🔐 Security and Privacy Tools

### Elusiv SDK (zk-Privacy)
```typescript
import { Elusiv, ClusterExtended } from '@elusiv/sdk';

const elusiv = await Elusiv.getElusivInstance(
    'devnet' as ClusterExtended,
    wallet,
    connection
);

// Private transfer
await elusiv.buildSendTx(
    1000000, // 0.001 SOL
    recipientAddress,
    'SOL'
);
```

### SolCerberus (Role-Based Access)
```rust
use solcerberus::Roles;

#[account]
pub struct MyAccount {
    pub roles: Roles,
    pub data: String,
}

// Check permissions
require!(
    ctx.accounts.my_account.roles.has_role(&Role::Admin),
    ErrorCode::Unauthorized
);
```

## 📊 Analytics and Monitoring

### Solana Transaction Explorer Tools
```bash
# Install Xray explorer locally
git clone https://github.com/helius-labs/xray
cd xray && npm install && npm run dev
```

### Custom RPC Endpoints
```javascript
// QuickNode
const connection = new Connection('https://your-quicknode-endpoint.solana-mainnet.quiknode.pro/');

// Helius
const connection = new Connection('https://mainnet.helius-rpc.com/?api-key=your-api-key');

// Chainstack
const connection = new Connection('https://solana-mainnet.core.chainstack.com/your-api-key');
```

## 🚀 Production Deployment

### Environment Configuration
```bash
# Development
export SOLANA_ENV=development
export RPC_URL=http://localhost:8899

# Testing
export SOLANA_ENV=devnet
export RPC_URL=https://api.devnet.solana.com

# Production
export SOLANA_ENV=mainnet
export RPC_URL=https://api.mainnet-beta.solana.com
```

### CI/CD with SolStromm
```yaml
# .github/workflows/solana-deploy.yml
name: Deploy Solana Program
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy with SolStromm
        uses: solstromm/action@v1
        with:
          program: ./target/deploy/my_program.so
          keypair: ${{ secrets.SOLANA_KEYPAIR }}
          cluster: mainnet
```

## 🤝 Community Tools and Resources

### Scaffold Templates
```bash
# Next.js + Anchor
npx create-solana-dapp my-app --template nextjs-anchor

# React + TypeScript
npx create-solana-dapp my-app --template react-typescript

# Mobile (React Native)
npx create-solana-dapp my-app --template react-native
```

### Development Environment Scripts
```bash
# Quick development setup
./scripts/dev-setup.sh

# Run local test suite
./scripts/test-all.sh

# Deploy to testnet
./scripts/deploy-testnet.sh
```

## 📖 Learning Resources

### Official Documentation
- [Solana Docs](https://docs.solana.com/)
- [Anchor Book](https://book.anchor-lang.com/)
- [SPL Token Program](https://spl.solana.com/token)

### Community Resources
- [Solana Cookbook](https://solanacookbook.com/)
- [Solana Stack Exchange](https://solana.stackexchange.com/)
- [Awesome Solana](https://github.com/paul-schaaf/awesome-solana)

### Interactive Tutorials
- [Solana Bootcamp](https://github.com/solana-labs/solana-bootcamp)
- [Web3 Builders Alliance](https://github.com/Web3-Builders-Alliance)
- [Buildspace Solana](https://buildspace.so/solana)

## 🔧 Troubleshooting

### Common Issues

**Anchor Build Failures:**
```bash
# Clear cache
anchor clean && anchor build

# Update Rust toolchain
rustup update
```

**RPC Connection Issues:**
```bash
# Test connection
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"getHealth"}' \
  https://api.devnet.solana.com
```

**Transaction Simulation Failures:**
```javascript
// Add simulation before sending
const simulation = await connection.simulateTransaction(transaction);
if (simulation.value.err) {
    console.error('Simulation failed:', simulation.value.err);
}
```

## 🎯 Next Steps

1. **Start with Anchor**: Begin with the Anchor framework for structured program development
2. **Use Scaffolds**: Leverage create-solana-dapp for rapid prototyping
3. **Test Locally**: Use Amman for comprehensive local testing
4. **Deploy Incrementally**: Start with devnet, then testnet, finally mainnet
5. **Monitor Performance**: Implement proper monitoring and error handling
6. **Engage Community**: Join Solana Discord and Stack Exchange for support

---

*This toolset provides everything needed for comprehensive SVM development on Firedancer. All tools are pre-installed in the DevContainer for immediate use.*