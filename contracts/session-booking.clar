;; Session Booking Contract
;; Manages hourly computer reservations for library patrons

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant MAX-COMPUTERS u50)
(define-constant MAX-SESSION-DURATION u7200) ;; 2 hours in blocks
(define-constant MAX-ADVANCE-BOOKING u100800) ;; 7 days in blocks

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-COMPUTER-BUSY (err u101))
(define-constant ERR-INVALID-TIME (err u102))
(define-constant ERR-INVALID-COMPUTER (err u106))
(define-constant ERR-BOOKING-CONFLICT (err u107))

;; Data structures
(define-map computer-sessions
  { computer-id: uint }
  {
    patron-id: uint,
    start-time: uint,
    end-time: uint,
    is-active: bool
  }
)

(define-map patron-bookings
  { patron-id: uint, booking-id: uint }
  {
    computer-id: uint,
    scheduled-start: uint,
    scheduled-end: uint,
    status: (string-ascii 20)
  }
)

(define-data-var next-booking-id uint u1)
(define-data-var total-active-sessions uint u0)

;; Read-only functions
(define-read-only (get-computer-status (computer-id uint))
  (match (map-get? computer-sessions { computer-id: computer-id })
    session (ok session)
    (ok { patron-id: u0, start-time: u0, end-time: u0, is-active: false })
  )
)

(define-read-only (is-computer-available (computer-id uint) (start-time uint) (end-time uint))
  (let ((current-session (unwrap-panic (get-computer-status computer-id))))
    (if (get is-active current-session)
      (if (or (< end-time (get start-time current-session))
              (> start-time (get end-time current-session)))
        (ok true)
        (ok false))
      (ok true))
  )
)

(define-read-only (get-patron-bookings (patron-id uint))
  (ok (map-get? patron-bookings { patron-id: patron-id, booking-id: u1 }))
)

(define-read-only (get-active-sessions-count)
  (ok (var-get total-active-sessions))
)

(define-read-only (is-valid-booking-time (start-time uint) (end-time uint))
  (let ((current-block block-height))
    (and
      (> start-time current-block)
      (< start-time (+ current-block MAX-ADVANCE-BOOKING))
      (> end-time start-time)
      (<= (- end-time start-time) MAX-SESSION-DURATION)
    )
  )
)

;; Public functions
(define-public (book-session (computer-id uint) (start-time uint))
  (let (
    (end-time (+ start-time MAX-SESSION-DURATION))
    (current-block block-height)
    (booking-id (var-get next-booking-id))
  )
    (asserts! (< computer-id MAX-COMPUTERS) ERR-INVALID-COMPUTER)
    (asserts! (is-valid-booking-time start-time end-time) ERR-INVALID-TIME)
    (asserts! (unwrap! (is-computer-available computer-id start-time end-time) ERR-BOOKING-CONFLICT) ERR-BOOKING-CONFLICT)

    (map-set patron-bookings
      { patron-id: (unwrap-panic (principal-to-uint tx-sender)), booking-id: booking-id }
      {
        computer-id: computer-id,
        scheduled-start: start-time,
        scheduled-end: end-time,
        status: "confirmed"
      }
    )

    (var-set next-booking-id (+ booking-id u1))
    (ok booking-id)
  )
)

(define-public (start-session (computer-id uint))
  (let (
    (patron-id (unwrap-panic (principal-to-uint tx-sender)))
    (current-time block-height)
    (end-time (+ current-time MAX-SESSION-DURATION))
  )
    (asserts! (< computer-id MAX-COMPUTERS) ERR-INVALID-COMPUTER)
    (asserts! (unwrap! (is-computer-available computer-id current-time end-time) ERR-COMPUTER-BUSY) ERR-COMPUTER-BUSY)

    (map-set computer-sessions
      { computer-id: computer-id }
      {
        patron-id: patron-id,
        start-time: current-time,
        end-time: end-time,
        is-active: true
      }
    )

    (var-set total-active-sessions (+ (var-get total-active-sessions) u1))
    (ok true)
  )
)

(define-public (end-session (computer-id uint))
  (let (
    (patron-id (unwrap-panic (principal-to-uint tx-sender)))
    (session (unwrap! (map-get? computer-sessions { computer-id: computer-id }) ERR-INVALID-COMPUTER))
  )
    (asserts! (is-eq (get patron-id session) patron-id) ERR-NOT-AUTHORIZED)
    (asserts! (get is-active session) ERR-INVALID-TIME)

    (map-set computer-sessions
      { computer-id: computer-id }
      (merge session { is-active: false })
    )

    (var-set total-active-sessions (- (var-get total-active-sessions) u1))
    (ok true)
  )
)

(define-public (cancel-booking (booking-id uint))
  (let (
    (patron-id (unwrap-panic (principal-to-uint tx-sender)))
    (booking (unwrap! (map-get? patron-bookings { patron-id: patron-id, booking-id: booking-id }) ERR-NOT-AUTHORIZED))
  )
    (map-set patron-bookings
      { patron-id: patron-id, booking-id: booking-id }
      (merge booking { status: "cancelled" })
    )
    (ok true)
  )
)

;; Admin functions
(define-public (force-end-session (computer-id uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (match (map-get? computer-sessions { computer-id: computer-id })
      session (begin
        (map-set computer-sessions
          { computer-id: computer-id }
          (merge session { is-active: false })
        )
        (var-set total-active-sessions (- (var-get total-active-sessions) u1))
        (ok true)
      )
      ERR-INVALID-COMPUTER
    )
  )
)

;; Helper function to convert principal to uint (simplified)
(define-private (principal-to-uint (p principal))
  (ok u1) ;; Simplified - in real implementation would hash principal
)
