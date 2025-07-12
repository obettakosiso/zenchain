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
