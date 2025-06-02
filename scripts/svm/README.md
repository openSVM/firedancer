# SVM Development Scripts

This directory contains scripts for Solana Virtual Machine (SVM) development within the Firedancer ecosystem.

## 📁 Available Scripts

### `setup-svm-dev.sh`
Complete SVM development environment setup script.

```bash
# Run the setup script
./scripts/svm/setup-svm-dev.sh
```

**What it installs:**
- Solana CLI tools
- Anchor framework and AVM
- SPL Token CLI
- Metaboss (NFT toolkit)
- JavaScript/TypeScript libraries
- Python Solana libraries
- Development templates and examples

**Output:**
- Creates `~/solana-projects/` directory
- Generates development keypair
- Sets up example projects
- Configures Solana CLI for devnet

### `test-svm-env.sh`
Tests all SVM development tools and provides environment status.

```bash
# Test the development environment
./scripts/svm/test-svm-env.sh
```

**What it checks:**
- ✅ Tool availability and versions
- 🌐 Network connectivity to Solana RPCs
- ⚙️ Solana configuration and wallet setup
- 📂 Development environment structure
- 🔥 Firedancer integration status

### `create-svm-project.sh`
Interactive project template generator for various SVM project types.

```bash
# Create new SVM projects
./scripts/svm/create-svm-project.sh
```

**Available templates:**
1. **Anchor Program**: Full Rust + TypeScript framework
2. **Next.js dApp**: React-based web application
3. **Seahorse Program**: Python-based Solana program
4. **Native Rust Program**: Low-level Solana program
5. **All Examples**: Creates all template types

## 🚀 Quick Start Workflow

### 1. Setup Development Environment
```bash
# Install all SVM development tools
./scripts/svm/setup-svm-dev.sh

# Verify installation
./scripts/svm/test-svm-env.sh
```

### 2. Create Your First Project
```bash
# Interactive project creation
./scripts/svm/create-svm-project.sh

# Or use specific templates
cd ~/solana-projects
anchor init my-program              # Anchor program
npx create-solana-dapp my-dapp      # Next.js dApp
seahorse init my-python-program     # Python program
```

### 3. Development Cycle
```bash
# For Anchor programs
cd ~/solana-projects/my-program
anchor build                        # Build program
anchor test                         # Run tests
anchor deploy                       # Deploy to cluster

# For dApps
cd ~/solana-projects/my-dapp
npm install                         # Install dependencies
npm run dev                         # Start development server

# For Seahorse programs
cd ~/solana-projects/my-python-program
seahorse build                      # Build Python to Rust
anchor test                         # Test the program
```

## 🔧 Integration with Firedancer

### Running with Firedancer Validator
```bash
# Build Firedancer
make -j$(nproc) fdctl

# Configure for development
./build/native/gcc/bin/fdctl configure init all --config dev-config.toml

# Run Firedancer validator
./build/native/gcc/bin/fdctl run --config dev-config.toml

# In another terminal, deploy your programs
solana config set --url http://localhost:8899
anchor deploy --provider.cluster localnet
```

### Development Configuration
The scripts automatically configure:
- **Solana CLI**: Points to devnet by default
- **Anchor**: Configured for local development
- **Wallet**: Development keypair in `~/.config/solana/id.json`
- **RPC URLs**: Pre-configured for all networks

## 📚 Documentation and Examples

### Learning Resources
- **`doc/SVM_DEVELOPMENT_TOOLS.md`**: Comprehensive tool documentation
- **`~/solana-projects/quick-start.sh`**: Quick command reference
- **Example projects**: Fully documented templates in `~/solana-projects/`

### Code Examples

**Anchor Program Structure:**
```
my-program/
├── Anchor.toml              # Anchor configuration
├── Cargo.toml              # Rust dependencies
├── programs/               # Solana programs
│   └── my-program/
│       └── src/lib.rs      # Program logic
├── tests/                  # TypeScript tests
│   └── my-program.ts
└── target/                 # Build output
```

**Next.js dApp Structure:**
```
my-dapp/
├── src/
│   ├── components/         # React components
│   ├── pages/             # Next.js pages
│   └── utils/             # Utility functions
├── public/                # Static assets
└── package.json           # Dependencies
```

## 🛠️ Advanced Usage

### Custom Tool Installation
```bash
# Source the configuration
source .devcontainer/svm-tools.conf

# Install additional tools
cargo install your-tool
npm install -g your-package
pip3 install your-python-package
```

### Network Switching
```bash
# Switch to different networks
solana config set --url devnet      # Development
solana config set --url testnet     # Testing
solana config set --url mainnet     # Production
solana config set --url localhost   # Local validator
```

### Advanced Testing
```bash
# Local validator with custom settings
solana-test-validator \
  --mint 9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM \
  --clone 9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM \
  --url devnet \
  --reset

# Test with Amman
cd my-program && amman start && anchor test
```

## 🔍 Troubleshooting

### Common Issues

**Tool Not Found:**
```bash
# Re-source environment
source ~/.bashrc
source ~/.cargo/env

# Re-run setup
./scripts/svm/setup-svm-dev.sh
```

**Build Failures:**
```bash
# Update Rust toolchain
rustup update

# Clear caches
anchor clean
cargo clean
rm -rf node_modules && npm install
```

**Network Connection Issues:**
```bash
# Test RPC connection
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"getHealth"}' \
  https://api.devnet.solana.com

# Reset Solana config
rm -rf ~/.config/solana
solana-keygen new
```

## 📈 Performance Tips

### Development Optimizations
- Use `anchor build --verifiable` for reproducible builds
- Enable `skipPreflight: true` for faster testing
- Use local validator for rapid iteration
- Cache dependencies with `anchor.toml` configurations

### Production Considerations
- Test on devnet before testnet deployment
- Use `anchor verify` for program verification
- Implement proper error handling and logging
- Monitor transaction costs and optimize

## 🤝 Contributing

To add new SVM development tools:

1. Update `.devcontainer/svm-tools.conf` with new tools
2. Add installation logic to `setup-svm-dev.sh`
3. Add testing logic to `test-svm-env.sh`
4. Update documentation in `doc/SVM_DEVELOPMENT_TOOLS.md`
5. Add project templates to `create-svm-project.sh` if applicable

## 📞 Support

- **Documentation**: `cat doc/SVM_DEVELOPMENT_TOOLS.md`
- **Test Environment**: `./scripts/svm/test-svm-env.sh`
- **Solana Discord**: https://discord.com/invite/solana
- **Anchor Discord**: https://discord.gg/ZCHmqvXgDw
- **Firedancer GitHub**: https://github.com/firedancer-io/firedancer

---

*These scripts provide a complete SVM development environment optimized for Firedancer integration and Solana ecosystem development.*