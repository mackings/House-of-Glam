# Mobile Escrow API

All endpoints use the existing API base URL and require
`Authorization: Bearer <token>`.

## Accept Quote

`POST /api/v1/custom-orders/requests/:requestId/accept`

Response:

```json
{
  "success": true,
  "message": "Quote accepted and payment protection record created",
  "data": {
    "escrow": {
      "_id": "escrowId",
      "status": "pending",
      "depositAmount": 50000,
      "balanceAmount": 50000,
      "milestones": [
        {"name": "deposit", "amount": 50000, "status": "pending"},
        {"name": "balance", "amount": 50000, "status": "pending"}
      ]
    }
  }
}
```

## Initialize Payment

`POST /api/v1/custom-orders/requests/:requestId/pay`

Request:

```json
{
  "milestoneName": "deposit",
  "callbackUrl": "https://houseofglam.app/escrow/callback"
}
```

Response:

```json
{
  "success": true,
  "message": "Escrow payment initialized successfully",
  "data": {
    "authorizationUrl": "https://checkout.paystack.com/...",
    "accessCode": "paystack_access_code",
    "paymentReference": "HOG-ESC-ABC123",
    "gateway": "Paystack",
    "amount": 50000,
    "currency": "NGN",
    "milestone": {
      "name": "deposit",
      "amount": 50000,
      "status": "pending",
      "reference": "HOG-ESC-ABC123"
    }
  }
}
```

Open `authorizationUrl` in the app checkout WebView. After it closes, verify
the returned `paymentReference`.

## Verify Payment

`GET /api/v1/custom-orders/escrow/verify/:paymentReference`

Response:

```json
{
  "success": true,
  "message": "Escrow payment confirmed and held successfully",
  "data": {
    "escrow": {
      "_id": "escrowId",
      "status": "deposit_held",
      "milestones": [
        {
          "name": "deposit",
          "amount": 50000,
          "status": "paid",
          "reference": "HOG-ESC-ABC123"
        }
      ]
    },
    "gateway": {
      "provider": "Paystack",
      "status": "success",
      "reference": "HOG-ESC-ABC123",
      "amount": 50000,
      "currency": "NGN"
    }
  }
}
```

## Designer Wallet

`GET /api/v1/custom-orders/designer/escrow-wallet`

The response contains held, released, and refunded totals plus escrow order
records and their milestone statuses. Designers can view funds but cannot
release them.

## Admin Release

`POST /api/v1/custom-orders/escrow/:escrowId/release`

Request:

```json
{
  "amount": 50000,
  "adminNote": "Order completed and approved"
}
```

This endpoint is admin-only. The server must reject customer and designer
tokens.

## Admin Refund

`POST /api/v1/custom-orders/escrow/:escrowId/refund`

Request:

```json
{
  "amount": 50000,
  "adminNote": "Customer refund approved"
}
```

This endpoint is admin-only.

## Manual Reconciliation

`POST /api/v1/custom-orders/escrow/:escrowId/payments`

This is for admin reconciliation only. Normal mobile payment confirmation uses
the verify endpoint or the Paystack webhook.
