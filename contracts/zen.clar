;; Community Wellness Initiative Smart Contract
;; Manages community contributions, wellness program distribution, and participant management

;; Error Constants
(define-constant ERR-UNAUTHORIZED-COORDINATOR-ACCESS (err u100))
(define-constant ERR-PARTICIPANT-DUPLICATE (err u101))
(define-constant ERR-PARTICIPANT-NONEXISTENT (err u102))
(define-constant ERR-INITIATIVE-BALANCE-INSUFFICIENT (err u103))
(define-constant ERR-CONTRIBUTION-MINIMUM-NOT-MET (err u104))
(define-constant ERR-INITIATIVE-NOT-ACTIVE (err u105))
(define-constant ERR-CONTRIBUTION-AMOUNT-INVALID (err u106))
(define-constant ERR-PARTICIPANT-STATUS-INVALID (err u107))
(define-constant ERR-COORDINATOR-ADDRESS-INVALID (err u108))

;; Data Variables
(define-data-var initiative-coordinator principal tx-sender)
(define-data-var initiative-balance-total uint u0)
(define-data-var initiative-active-status bool true)
(define-data-var contribution-minimum-amount uint u1000000) ;; 1 STX
(define-data-var initiative-emergency-mode bool false)

;; Data Maps
(define-map participant-registry 
    principal 
    {
        is-participant-active: bool,
        wellness-funds-received: uint,
        last-distribution-block: uint,
        current-program-status: (string-ascii 20)
    }
)

(define-map contributor-registry
    principal
    {
        total-contributions-made: uint,
        last-contribution-block: uint
    }
)

;; Read-only functions
(define-read-only (get-initiative-coordinator)
    (var-get initiative-coordinator)
)

(define-read-only (get-initiative-balance)
    (var-get initiative-balance-total)
)

(define-read-only (get-participant-information (participant-wallet principal))
    (map-get? participant-registry participant-wallet)
)

(define-read-only (get-contributor-information (contributor-wallet principal))
    (map-get? contributor-registry contributor-wallet)
)

(define-read-only (check-initiative-operational-status)
    (and (var-get initiative-active-status) (not (var-get initiative-emergency-mode)))
)

;; Private functions
(define-private (verify-coordinator-privileges)
    (is-eq tx-sender (var-get initiative-coordinator))
)

(define-private (update-contributor-history (contributor-wallet principal) (contribution-value uint))
    (let (
        (existing-contributor-record (default-to 
            { total-contributions-made: u0, last-contribution-block: u0 } 
            (map-get? contributor-registry contributor-wallet)
        ))
    )
    (map-set contributor-registry
        contributor-wallet
        {
            total-contributions-made: (+ (get total-contributions-made existing-contributor-record) contribution-value),
            last-contribution-block: block-height
        }
    ))
)

;; Private validation functions
(define-private (validate-contribution-amount (amount uint))
    (and 
        (> amount u0)
        (<= amount u1000000000000) ;; Set reasonable upper limit
    )
)

(define-private (validate-participant-status (status-code (string-ascii 20)))
    (or 
        (is-eq status-code "active")
        (is-eq status-code "pending")
        (is-eq status-code "suspended")
        (is-eq status-code "completed")
    )
)

(define-private (validate-coordinator-address (wallet-address principal))
    (and 
        (not (is-eq wallet-address (var-get initiative-coordinator)))
        (not (is-eq wallet-address (as-contract tx-sender)))
    )
)

;; Public functions
(define-public (make-contribution)
    (let (
        (contribution-value (stx-get-balance tx-sender))
    )
    (asserts! (>= contribution-value (var-get contribution-minimum-amount)) ERR-CONTRIBUTION-MINIMUM-NOT-MET)
    (asserts! (check-initiative-operational-status) ERR-INITIATIVE-NOT-ACTIVE)
    
    (try! (stx-transfer? contribution-value tx-sender (as-contract tx-sender)))
    (var-set initiative-balance-total (+ (var-get initiative-balance-total) contribution-value))
    (update-contributor-history tx-sender contribution-value)
    (ok contribution-value))
)

(define-public (register-new-participant (participant-wallet principal))
    (begin
        (asserts! (verify-coordinator-privileges) ERR-UNAUTHORIZED-COORDINATOR-ACCESS)
        (asserts! (is-none (map-get? participant-registry participant-wallet)) ERR-PARTICIPANT-DUPLICATE)
        
        (map-set participant-registry 
            participant-wallet
            {
                is-participant-active: true,
                wellness-funds-received: u0,
                last-distribution-block: u0,
                current-program-status: "active"
            }
        )
        (ok true)
    )
)

(define-public (distribute-wellness-funds (participant-wallet principal) (distribution-value uint))
    (begin
        (asserts! (verify-coordinator-privileges) ERR-UNAUTHORIZED-COORDINATOR-ACCESS)
        (asserts! (check-initiative-operational-status) ERR-INITIATIVE-NOT-ACTIVE)
        (asserts! (>= (var-get initiative-balance-total) distribution-value) ERR-INITIATIVE-BALANCE-INSUFFICIENT)
        (asserts! 
            (is-some (map-get? participant-registry participant-wallet)) 
            ERR-PARTICIPANT-NONEXISTENT
        )
        
        (try! (as-contract (stx-transfer? distribution-value tx-sender participant-wallet)))
        (var-set initiative-balance-total (- (var-get initiative-balance-total) distribution-value))
        
        (let (
            (participant-record (unwrap! (map-get? participant-registry participant-wallet) ERR-PARTICIPANT-NONEXISTENT))
        )
        (map-set participant-registry
            participant-wallet
            {
                is-participant-active: (get is-participant-active participant-record),
                wellness-funds-received: (+ (get wellness-funds-received participant-record) distribution-value),
                last-distribution-block: block-height,
                current-program-status: (get current-program-status participant-record)
            }
        )
        (ok distribution-value))
    )
)

;; Administrative functions
(define-public (set-minimum-contribution (new-minimum-value uint))
    (begin
        (asserts! (verify-coordinator-privileges) ERR-UNAUTHORIZED-COORDINATOR-ACCESS)
        (asserts! (validate-contribution-amount new-minimum-value) ERR-CONTRIBUTION-AMOUNT-INVALID)
        (var-set contribution-minimum-amount new-minimum-value)
        (ok true)
    )
)

(define-public (toggle-initiative-status)
    (begin
        (asserts! (verify-coordinator-privileges) ERR-UNAUTHORIZED-COORDINATOR-ACCESS)
        (var-set initiative-active-status (not (var-get initiative-active-status)))
        (ok true)
    )
)

(define-public (enable-emergency-mode)
    (begin
        (asserts! (verify-coordinator-privileges) ERR-UNAUTHORIZED-COORDINATOR-ACCESS)
        (var-set initiative-emergency-mode true)
        (ok true)
    )
)

(define-public (disable-emergency-mode)
    (begin
        (asserts! (verify-coordinator-privileges) ERR-UNAUTHORIZED-COORDINATOR-ACCESS)
        (var-set initiative-emergency-mode false)
        (ok true)
    )
)

(define-public (update-participant-status (participant-wallet principal) (new-status (string-ascii 20)))
    (begin
        (asserts! (verify-coordinator-privileges) ERR-UNAUTHORIZED-COORDINATOR-ACCESS)
        (asserts! (validate-participant-status new-status) ERR-PARTICIPANT-STATUS-INVALID)
        (asserts! 
            (is-some (map-get? participant-registry participant-wallet)) 
            ERR-PARTICIPANT-NONEXISTENT
        )
        
        (let (
            (current-record (unwrap! (map-get? participant-registry participant-wallet) ERR-PARTICIPANT-NONEXISTENT))
        )
        (map-set participant-registry
            participant-wallet
            {
                is-participant-active: (get is-participant-active current-record),
                wellness-funds-received: (get wellness-funds-received current-record),
                last-distribution-block: (get last-distribution-block current-record),
                current-program-status: new-status
            }
        )
        (ok true))
    )
)

;; Transfer ownership
(define-public (transfer-coordinator-rights (new-coordinator-address principal))
    (begin
        (asserts! (verify-coordinator-privileges) ERR-UNAUTHORIZED-COORDINATOR-ACCESS)
        (asserts! (validate-coordinator-address new-coordinator-address) ERR-COORDINATOR-ADDRESS-INVALID)
        (var-set initiative-coordinator new-coordinator-address)
        (ok true)
    )
)