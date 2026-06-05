# Newest Feature Mobile Flow Notes

## UX Rules Applied

- Customers should not type backend IDs, vendor IDs, designer IDs, order IDs, escrow IDs, or payment references.
- Messaging opens from accepted quotation relationships only.
- Support tickets and reviews are linked to real orders selected from the user's order history.
- Payment protection is shown as an order state. Customers do not manually record Paystack/Stripe references.
- Admins can intervene in disputes and escrow, but customer-facing screens do not expose backend internals.

## Current Mobile Flow

### Guest

- Guests land on public exploration after onboarding.
- Guests can browse listings and designers.
- Buying, saving, messaging, custom requests, and payment still require account login.

### Customer Style Studio

- `Explore`: listing/designer discovery with filters and rich media viewer.
- `My Sizes`: saved measurements with guide URL fields.
- `Saved`: moodboards and saved inspiration.
- `Custom`: choose a designer and saved measurement profile from lists before submitting a custom request.
- `Chats`: loads backend-approved messageable threads from `GET /messaging/eligible-threads`, then opens chat with the returned `threadId`.
- `Protection`: records deposit/balance using `POST /custom-orders/requests/:requestId/pay`; the backend generates internal references and holds funds.
- `Help`: loads support-eligible orders from `GET /disputes/support-orders`, then creates tickets with the returned `supportTargetId`.
- `Review`: loads reviewable orders from `GET /reputation/reviewable-orders`, then submits verified-purchase category ratings with the returned `reviewTargetId`.

### Designer Tools

- `Portfolio`: categorized portfolio update.
- `Measurements`: loads measurement request targets from `GET /measurements/request-targets` and requests extra fields with the returned `measurementTargetId`.
- `Quotes`: accept/decline custom requests and submit quote details.
- `Workflow`: update order production status.
- `Media`: update listing rich media URL fields.
- `Analytics`: view growth metrics, held/released/refunded escrow wallet values, and feature listings.
- `Reviews`: respond to customer reviews.

## Backend Dependencies Still Needed For Full Polish

To fully remove internal identifiers from every designer-side action, mobile
needs list/detail endpoints that return selectable records:

- Incoming custom requests for the logged-in designer, so quote accept/decline
  and quote submission can start from cards instead of a request token field.
- Designer review response targets for the logged-in designer, so replies can
  start from review cards instead of a review token field.
- Selectable listing records owned by the logged-in designer for media updates
  and featured listing controls.

Customer-facing messaging, support, reviews, measurement requests, and payment
protection now use the new backend selection-token endpoints instead of asking
users for backend IDs or Paystack references.

The latest docs still define these fields as URL arrays:

- `custom-orders/requests.inspirationImages`
- `seller/updateSellerListingMedia.media.fabricCloseups`
- `media.videoPreviews`
- `media.beforeAfterShowcases`
- `media.styledLookPreviews`
- `media.zoomImages`

The app can pick files locally only when the endpoint accepts multipart upload or the backend provides signed upload credentials. Existing app flows already do multipart upload for normal order/listing creation, but the newest feature endpoints are documented as URL-based.

To support user-picked uploads in these newest screens, backend should provide one of:

- Multipart endpoints for custom request inspiration and listing rich media.
- A signed upload flow, for example `GET /imagekit/auth`, plus required public key, upload URL, and folder rules.

Until then, the mobile app should not send local device file paths as media URLs.

## Escrow Behavior

The app should rely on backend automation:

1. User pays through existing Paystack/Stripe checkout.
2. Mobile calls `POST /custom-orders/requests/:requestId/pay` for the selected milestone.
3. Backend records the milestone and generates the internal reference.
4. Designer escrow wallet shows held funds as `pendingEscrow`.
5. Funds release to bank only after delivery confirmation, admin release, or dispute resolution.

The customer UI no longer asks for Paystack references or escrow IDs.
