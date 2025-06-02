#!/bin/bash
# SVM Project Template Generator
# Creates various types of Solana/SVM projects with best practices

set -e

echo "🏗️  SVM Project Template Generator"
echo "=================================="

# Function to create Anchor program template
create_anchor_program() {
    local name="$1"
    echo "Creating Anchor program: $name"

    anchor init "$name"
    cd "$name"

    # Enhanced program template
    cat > programs/"$name"/src/lib.rs << EOF
use anchor_lang::prelude::*;

declare_id!("11111111111111111111111111111112");

#[program]
pub mod $name {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>, data: u64) -> Result<()> {
        let my_account = &mut ctx.accounts.my_account;
        my_account.data = data;
        my_account.authority = ctx.accounts.user.key();
        msg!("Initialized account with data: {}", data);
        Ok(())
    }

    pub fn update(ctx: Context<Update>, new_data: u64) -> Result<()> {
        let my_account = &mut ctx.accounts.my_account;
        my_account.data = new_data;
        msg!("Updated account data to: {}", new_data);
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(
        init,
        payer = user,
        space = 8 + MyAccount::LEN,
        seeds = [b"my-account", user.key().as_ref()],
        bump
    )]
    pub my_account: Account<'info, MyAccount>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Update<'info> {
    #[account(
        mut,
        seeds = [b"my-account", authority.key().as_ref()],
        bump,
        has_one = authority
    )]
    pub my_account: Account<'info, MyAccount>,
    pub authority: Signer<'info>,
}

#[account]
pub struct MyAccount {
    pub data: u64,
    pub authority: Pubkey,
}

impl MyAccount {
    pub const LEN: usize = 8 + 32; // discriminator + data + authority
}

#[error_code]
pub enum ErrorCode {
    #[msg("Custom error message")]
    CustomError,
}
EOF

    # Enhanced test template
    cat > tests/"$name".ts << EOF
import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { $name } from "../target/types/${name}";
import { expect } from "chai";

describe("$name", () => {
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.$name as Program<$name>;
  const user = provider.wallet as anchor.Wallet;

  let myAccountPda: anchor.web3.PublicKey;
  let bump: number;

  before(async () => {
    [myAccountPda, bump] = anchor.web3.PublicKey.findProgramAddressSync(
      [Buffer.from("my-account"), user.publicKey.toBuffer()],
      program.programId
    );
  });

  it("Initializes account", async () => {
    const testData = new anchor.BN(42);

    await program.methods
      .initialize(testData)
      .accounts({
        myAccount: myAccountPda,
        user: user.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .rpc();

    const account = await program.account.myAccount.fetch(myAccountPda);
    expect(account.data.toString()).to.equal(testData.toString());
    expect(account.authority.toString()).to.equal(user.publicKey.toString());
  });

  it("Updates account data", async () => {
    const newData = new anchor.BN(100);

    await program.methods
      .update(newData)
      .accounts({
        myAccount: myAccountPda,
        authority: user.publicKey,
      })
      .rpc();

    const account = await program.account.myAccount.fetch(myAccountPda);
    expect(account.data.toString()).to.equal(newData.toString());
  });
});
EOF

    echo "✅ Created Anchor program with enhanced templates"
    cd ..
}

# Function to create Next.js dApp template
create_nextjs_dapp() {
    local name="$1"
    echo "Creating Next.js dApp: $name"

    npx create-solana-dapp "$name" --template nextjs
    cd "$name"

    # Add enhanced components
    mkdir -p src/components/ui

    cat > src/components/ui/WalletButton.tsx << EOF
import { useWallet } from '@solana/wallet-adapter-react';
import { WalletMultiButton } from '@solana/wallet-adapter-react-ui';

export function WalletButton() {
  const { publicKey, connected } = useWallet();

  return (
    <div className="flex flex-col items-center space-y-2">
      <WalletMultiButton />
      {connected && publicKey && (
        <p className="text-sm text-gray-600">
          Connected: {publicKey.toString().slice(0, 8)}...
        </p>
      )}
    </div>
  );
}
EOF

    echo "✅ Created Next.js dApp with enhanced components"
    cd ..
}

# Function to create Python Seahorse program
create_seahorse_program() {
    local name="$1"
    echo "Creating Seahorse (Python) program: $name"

    seahorse init "$name"
    cd "$name"

    # Enhanced Python program
    cat > programs/"$name"/src/main.py << EOF
from seahorse.prelude import *

declare_id('11111111111111111111111111111112')

class MyAccount(Account):
    data: u64
    authority: Pubkey

@instruction
def initialize(signer: Signer, my_account: Empty[MyAccount], data: u64):
    """Initialize a new account with data"""
    my_account.init(
        payer=signer,
        seeds=['my-account', signer]
    )

    my_account.data = data
    my_account.authority = signer.key()

    print(f'Initialized account with data: {data}')

@instruction
def update(authority: Signer, my_account: MyAccount, new_data: u64):
    """Update account data"""
    assert my_account.authority == authority.key(), "Unauthorized"

    old_data = my_account.data
    my_account.data = new_data

    print(f'Updated data from {old_data} to {new_data}')

@instruction
def get_data(my_account: MyAccount) -> u64:
    """Get current account data"""
    return my_account.data
EOF

    echo "✅ Created Seahorse program with enhanced templates"
    cd ..
}

# Function to create Rust native program
create_native_program() {
    local name="$1"
    echo "Creating native Rust program: $name"

    cargo new --lib "$name"
    cd "$name"

    # Add Solana dependencies
    cat > Cargo.toml << EOF
[package]
name = "$name"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["cdylib", "lib"]

[dependencies]
solana-program = "~1.18"
borsh = "0.10"
thiserror = "1.0"

[dev-dependencies]
solana-program-test = "~1.18"
solana-sdk = "~1.18"
tokio = { version = "1.0", features = ["macros"] }
EOF

    # Enhanced native program
    cat > src/lib.rs << EOF
use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
    rent::Rent,
    system_instruction,
    sysvar::Sysvar,
};

// Program entrypoint
entrypoint!(process_instruction);

// Instruction data
#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub enum MyInstruction {
    Initialize { data: u64 },
    Update { new_data: u64 },
}

// Account data
#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub struct MyAccount {
    pub data: u64,
    pub authority: Pubkey,
}

impl MyAccount {
    pub const LEN: usize = 8 + 32; // data + authority
}

// Process instruction
pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = MyInstruction::try_from_slice(instruction_data)?;

    match instruction {
        MyInstruction::Initialize { data } => {
            process_initialize(program_id, accounts, data)
        }
        MyInstruction::Update { new_data } => {
            process_update(program_id, accounts, new_data)
        }
    }
}

fn process_initialize(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    data: u64,
) -> ProgramResult {
    let account_info_iter = &mut accounts.iter();
    let my_account = next_account_info(account_info_iter)?;
    let authority = next_account_info(account_info_iter)?;
    let system_program = next_account_info(account_info_iter)?;

    // Create account
    let rent = Rent::get()?;
    let space = MyAccount::LEN;
    let lamports = rent.minimum_balance(space);

    solana_program::program::invoke(
        &system_instruction::create_account(
            authority.key,
            my_account.key,
            lamports,
            space as u64,
            program_id,
        ),
        &[authority.clone(), my_account.clone(), system_program.clone()],
    )?;

    // Initialize data
    let account_data = MyAccount {
        data,
        authority: *authority.key,
    };

    account_data.serialize(&mut &mut my_account.data.borrow_mut()[..])?;

    msg!("Initialized account with data: {}", data);
    Ok(())
}

fn process_update(
    _program_id: &Pubkey,
    accounts: &[AccountInfo],
    new_data: u64,
) -> ProgramResult {
    let account_info_iter = &mut accounts.iter();
    let my_account = next_account_info(account_info_iter)?;
    let authority = next_account_info(account_info_iter)?;

    if !authority.is_signer {
        return Err(ProgramError::MissingRequiredSignature);
    }

    let mut account_data = MyAccount::try_from_slice(&my_account.data.borrow())?;

    if account_data.authority != *authority.key {
        return Err(ProgramError::InvalidAccountData);
    }

    account_data.data = new_data;
    account_data.serialize(&mut &mut my_account.data.borrow_mut()[..])?;

    msg!("Updated account data to: {}", new_data);
    Ok(())
}
EOF

    echo "✅ Created native Rust program with enhanced templates"
    cd ..
}

# Main menu
echo ""
echo "Select project type to create:"
echo "1) Anchor Program (Rust + TypeScript)"
echo "2) Next.js dApp (TypeScript + React)"
echo "3) Seahorse Program (Python)"
echo "4) Native Rust Program"
echo "5) All examples"
echo ""

read -p "Enter choice (1-5): " choice
read -p "Enter project name: " project_name

# Create projects directory if it doesn't exist
mkdir -p ~/solana-projects
cd ~/solana-projects

case $choice in
    1)
        create_anchor_program "$project_name"
        ;;
    2)
        create_nextjs_dapp "$project_name"
        ;;
    3)
        create_seahorse_program "$project_name"
        ;;
    4)
        create_native_program "$project_name"
        ;;
    5)
        echo "Creating all example projects..."
        create_anchor_program "${project_name}-anchor"
        create_nextjs_dapp "${project_name}-dapp"
        create_seahorse_program "${project_name}-seahorse"
        create_native_program "${project_name}-native"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "✅ Project(s) created successfully in ~/solana-projects/"
echo ""
echo "🚀 Next steps:"
echo "  cd ~/solana-projects/$project_name"
echo "  # For Anchor projects: anchor build && anchor test"
echo "  # For dApps: npm install && npm run dev"
echo "  # For Seahorse: seahorse build"
echo "  # For native Rust: cargo build-bpf"
echo ""
echo "📚 Documentation: cat ../doc/SVM_DEVELOPMENT_TOOLS.md"