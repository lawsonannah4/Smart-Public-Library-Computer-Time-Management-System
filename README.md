# Smart Public Library Computer Time Management System

A comprehensive blockchain-based system for managing public library computer access, built on the Stacks blockchain using Clarity smart contracts.

## System Overview

This system provides complete computer time management for public libraries through five interconnected smart contracts:

### 1. Session Booking Contract (`session-booking.clar`)
- Manages hourly computer reservations for library patrons
- Handles booking conflicts and availability checking
- Tracks patron information and session details
- Supports advance reservations up to 7 days

### 2. Time Limit Enforcement Contract (`time-enforcement.clar`)
- Automatically tracks active sessions and time remaining
- Enforces maximum session durations (default 2 hours)
- Provides warnings before session expiration
- Manages session extensions and renewals

### 3. Technical Support Contract (`tech-support.clar`)
- Tracks technical issues and support requests
- Manages support ticket lifecycle
- Records resolution times and common problems
- Provides self-help resources and troubleshooting guides

### 4. Printing Management Contract (`printing-management.clar`)
- Handles document printing fees and quotas
- Tracks paper usage and supply levels
- Manages print job queues and priorities
- Calculates costs for different print types (B&W, color, etc.)

### 5. Usage Analytics Contract (`usage-analytics.clar`)
- Tracks computer utilization patterns
- Records peak usage times and popular applications
- Generates capacity planning reports
- Monitors system performance metrics

## Key Features

- **Decentralized Management**: All data stored on blockchain for transparency
- **Real-time Tracking**: Live session monitoring and resource allocation
- **Cost Management**: Automated fee calculation for printing services
- **Analytics Dashboard**: Comprehensive usage statistics and reporting
- **Conflict Resolution**: Automatic handling of booking conflicts
- **Resource Optimization**: Smart allocation based on usage patterns

## Technical Specifications

- **Blockchain**: Stacks blockchain
- **Smart Contract Language**: Clarity
- **Session Duration**: 2 hours maximum (configurable)
- **Advance Booking**: Up to 7 days
- **Computer Capacity**: 50 computers (configurable)
- **Print Quotas**: 20 pages per day per patron

## Contract Interactions

Each contract operates independently but shares common data structures:

- **Patron ID**: Unique identifier for library users
- **Computer ID**: Unique identifier for each computer terminal
- **Session ID**: Unique identifier for each usage session
- **Timestamp**: Block height for time tracking

## Installation

1. Install Clarinet CLI
2. Clone this repository
3. Run `clarinet check` to validate contracts
4. Deploy contracts to testnet/mainnet

## Testing

Run the test suite with:
\`\`\`bash
npm test
\`\`\`

## Usage Examples

### Booking a Session
\`\`\`clarity
(contract-call? .session-booking book-session u1 u123456789)
\`\`\`

### Checking Time Remaining
\`\`\`clarity
(contract-call? .time-enforcement get-time-remaining u1)
\`\`\`

### Submitting Support Request
\`\`\`clarity
(contract-call? .tech-support create-ticket u1 "Printer not working")
\`\`\`

### Processing Print Job
\`\`\`clarity
(contract-call? .printing-management submit-print-job u1 u5 false)
\`\`\`

### Viewing Usage Stats
\`\`\`clarity
(contract-call? .usage-analytics get-daily-stats)
\`\`\`

## Configuration

Key system parameters can be adjusted:

- `MAX-SESSION-DURATION`: Maximum session length in blocks
- `MAX-COMPUTERS`: Total number of available computers
- `DAILY-PRINT-QUOTA`: Maximum pages per patron per day
- `PRINT-COST-BW`: Cost per black & white page
- `PRINT-COST-COLOR`: Cost per color page

## Error Codes

- `ERR-NOT-AUTHORIZED` (u100): Caller not authorized
- `ERR-COMPUTER-BUSY` (u101): Computer already in use
- `ERR-INVALID-TIME` (u102): Invalid time parameters
- `ERR-QUOTA-EXCEEDED` (u103): Print quota exceeded
- `ERR-INSUFFICIENT-FUNDS` (u104): Not enough funds for printing
- `ERR-SESSION-EXPIRED` (u105): Session has expired
- `ERR-INVALID-COMPUTER` (u106): Computer ID not found

## License

MIT License - see LICENSE file for details
