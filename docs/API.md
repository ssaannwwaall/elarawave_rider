# API.md — ElaraWave Rider App

Base URL:
```
http://18.170.4.157/elara/api/riderv1/
```

All endpoints below are confirmed and used exactly as documented by the client. **No field beyond what is shown here should be assumed to exist.**

---

## 1. Login

```
GET {base}/login?device=app&username={username}&password={password}
```

**Query params**
| Param | Type | Notes |
|---|---|---|
| `device` | string | Always `app` for this client |
| `username` | string | Rider's username |
| `password` | string | Rider's password |

**Sample response**
```json
{"success":true,"message":"Login successful.","rider":{"id":265,"name":"Testrider","email":"test00@gmail.com","username":"test00","type":"rider"}}
```

**Test credentials (dev only):** `username=test00`, `password=test00`

**UI usage**
| Field | Used for |
|---|---|
| `success` | Branches to Home (true) vs. inline error (false) |
| `message` | Shown inline near the Login button on failure |
| `rider.id` | Persisted locally; used as `rider_id` on every subsequent API call |
| `rider.name` | Displayed in Home top bar |
| `rider.email`, `rider.username` | Persisted for future profile screen; not yet displayed |
| `rider.type` | Persisted, not currently branched on (only riders use this app) |

---

## 2. Allocated Zones

```
GET {base}/allocated_zones?rider_id={rider_id}
```

**Query params**
| Param | Type | Notes |
|---|---|---|
| `rider_id` | int | From persisted session — never hardcoded |

**Sample response**
```json
{"success":true,"message":"Allocated zones loaded.","rider":{"id":265,"name":"Testrider","username":"test00","email":"test00@gmail.com"},"date":"2026-07-23","weekday":4,"weekday_label":"Thursday","allocations":[{"allocation_id":1,"weekdays":[1,2,3,4,5,6,7],"weekday_labels":["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"],"is_today":true,"zones":[{"id":5,"name":"Askari 10"},{"id":2,"name":"DHA Phase 3"},{"id":7,"name":"DHA Phase 4"},{"id":6,"name":"DHA Phase 5"},{"id":10,"name":"DHA Phase 6"},{"id":9,"name":"DHA Phase 7"},{"id":11,"name":"DHA Phase 8"},{"id":8,"name":"DHA Phase 9 town"},{"id":4,"name":"Gulberg"},{"id":1,"name":"Hassan 2"},{"id":3,"name":"Hassan Shah"},{"id":12,"name":"Paragon City"}]}]}
```

**UI usage**
| Field | Used for |
|---|---|
| `date`, `weekday`, `weekday_label` | Cross-check against selected date tab |
| `allocations[].is_today` | Highlighting which allocation block is active "today" |
| `allocations[].weekdays` / `weekday_labels` | Could later be used to gray out zone chips on days a zone isn't allocated (not yet implemented — all zones across all allocations are flattened into one filter list today) |
| `zones[].id` | Value sent as `filters.zone_id` equivalent when filtering the to-do list |
| `zones[].name` | Chip label in the zone filter strip on Home |

---

## 3. To-Do List

```
GET {base}/todo_list?rider_id={rider_id}
```

**Query params (currently supported)**
| Param | Type | Notes |
|---|---|---|
| `rider_id` | int | From persisted session |

**Sample response (empty state — still possible on days with no orders)**
```json
{"success":true,"message":"To-do list loaded.","rider":{"id":265,"name":"Testrider","username":"test00","email":"test00@gmail.com"},"list_type":"today","date":"2026-07-23","filters":{"zone_id":0,"q":""},"summary":{"count":0,"sold":0,"cash":0},"orders":[]}
```

**Sample response (with a real order — confirmed schema)**
```json
{"success":true,"message":"To-do list loaded.","rider":{"id":265,"name":"Testrider","username":"test00","email":"test00@gmail.com"},"list_type":"today","date":"2026-07-23","filters":{"zone_id":0,"q":""},"summary":{"count":1,"sold":1200,"cash":0},"orders":[{"sr":1,"order_id":3,"order_no":"00003","order_type":"sale_order","order_status":"ready","order_status_label":"Ready","order_datetime":"2026-07-23 13:51:00","delivery_due_date":"0000-00-00","amount":1200,"received":0,"notes":"","customer":{"id":81,"party_code":"00081","name":"Test customer","type_label":"Customer","address":"","phone":"+92","latitude":null,"longitude":null,"last_days":7,"empty":205,"balance":12000},"zone":{"id":7,"name":"DHA Phase 4"},"items":[{"id":3,"product_id":25,"item_name":"19 liter Refill Alkaline","quantity":10,"unit_price":120,"line_amount":1200,"empty_received":10}]}]}
```

**UI usage**
| Field | Used for |
|---|---|
| `list_type` | Echoed back; will reflect date-tab selection once the backend accepts a date/list_type param |
| `date` | Displayed / cross-checked against the selected date tab |
| `filters.zone_id` | Reflects active zone filter; `0` = all zones |
| `filters.q` | Reflects active search text |
| `summary.count` | "Orders" stat tile |
| `summary.sold` | "Sold" stat tile |
| `summary.cash` | "Cash" stat tile (total cash collected across today's orders — distinct from any single order's `received`) |

### `orders[]` — confirmed schema

Confirmed against one real sample order (above). Parsed in `lib/data/models/todo_order_model.dart` into `ToDoOrder`/`OrderCustomer`/`OrderItem` (`lib/domain/entities/todo_order.dart`). Fields stay nullable/defensive where only one example has been seen — do not assume every order will have a full address, phone, or geo location just because the schema is now known.

| Field | Type | Used for |
|---|---|---|
| `sr` | int | Not currently displayed (sequence number within the response) |
| `order_id` | int | Order card tap target → `/order-detail/:id` route (stub only, see `PROJECT.md`) |
| `order_no` | string | Order card header, shown as `#00003` |
| `order_type` | string | **Open string** — only `"sale_order"` confirmed. Not branched on in the UI yet; treat as free text, not an enum. |
| `order_status` | string | Machine-readable status key. **Only `"ready"` confirmed so far.** Used to pick the status badge color via an extensible map (`lib/core/widgets/status_badge.dart`) — any unrecognized key falls back to a neutral gray rather than breaking. Add delivered/cancelled/pending/etc. to that map once the backend confirms their keys. |
| `order_status_label` | string | Human-readable label shown on the status badge (e.g. "Ready") |
| `order_datetime` | string (`yyyy-MM-dd HH:mm:ss`) | Parsed to `DateTime`, shown as a short time (e.g. "1:51 PM") on the order card |
| `delivery_due_date` | string | **`"0000-00-00"` is the backend's null-placeholder**, not a real date — parsed to `null` and hidden from the UI. A real date (once seen) would render normally. |
| `amount` | number | What's owed for this order — shown bold on the order card |
| `received` | number | What's been collected so far for this order (`0` = nothing collected). If `received < amount`, the card visually flags the outstanding balance. |
| `notes` | string | Persisted in the model; not yet surfaced in the Home card (candidate for Order Detail) |
| `customer.id`, `.party_code`, `.name`, `.type_label` | — | `name` shown on the card; the rest persisted for Order Detail |
| `customer.address` | string | Hidden when empty (the sample record has `""`) |
| `customer.phone` | string | Call icon on the card is only enabled when the value contains **≥10 digits** — guards against placeholder values like `"+92"` with no real subscriber number attached |
| `customer.latitude` / `.longitude` | number or null | Navigate icon is disabled (not hidden) whenever either is `null` |
| `customer.last_days` | int | Not yet surfaced in the UI (candidate for Order Detail — "last ordered N days ago") |
| `customer.empty` | number | Outstanding **empty bottles** owed by the customer — shown as an "Empties due: N" chip, kept visually separate from money |
| `customer.balance` | number | Customer's overall account balance/dues — **not** the same as this order's `amount`; persisted but not yet surfaced on the Home card to avoid confusing the two |
| `zone.id`, `zone.name` | — | `zone.name` shown as a small tag next to the customer name |
| `items[].item_name`, `.quantity` | — | Combined into a compact one-line summary, e.g. "10× 19 liter Refill Alkaline", with "+N more" when there's more than one line item |
| `items[].unit_price`, `.line_amount`, `.empty_received` | number | Persisted per item; not shown in the compact card summary (candidate for Order Detail's expanded item list) |

**Known gap:** there is no documented `date` (or `list_type`) query param for fetching a specific day's to-do list yet. The Home screen's date tabs currently re-trigger the same `todo_list` call (today's data only) when a different tab is tapped; the controller method (`HomeController._loadToDoList` → `RiderRepository.getToDoList`) is structured so adding a `date` param is a one-line change once the backend confirms the parameter name. This is intentionally not blocking the UI — see `STATE_ARCHITECTURE.md` for how the fetch method is isolated.

---

## Pending / TBD (not yet available — do not fake)

These are referenced in the build brief as future work. **No endpoint exists for these today.** Do not silently mock success responses — code paths that would call these are left as clearly marked TODOs or are simply not built:

- **Logout** — no endpoint documented. No token exists to invalidate; "logging out" today would just mean clearing local storage, but this is not wired up in the UI since the brief doesn't request a logout button yet.
- **Update order status** (e.g. mark delivered / cancelled) — no endpoint documented. Only the `"ready"` status key/label has been confirmed; the status→color map in `status_badge.dart` is intentionally open so unseen keys don't break.
- **Proof of delivery** (photo/signature upload) — no endpoint documented.
- **Cash collection confirmation** — no endpoint documented.
- **Push notifications** — no endpoint/token registration documented. The notification bell icon on Home is a non-functional placeholder.
- **Date-scoped to-do list** (`date` or `list_type` query param) — see "Known gap" above.
- **Order Detail data** — `/order-detail/:id` is wired as a navigation target from the order card, but there is no endpoint yet to fetch a single order's full detail (it reuses whatever the to-do list already returned in memory, once that screen is actually built).
