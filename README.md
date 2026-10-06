# Glance — Style Intelligence

A SwiftUI iOS app built from the [Fig File](https://www.figma.com/design/Lc6brs9Cgeem9rbu1jHwgH/Fig-File?node-id=11-1211) design system: a personalised style feed, a product detail screen, and a Style Intelligence Profile.

## Running it

```bash
open Glance.xcodeproj
```

Pick any iPhone simulator and run. Minimum deployment target is **iOS 18** (the shared-element navigation transition needs it). Dark only.

## Installing it on a phone

The app builds clean for `arm64` device (`-destination 'generic/platform=iOS'`), but a build only runs on a phone once **your** signing identity is on it — no one else can sign it for you.

**With any Apple ID, no paid account.** Open `Glance.xcodeproj`, pick the Glance target → *Signing & Capabilities*, set *Team* to your personal team, plug the iPhone in and Run. If Xcode says the bundle identifier is unavailable, change `PRODUCT_BUNDLE_IDENTIFIER` to something of your own (`com.yourname.glance`). The app then runs for **7 days** before it needs re-installing, and the phone must be on **iOS 18 or newer**.

**With a paid developer account**, to hand someone an `.ipa`:

```bash
xcodebuild -project Glance.xcodeproj -scheme Glance -configuration Release \
  -destination 'generic/platform=iOS' -archivePath build/Glance.xcarchive archive
xcodebuild -exportArchive -archivePath build/Glance.xcarchive \
  -exportOptionsPlist ExportOptions.plist -exportPath build
```

Fill your Team ID into `ExportOptions.plist` first; switch its `method` to `app-store-connect` for TestFlight.

## Screens

| Screen | Entry point | Figma node |
| --- | --- | --- |
| Home feed | app root | `321:518` |
| Product detail (L2) | tap the olive polo card | `32:2523` in [iOS – V7](https://www.figma.com/design/vBUORrjA3i65GhXmIgXJyF/iOS---V7?node-id=32-2523) |
| Style Intelligence Profile | tap the header avatar | `2490:1619` (`D0- Profile`) |
| Look page | tap the big look card | `6215:7530` in Surface Art Dev Handoff |
| Tip page | tap a tip card, or its `Find a Product` | `4201:5148` in Surface Art Dev Handoff |
| Assistant | an analysis card's call to action | `731:701` |

Home was redrawn as a new frame, so its node IDs differ from the rest of the file. Every card in `MockFeedRepository` is annotated with the node it came from.

Both pushes are **zoom / shared-element transitions** (`matchedTransitionSource` + `navigationTransition(.zoom:)`): the header avatar expands into the profile, and the polo card expands into the product screen. The product gallery leads with the feed card's own photograph so the card morphs into the same image it grew out of.

## Layout

```
Glance/
├── DesignSystem/      colour, type scale, spacing/radius, font registration
├── Components/        chips, badges, bubble shape, glass panel, page dots
├── Models/            feed, product and profile value types
├── Data/              repositories — mock today, swappable tomorrow
└── Features/
    ├── Home/          masonry feed + the seven card types
    ├── Product/       gallery, reviews, size, colours, price chart, delivery…
    ├── Profile/       hero, vibes, personal analysis, dimension cards
    └── Shared/        the Ask Glance assistant sheet
```

### Design system

Tokens are lifted straight from the `Foundations` frames, so the names in code match the names in Figma:

- **Colour** — `GlanceColor`. Hierarchy comes from white-opacity levels, not separate greys.
- **Type** — `GlanceTextStyle`, following the design system's `Typeface` frame ([Surface Art Design Library, 2051:136](https://www.figma.com/design/Lc6brs9Cgeem9rbu1jHwgH/Surface-Art-Design-Library?node-id=2051-136)). Two voices: **Manrope** for UI (headlines, titles, body, labels, data, actions) and **Playfair Display** for editorial (display roles, hero moments, quotes); italic is Playfair-only. Never mix voices inside one component. Apply with `.glanceText(.headingXL)`; label styles uppercase themselves. On iOS 26 each style's line height is set exactly, as Figma sets it.
- **Spacing / radius** — `Space` (4px base grid) and `Radius`.

Both font families are bundled under `Resources/Fonts` and registered at launch by `FontRegistration`, so there is no `UIAppFonts` list to keep in sync.

### Data

Every screen reads through a repository protocol (`FeedRepository`, `ProfileRepository`, `ProductRepository`). The mock implementations carry the copy and imagery from the comps. Pointing the app at a real backend means writing one new conformance per protocol — no view changes.

## What's interactive

Working: size and colour selection, wishlist toggles, sharing a product, the fit question, selectable vibe chips, the analysis cards' calls to action, and the Ask Glance sheet (canned replies via `AskGlanceResponder`).

Visual only for now: the recently-viewed button.

An analysis card's call to action ("Find your fit →", "Cuts and Frames →", …) pushes the assistant (731:701) already talking about that reading: the card carries Glance's opening line and the replies it offers, so Body Frame opens on fit and Skin Type on a routine. Chips and typed messages both get canned answers from `AskGlanceResponder`, which names the card they came from. `ChatTopic` can also carry `followUps` and a `closing` line, so a topic is either one question or a short interview without the view knowing the difference. The older `AskGlanceView` sheet still backs Product's Ask Glance and Try On; moving those onto this screen is a small follow-up.

## Assets

Images and icons are exported from the Figma file into `Assets.xcassets` — photographs as PNG, icons and illustrations as SVG with vector representation preserved. The brand marks ship as white artwork on black and are screen-blended onto their campaign images.

### Image crops

**Feed card artwork fills from centre.** `ImageCrop`'s default is a centred cover fill and no feed card overrides it. Figma offsets each node's art rect by hand, and reproducing those faithfully made the framing read as off across the feed — bottom-aligned portraits, product shots pushed to one side — so the per-node offsets were dropped.

The crop machinery is still there, because three placements genuinely need it: they frame a **face**, where a centred fill would show a torso instead.

| Placement | Why it crops |
| --- | --- |
| Home header avatar | 40pt circle onto the face |
| Profile hero portrait | 104pt circle onto the face |
| Profile analysis portraits | face / hair / skin close-ups |

Figma frames an image in two steps: an **art rect** (a sized, offset box) and a **cover fill** inside it that may be biased up or down rather than centred. `ImageCrop` restates both in the comp's own points, and `CroppedImage` resolves them against the real container:

```swift
// Figma: art rect 204×163 at (-52.74, -54) inside the 76pt Skin Type circle
crop: ImageCrop(width: 204, height: 163, x: -52.74, y: -54, reference: 76)
```

Icons and line illustrations stay on `scaledToFit` — they are glyphs, not photography — as does the Date Night flat-lay, which the comp presents whole on a padded panel.

## Keyboard in the simulator

If a field clearly takes focus (a live caret) but no keyboard appears, that is the **simulator**, not the app: it thinks a hardware keyboard is attached. `defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false`, then restart the Simulator app itself — rebooting the device does not re-read it.

## Development helpers

`DebugLaunch` reads launch arguments so a screen or scroll position can be opened directly — useful for screenshots and review:

```bash
xcrun simctl launch booted com.glance.styleintelligence --route product --scrollTo 6
```

`--route` accepts `product`, `profile`, `look` or `tip`; `--scrollTo` takes a section index; `--chat 0` opens the assistant on that analysis card; `--gallery look`, `signal`, `filler` and `tips` open a component's variant gallery; `--askStage feedReady` starts Home's composer at another point in the journey (`beforeOnboarding`, `feedReady`, `firstGeneration`, `feedIsReady`, `afterOnboarding`). They exist because `simctl` cannot tap, and are all compiled out of release builds.

Screenshots can't catch a half-second transition, so to inspect one, slow the animation down and burst-capture:

```bash
xcrun simctl launch booted com.glance.styleintelligence -UIAnimationDragCoefficient 40 --route product
```

## Notes

- The feed runs on one even 8pt rhythm — **8 / 189 / 8 / 189 / 8** on a 402pt phone, and 8pt between stacked cards — with the columns taking what is left (`GlanceLayout.feedGutter`, `feedColumnGap`, `feedRowGap`).
- Each column **flows on** from one authored block to the next (`FeedLayout.rows`), so every card sits 8pt below the one above it. Squaring the columns up at each block left the shorter one a wider gap every time; now they square up only where a wide card breaks across them — the big look card and the trend card — which is the one place a difference in height can show. Measured, the columns meet those cards within 11 and 20pt. Because order within a column is all that matters, the two taller filler states are placed so no two dark AI cards, posters, tips or products sit side by side or one above the other.
- **Feed type sizes:** a tip's sentence is 20 (`headlineM` — `Headline/Medium`'s 20/24 in Regular, its bold phrase ExtraBold at the same 20/24, so every line sits at 24); the small look card's caption is 16 (`bodyLarge`, `Body/Large` 16/22); the big look card's is 18 (`headlineS`, 18/26); a product card's line is 16 (`bodyL`, 16/20).
- **Every card is 24pt, smoothed** (`RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)`), including the cards whose comps asked for 32 (big look, trend, routine), 26.24 (L2's outfit boards), 22.67 (L2's look suggestion) or 20.5 (L2's panels). Pieces inside a card — thumbnails, chips, swatches, pills — keep their own radii.
- Card furniture from that page: a **wishlist heart** top-right on every card (`WishlistButton` — outlined on the artwork, filled red once tapped, state per card until a wishlist repository exists), a **price pill** with the struck-out original, and a **trending tag** (`TrendingTag`, 28119:1632 — `white 5%` over a blur, a 0.5px white hairline, 4pt radius, 10pt SemiBold beside the arrow) carried as `note` on the model. The look card can lead its tag with a social read (`2.2K LIKE DIOR · BEAUTY`) and offer an action chip (`Style Me`); when that prefix is present the match score is dropped, since all three will not fit 165pt. The AI spark badge moved to the leading corner to give the heart the trailing one.
- `TrendCard` now carries its own `tint` — the comp gives the Lakme story maroon and the Met Gala one navy — and its story line is the **same** `TrendingTag` as the artwork pills. One component for both on purpose: they were two treatments before — a dark scrim on artwork, a tinted gradient on the panel — and drifted the moment the tag was redesigned.
- `SignalCard` (`TRAIN YOUR AI`, `Signal Card` 2831:1117) is the one card that asks: the viewer's portrait beside the label, a serif question, and the answers as pills on the secondary glass. A tap lights the answer white for a beat (650ms, with a selection haptic), then the card turns — a blur-and-fade, as iOS swaps content in place — to its second face, `Want to tell me a little more about what you like?` over `Start Chat →` (2831:1118). Both faces stay laid out, the hidden one invisible, so the card is sized for the taller and keeps its height as it turns: the cards under it in the column never move. The comp's 170×300 is a floor at the column's width, not a cap, so a long question grows the card instead of clipping.
- `Start Chat` pushes the assistant (731:701) already talking: Glance's line about the answer (`acknowledgement`, a format string on the model) leads into four questions about what she likes, asked one at a time through `ChatTopic.followUps` — the interview the old profile's Start Training banner used.
- **Look page** (`Look L2`, 6215:7530) opens from the big look card, which zooms up into it — the card's photograph is the comp's own `image 5795`, and its V7 caption is the page's title. The look stands at 240×424 with its actions hung half over its right edge (like, not for me, share — share is the system sheet) and `Add to Lockscreen` half over its foot, all on Liquid Glass. iOS gives an app no way to set the Lock Screen, so for now that button confirms with a toast; the real flow is a product decision. `Shop the look` lists the pieces (cut-outs from the comp, their proportions restored — Figma exported them stretched and squeezed them back in their frames), `Change Outfit` is the page's one filled button, and `More I think you'll like` runs product tiles and the `Find Similar` card (shared with L2, its front photo per page); all four stand at the tallest tile's height, and every price reads now, was, then the saving, which drops to its own line when it won't fit (`PriceRow`, as on the feed). The composer is the bare `on L2` pill, as the comp draws it.
- **Tip page** (`Skin Tip`, 4201:5148) opens from a tip card, which zooms up into it: the tip as it was in the feed, `Suggested Products` for it, and the composer in its `on L2` state with chips of the tip's own. Each tip carries its suggestions and chips on the model, drawn from the feed's own products.
- Both pages, and L2, share `GlanceLogoBar` — back and recently viewed on glass either side of the wordmark — and the product rows and tiles in `DetailSections`.
- Every product card names its brand now (the brush, vases, merino, loafers and cleanser had none), and every saving — `(21% OFF)` — is `#FF8787` (`GlanceColor.discount`).
- The filler card (`Card`, 2831:1018) is Glance offering to talk: `#050505`, a blue-grey light from past the top-left corner, and a 114pt sparkle watermarked at 7% over the far end. All three of its states are in the feed — `Start a chat?` (`Start Chat`, 2831:1019) under the first skin tip, and further down `Continue Chat` (2831:1017), picking up a date-night thread, and `Want to chat about something?` (`Start Chat 2`, 3138:1867).
- Its edge is a **gradient stroke**, though the exported code flattens it to `rgba(147,117,254,0.1)`: violet at 10%, flaring to white at 90% along a band that crosses the top at 44% of the width and the bottom at 65%. Read off the comp's pixels, it reproduces them within a few levels on every edge. Figma lays a gradient out in the card's unit square and stretches it, so the band shears with each state's height; the stroke is drawn in a square and scaled to match, and given stops every eighth of the way, because Figma blends stops without premultiplying (keeping the flanks violet) where SwiftUI premultiplies (greying them).
- The corner light is drawn as the elliptical Gaussian a σ50 blur of that 159×29 bar leaves behind (σ64 × σ50.5, peaking near 19%) — SwiftUI's `blur(radius: 50)` spread it to barely a glimmer. The first two are one big button; `Continue Chat` has its own, on the secondary Liquid Glass at iOS's measure — 32pt with a 12pt label, where the comp's pill is 24pt with a 9pt label. Each opens the assistant on its own `ChatTopic`.
- `Tip Card` (2825:810) comes in four palettes — Beauty, Fashion, Gadget, Health — of five shades each (`TipCategory`); the feed's skin, hair and fragrance tips are Beauty, its workwear, style and colour tips Fashion, with shades spread so no two neighbours repeat. The content is unchanged, bold phrase included; the colours, 24pt rhythm and corners are the component's, with the kicker at 70% and the whole headline white. Its button is the secondary Liquid Glass button at 32pt with a 12pt label, as on the filler card, and is named for where the tip leads (`TipAction`): `Tell Me More` opens the assistant on the tip's detail, while `Show Products`, `Find Sunscreens` or `Find Cleansers` open the tip's page. On a coloured card the glass takes on the card's tint.
- `Look Card Big` (V7 29:881) rests the shot in a 364×576 window over a 64pt footer — `Do you like this look?` beside the thumbs — on the app's 24pt corners. The photo keeps its 364×647 proportion pinned to the top, so the window sheds its foot, never the face. The scrim and the footer share one tone, sampled from the photo by `ImageTone` (`#45413B` for the airport shot, against the comp's `#41413E`), so the photo settles straight into the footer. A thumbs up answers the question — `You’ll see more of these` (29:907); a thumbs down only fills its glyph, as the comp draws it (29:894).
- Both columns are pinned to that measured width. Left to itself an `HStack` hands extra room to whichever column holds the longest unbreakable word, starving the other.
- **Vertical rhythm:** a card drawn with `BubbleShape` would take half the gap beneath it, since its tail already hangs into that space; `FeedItem.hasTail` decides, though no card currently has one.
- `BubbleShape` traces one continuous outline. Filling a rounded rect and a tail triangle as two subpaths leaves a transparent hairline at the joint: they wind in opposite directions, so the non-zero fill rule cancels their overlap to zero.
- Card placement is declared per column in `MockFeedRepository` rather than derived by a shortest-column heuristic, so it matches the hand-laid-out comp exactly.
- The product card's image container is a strict 3:4 (`Product Cards`, 321:117) and its `Rational` text block has no top padding.
- That component also defines a price pill — 16pt in from the leading edge, 8pt up from the image's bottom. `RationalCard.price` still renders it, but the current `Home` frame (321:518) sets no prices, so nothing shows one. Set `price:` on a card to bring it back.
- Brand card artwork ships flattened: the wordmark and bottom scrim are baked into the image, so the view composites nothing over it. Only the caption and the folded page corner are drawn.
- Profile's `Glow` (338:174, kept by D0) is **not** a purple gradient — it is a dark arch, filled with the page's own black, lit only at its rim. `ArchGlow` draws a 640pt rounded-top rect (crown radius 320, a true semicircle) with an outer halo above the crown and a `RadialGradient` centred on the crown circle for the inner spill. Sampling the comp showed that spill is purely a function of distance from that circle's centre, so one radial gradient reproduces all three of Figma's stacked inset shadows.
- The comp is a still. The glow's only motion is the scroll response — the layer dims toward 55% as the hero leaves (`onScrollGeometryChange`) — plus a slow 7.5s breath in the rim. An idle sweep of light along the crown was tried and taken back out. Everything animates opacity or scale, so the render server handles it and the blurred layers are never redrawn; `accessibilityReduceMotion` skips the breath and keeps the scroll response.
- It rides in the hero as a top-aligned background, hung from the avatar's centre line as in the comp (glow at y 180, avatar 128…232), so it scrolls with her photo natively. Pinned behind the page — as it was, drifting at 0.08× — the crown stayed put while the copy below slid over it, and a fixed 180 from the top of the screen left it riding high on the photo on phones whose top inset is taller than the comp's 40pt status bar.
- Only the crown and its 400pt rim band are drawn. Below that the arch is black on black, and an arch cut short trails its halo along the cut, so the layer is masked to the band plus room above the crown for the halo. Over black the rim light also has to fade out across the band's last 80pt rather than stop — cut square, its edge shows as a seam.
- On the analysis cards the metric chip is painted **before** the portrait, so the circle occludes the chip's leading end. Figma orders it that way among its siblings; layering it after covers her hair.
- `Personal Analysis` (2490:1668 — the comp spells it `PersonaL`) is four 240×302 cards — Body, Face, Skin, Hair — at a 12pt gap, in a row that pages card by card (`scrollTargetBehavior(.viewAligned)`) with the next card showing at the edge. 302 is a floor rather than a fixed height, so a longer reading grows the card instead of clipping.
- Skin and Hair render their circle from a **source photo plus a crop**, not a pre-rendered circle like Body and Face. Figma stacks two fills inside those 76pt circles — a base cover fill and a second, much larger image laid over it — and only the overlay is visible, so `AnalysisCard.crop` restates the overlay's art rect: 204×163 at (-52.74, -54) for Skin, 129×103 at (-12.74, -24) for Hair. That is what lands the circle on her cheek and on the back of her hair rather than on a whole portrait.
- Those two nodes cannot be exported: `get_screenshot` and `download_assets` both return a 149-byte 1×1 PNG for them, which looks exactly like an empty layer. It isn't — the fills are there in `get_design_context`. Reach for the design context, not the export, when a node comes back empty.
- Each card carries its own call to action ("Find your fit →", "Build your routine →") as a secondary glass pill, which opens the assistant on that reading.
- The mascot (338:310) is drawn by `MascotView` from a **blur-free** asset: the comp's blurred ground ellipse (`feGaussianBlur stdDeviation="12"`) and the inner-shadow filters are stripped, leaving the body path with its `#AC42D6 → #6032FF` gradient plus the two white eyes. Keeping the glow was a dead end — Figma's PNG export bakes the canvas in as opaque pixels (a dark rectangle over every card), and keying it out reintroduced haze wherever the un-composite divided by a near-zero alpha.
- Inside the comp's 48pt frame that body measures 34.34×27.43 at (7.5, 10.5). `MascotView` keeps those numbers and scales them from its `size`, rather than stretching the artwork to fill a square — the body's aspect is 1.25:1, so filling a square distorts the character.
- The composer (`Bottom New`, 406:1419) is `AskGlanceBar`, shared by Home and Product. Product passes its suggestion chips as the `accessory` row above the pill; Home uses the chip-free convenience initialiser. Both hosts ignore the bottom safe area so the pill sits a fixed 24pt from the **physical** bottom edge rather than from the home indicator, and each leaves `AskGlanceBarMetrics.reservedHeight` of bottom padding so its last item clears the bar. The metrics live outside the generic view so callers can read them without naming a concrete `Accessory`.
- Its band grades to `#000000` as the comp specifies, over a **progressive blur** — three masked `.ultraThinMaterial` layers, each starting lower than the last, so the softening deepens toward the bar the way iOS's own scroll-edge effect does. The earlier hard-edged look came from a separate solid fill under the home indicator, not from this ramp; the band now bleeds upward as a background, which costs no layout.
- Inset shadows (`shadow(inset 0 0 R colour)`) go through `innerGlow(_:radius:color:)`, never a blurred `strokeBorder`. `strokeBorder` sits wholly inside the shape, so blurring it drags the light's peak ~10pt inward and smears the falloff over roughly twice the distance — the card reads as a broad vignette instead of a lit rim. Stroking *centred* on the path and clipping back to the shape keeps the maximum on the boundary, which is what an inset shadow does. Calibrated against `training-banner` (338:308): the comp peaks just inside the border and reaches the flat fill ~28pt in, and the build now tracks that to within 7 of 255 levels.
- The trending card is the one component from a **different library** — `Trending News Card`, 27948:7574 in *Surface Art Playground* — so it does not inherit this project's foundations. It replaced the older image-and-headline card: a deep maroon `#220605` panel, the photograph at the comp's 364:322, a half-transparent maroon gradient bar over a blur naming the story, the headline, then the three tools. Two notes on the translation: the panel keeps Glance's own photograph and headline rather than that file's placeholder copy, with the pill carrying the story line; and the card has **no tail**, so `.trend` is no longer in `FeedItem.hasTail` and the feed gives it a full 24pt beneath.
- Its chips are the same `GlanceChip`, on a new `tone: .plain` — a borderless `white 4%` wash. The outlined tone the product screen uses is untouched.
- Product and Profile pin their header with `.safeAreaInset(edge: .top)` and hide `UINavigationBar`. The inset pins the bar and insets the content, but the scroll view still draws *behind* it, so the blur has live content passing underneath. Its buttons are the comp's glyphs on 40pt Liquid Glass discs inside 44pt targets (`BarIconButton`), as an iOS 26 bar draws them.
- Both the pinned headers and the bottom composer sit on `EdgeScrim`: a progressive blur (stacked masked material layers, each reaching a little less far than the last) plus a ramp to `#000000`, anchored to one edge and falling away from it. A single uniform material ends abruptly and draws a crisp line across the content. Stops are authored as distance from the anchored edge, so the bottom-anchored case just mirrors them — one implementation, so the two edges cannot drift apart. Both ends grade to `#000000`. What differs is how long they hold it: the bottom band holds nothing and ramps the whole way, and a header holds only its top 18% — the status-bar strip is true black, and by the title the ramp has already given way to blur, so content passes behind the bar instead of vanishing under it. Holding black across the whole bar (0.7, as it was first built) turns the top of the screen into a slab; watering the colour down instead just leaves the material's grey showing.
- That header is deliberately **not** in the toolbar. `UINavigationBar` runs its own push animation, sliding its items in from the trailing edge, which fights the zoom transition — you get the page expanding out of the card while the bar slides in sideways. Owning the header puts it inside the zoomed content, so it expands with everything else.
- Its tool chips scroll rather than wrap, since three chips laid out for 440pt do not fit 402pt.
- A dimension card's blocks stand **44pt** apart, not 16: Figma pads each block 16 inside its own frame and leaves 12 between frames (2490:1762 / 1785 / 1808), and reading only the frame gap collapses the card. The palette block closes on 24 rather than 16.
- Profile follows `D0- Profile` (2490:1619). Against `V1 - Profile` (689:881) that means: no name field, no visual-source strip or `Add Photo` sheet, no `Start Training` banner, no editable occasion frequency and no completeness bars. Each block's header names whose read it is — amber `YOUR GO TO` / `YOUR` for what she has told Glance, lavender `AI READ` for what it inferred. Meters read **High / Medium / Low** over a track; `MeterRow` carries both, `reading` for the word and `percent` for the track.
- Meter tracks are drawn as a share of the row: the comp's fills are fixed widths (243 / 183 / 63 of a 316pt track), restated as 77 / 58 / 20%. It draws Occasion's Casual (`Medium`) to the same 264pt as Work (`High`); the build gives Medium the 58% it has in the Aesthetic mix, so the word and the track agree.
- Row rhythm differs from card to card in the comp — Fit & sizing sets its rows 12 apart and Brand 16, Occasion pads 8 under each meter, and Fashion & Style alone puts 12 between its title and subtitle where the others use 4. The build mirrors it per block (`DimensionBlock`'s `spacing` / `rowInset`, `DimensionCard.headerSpacing`) rather than evening it out.
- The iOS treatment on Profile: the back button on glass, the analysis calls to action as secondary glass, cards on continuous corners, the analysis row snapping card by card, and a selection haptic when a vibe chip is toggled.
- Two of the four analysis portraits cannot be exported: asking Figma to render the Skin or Hair circle returns a 149-byte 1×1 PNG. Their source photographs come back fine through `download_assets`, so those two cards frame the source with an `ImageCrop` taken from the node's own numbers (`204×163` centred at `+11.26, -10.5` for Skin), while Body and Face use the pre-rendered circles Figma does export.
