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
| Product detail (L2) | tap the olive polo card | `11:1512` |
| Style Intelligence Profile | tap the header avatar | `11:1212` |
| Assistant | an analysis card's call to action, or Start Training | `731:701` |

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
    ├── Profile/       hero, visual sources, analysis, dimension cards
    └── Shared/        the Ask Glance assistant sheet
```

### Design system

Tokens are lifted straight from the `Foundations` frames, so the names in code match the names in Figma:

- **Colour** — `GlanceColor`. Hierarchy comes from white-opacity levels, not separate greys.
- **Type** — `GlanceTextStyle`. Two voices: **Inter** for UI (labels, data, actions) and **Libre Caslon Text** for editorial (headlines, quotes, occasion moments). Never mix voices inside one component. Apply with `.glanceText(.headingXL)`; label styles uppercase themselves.
- **Spacing / radius** — `Space` (4px base grid) and `Radius`.

Both font families are bundled under `Resources/Fonts` and registered at launch by `FontRegistration`, so there is no `UIAppFonts` list to keep in sync.

### Data

Every screen reads through a repository protocol (`FeedRepository`, `ProfileRepository`, `ProductRepository`). The mock implementations carry the copy and imagery from the comps. Pointing the app at a real backend means writing one new conformance per protocol — no view changes.

## What's interactive

Working: image and review carousels with page dots, size and colour selection, wishlist toggle, the 30 Day / 3 Months / 6 Months price chart (Swift Charts over generated history), editable profile name, selectable vibe chips, expandable analysis cards, photo-picker visual sources, and the Ask Glance sheet (canned replies via `AskGlanceResponder`).

Visual only for now: "View all reviews", "+5 offers", the recently-viewed button, Start Training, and the `+Add` prompts on unread dimension rows.

An analysis card's call to action ("Find your fit →", "Cuts and Frames →", …) pushes the assistant (731:701) already talking about that reading: the card carries Glance's opening line and the replies it offers, so Body Frame opens on fit and Skin Type on a routine. Chips and typed messages both get canned answers from `AskGlanceResponder`, which names the card they came from. `Start Training` opens the same screen on the first of the banner's four questions, and each answer brings the next one — `ChatTopic` carries `followUps` and a `closing` line, so a topic is either one question or a short interview without the view knowing the difference. The older `AskGlanceView` sheet still backs Product's Ask Glance and Try On; moving those onto this screen is a small follow-up.

## Assets

Images and icons are exported from the Figma file into `Assets.xcassets` — photographs as PNG, icons and illustrations as SVG with vector representation preserved. The brand marks ship as white artwork on black and are screen-blended onto their campaign images.

### Image crops

**Feed card artwork fills from centre.** `ImageCrop`'s default is a centred cover fill and no feed card overrides it. Figma offsets each node's art rect by hand, and reproducing those faithfully made the framing read as off across the feed — bottom-aligned portraits, product shots pushed to one side — so the per-node offsets were dropped.

The crop machinery is still there, because four placements genuinely need it: they frame a **face**, where a centred fill would show a torso instead.

| Placement | Why it crops |
| --- | --- |
| Home header avatar | 40pt circle onto the face |
| Profile hero portrait | 104pt circle onto the face |
| Profile visual-source tile | 82.5pt tile onto the face (338:216) |
| Profile analysis portraits | face / hair / skin close-ups |

Figma frames an image in two steps: an **art rect** (a sized, offset box) and a **cover fill** inside it that may be biased up or down rather than centred. `ImageCrop` restates both in the comp's own points, and `CroppedImage` resolves them against the real container:

```swift
// Figma: art rect 383×399 at (-158, -8) inside an 82.5pt tile
crop: ImageCrop(width: 383, height: 399, x: -158, y: -8, reference: 82.5)
```

Icons and line illustrations stay on `scaledToFit` — they are glyphs, not photography — as does the Date Night flat-lay, which the comp presents whole on a padded panel.

## Notes on the name field

Profile's name is a `TextField` that is **always present**, with the `+Add Name` prompt drawn by hand on top of it. It is not swapped in on tap: creating the field and requesting focus in the same tick drops the request — the field does not exist yet — so the keyboard never opened. The field also takes `maxWidth: .infinity`, because centred text in an empty field leaves only a caret-wide tap target, and the row is padded and given a `contentShape` with its own tap-to-focus so anywhere along it works — attached only while the field is empty, so it cannot steal caret placement from real text. The prompt follows the *text*, not the focus: full strength when the field is empty and idle, a 25% watermark behind the caret while editing an empty field, and gone the moment a character is typed. Clearing the field brings it back.

If focus clearly takes (a live caret) but no keyboard appears, that is the **simulator**, not the app: it thinks a hardware keyboard is attached. `defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false`, then restart the Simulator app itself — rebooting the device does not re-read it.

## Development helpers

`DebugLaunch` reads launch arguments so a screen or scroll position can be opened directly — useful for screenshots and review:

```bash
xcrun simctl launch booted com.glance.styleintelligence --route product --scrollTo 6
```

`--route` accepts `product` or `profile`; `--scrollTo` takes a section index; `--sheet addPhoto` opens Profile's source chooser; `--focus name` puts the caret in the name field; `--chat 0` opens the assistant on that analysis card. They exist because `simctl` cannot tap, and are all compiled out of release builds.

Screenshots can't catch a half-second transition, so to inspect one, slow the animation down and burst-capture:

```bash
xcrun simctl launch booted com.glance.styleintelligence -UIAnimationDragCoefficient 40 --route product
```

## Notes

- The feed follows the redrawn Home page (`28037:12124`, *Surface Art Playground*), laid out on a 412pt frame as **24 / 170 / 24 / 170 / 24** — so gutter and column gap are both 24 and the columns take what is left, 165pt on a 402pt screen. That is a deliberate change from the earlier 440pt comp, which was mapped with 16pt gutters to protect a 180pt card width; the new frame states the margins outright, so they win.
- Card furniture from that page: a **wishlist heart** top-right on every card (`WishlistButton` — outlined on the artwork, filled red once tapped, state per card until a wishlist repository exists), a **price pill** with the struck-out original, and a **trending tag** (`TrendingTag`, 28119:1632 — `white 5%` over a blur, a 0.5px white hairline, 4pt radius, 10pt SemiBold beside the arrow) carried as `note` on the model. The look card can lead its tag with a social read (`2.2K LIKE DIOR · BEAUTY`) and offer an action chip (`Style Me`); when that prefix is present the match score is dropped, since all three will not fit 165pt. The AI spark badge moved to the leading corner to give the heart the trailing one.
- `TrendCard` now carries its own `tint` — the comp gives the Lakme story maroon and the Met Gala one navy — and its story line is the **same** `TrendingTag` as the artwork pills. One component for both on purpose: they were two treatments before — a dark scrim on artwork, a tinted gradient on the panel — and drifted the moment the tag was redesigned.
- `SignalCard` (`TRAIN YOUR AI`) is the one card that asks: the viewer's portrait beside the label, a serif question, and the answers as capsule rows. It holds all three states itself — question, the answer as given, then Glance's acknowledgement — so a tap resolves in place rather than opening anything. The acknowledgement is a format string on the model, which keeps the wording with the content.
- Both columns are pinned to that measured width. Left to itself an `HStack` hands extra room to whichever column holds the longest unbreakable word, starving the other.
- **Vertical rhythm:** 24pt between stacked cards, halved to 12pt below any card drawn with `BubbleShape` — its tail already hangs into the space beneath the body, so a full 24pt reads as a wider break. Gaps are applied as per-card bottom padding rather than uniform stack spacing, since spacing can't vary by neighbour. `FeedItem.hasTail` decides; a full-width block inherits its card's gap.
- `BubbleShape` traces one continuous outline. Filling a rounded rect and a tail triangle as two subpaths leaves a transparent hairline at the joint: they wind in opposite directions, so the non-zero fill rule cancels their overlap to zero.
- Card placement is declared per column in `MockFeedRepository` rather than derived by a shortest-column heuristic, so it matches the hand-laid-out comp exactly.
- The product card's image container is a strict 3:4 (`Product Cards`, 321:117) and its `Rational` text block has no top padding.
- That component also defines a price pill — 16pt in from the leading edge, 8pt up from the image's bottom. `RationalCard.price` still renders it, but the current `Home` frame (321:518) sets no prices, so nothing shows one. Set `price:` on a card to bring it back.
- Brand card artwork ships flattened: the wordmark and bottom scrim are baked into the image, so the view composites nothing over it. Only the caption and the folded page corner are drawn.
- Profile's `Glow` (338:174) is **not** a purple gradient — it is a dark arch, filled with the page's own near-black, lit only at its rim. `ArchGlow` draws a 640pt rounded-top rect (crown radius 320, a true semicircle) with an outer halo above the crown and a `RadialGradient` centred on the crown circle for the inner spill. Sampling the comp showed that spill is purely a function of distance from that circle's centre, so one radial gradient reproduces all three of Figma's stacked inset shadows.
- The comp is a still. The glow's only motion is the scroll response — the layer dims to 55% and drifts up at 0.08× (`onScrollGeometryChange`) — plus a slow 7.5s breath in the rim. An idle sweep of light along the crown was tried and taken back out. Everything animates opacity, offset or scale, so the render server handles it and the blurred layers are never redrawn; `accessibilityReduceMotion` skips the breath and keeps the scroll response.
- It is attached as an `overlay` on a greedy `Color`, never as a `ZStack` sibling: a ZStack sizes to its tallest child, and a background gets centred in its slot, which would shove the crown hundreds of points off the top of the screen.
- On the analysis cards the metric chip is painted **before** the portrait, so the circle occludes the chip's leading end. Figma orders it that way among its siblings; layering it after covers her hair.
- `PERSONAL ANAYLSIS` (631:777) is four 240×263 cards — Body, Face, Skin, Hair — at a 12pt gap. 263 is a floor rather than a fixed height and the content is top aligned, which reproduces the comp's ~3pt of slack under the call-to-action pill and still lets an expanded card grow. The reading block claims the comp's 55pt as a minimum for the same reason.
- Skin and Hair render their circle from a **source photo plus a crop**, not a pre-rendered circle like Body and Face. Figma stacks two fills inside those 76pt circles — a base cover fill and a second, much larger image laid over it — and only the overlay is visible, so `AnalysisCard.crop` restates the overlay's art rect: 204×163 at (-52.74, -54) for Skin, 129×103 at (-12.74, -24) for Hair. That is what lands the circle on her cheek and on the back of her hair rather than on a whole portrait.
- Those two nodes cannot be exported: `get_screenshot` and `download_assets` both return a 149-byte 1×1 PNG for them, which looks exactly like an empty layer. It isn't — the fills are there in `get_design_context`. Reach for the design context, not the export, when a node comes back empty.
- Each card now carries its own call to action ("Find your fit →", "Build your routine →"), and that pill is still the expand toggle — the label switches to "Show less ←" while open.
- The mascot (338:310) is drawn by `MascotView` from a **blur-free** asset: the comp's blurred ground ellipse (`feGaussianBlur stdDeviation="12"`) and the inner-shadow filters are stripped, leaving the body path with its `#AC42D6 → #6032FF` gradient plus the two white eyes. Keeping the glow was a dead end — Figma's PNG export bakes the canvas in as opaque pixels (a dark rectangle over every card), and keying it out reintroduced haze wherever the un-composite divided by a near-zero alpha.
- Inside the comp's 48pt frame that body measures 34.34×27.43 at (7.5, 10.5). `MascotView` keeps those numbers and scales them from its `size`, rather than stretching the artwork to fill a square — the body's aspect is 1.25:1, so filling a square distorts the character.
- Profile's visual-source strip (`Images`, 338:213) uses **fixed 82.5pt tiles at a 12pt gap**, not tiles stretched to fill. Five of them total 460.5pt inside a 354pt frame, so the row scrolls horizontally and the trailing "add another" tile deliberately sits past the edge. The filled tile carries its own `ImageCrop` (art rect 383×399 at (-158, -8)) which frames the portrait on the face; letting it merely cover the tile shows the whole seated figure instead.
- The composer (`Bottom New`, 406:1419) is `AskGlanceBar`, shared by Home and Product. Product passes its suggestion chips as the `accessory` row above the pill; Home uses the chip-free convenience initialiser. Both hosts ignore the bottom safe area so the pill sits a fixed 24pt from the **physical** bottom edge rather than from the home indicator, and each leaves `AskGlanceBarMetrics.reservedHeight` of bottom padding so its last item clears the bar. The metrics live outside the generic view so callers can read them without naming a concrete `Accessory`.
- Its band grades to `#000000` as the comp specifies, over a **progressive blur** — three masked `.ultraThinMaterial` layers, each starting lower than the last, so the softening deepens toward the bar the way iOS's own scroll-edge effect does. The earlier hard-edged look came from a separate solid fill under the home indicator, not from this ramp; the band now bleeds upward as a background, which costs no layout.
- Inset shadows (`shadow(inset 0 0 R colour)`) go through `innerGlow(_:radius:color:)`, never a blurred `strokeBorder`. `strokeBorder` sits wholly inside the shape, so blurring it drags the light's peak ~10pt inward and smears the falloff over roughly twice the distance — the card reads as a broad vignette instead of a lit rim. Stroking *centred* on the path and clipping back to the shape keeps the maximum on the boundary, which is what an inset shadow does. Calibrated against `training-banner` (338:308): the comp peaks just inside the border and reaches the flat fill ~28pt in, and the build now tracks that to within 7 of 255 levels.
- The trending card is the one component from a **different library** — `Trending News Card`, 27948:7574 in *Surface Art Playground* — so it does not inherit this project's foundations. It replaced the older image-and-headline card: a deep maroon `#220605` panel, the photograph at the comp's 364:322, a half-transparent maroon gradient bar over a blur naming the story, the headline, then the three tools. Three notes on the translation: its **Manrope** headline is set in Inter Medium, the nearest bundled face (say the word and I'll bundle Manrope properly); the panel keeps Glance's own photograph and headline rather than that file's placeholder copy, with the pill carrying the story line; and the card has **no tail**, so `.trend` is no longer in `FeedItem.hasTail` and the feed gives it a full 24pt beneath.
- Its chips are the same `GlanceChip`, on a new `tone: .plain` — a borderless `white 4%` wash. The outlined tone the product screen uses is untouched.
- Product and Profile pin their header with `.safeAreaInset(edge: .top)` and hide `UINavigationBar`. The inset pins the bar and insets the content, but the scroll view still draws *behind* it, so the blur has live content passing underneath. Glyphs are SF Symbols in white.
- Both the pinned headers and the bottom composer sit on `EdgeScrim`: a progressive blur (stacked masked material layers, each reaching a little less far than the last) plus a ramp to `#000000`, anchored to one edge and falling away from it. A single uniform material ends abruptly and draws a crisp line across the content. Stops are authored as distance from the anchored edge, so the bottom-anchored case just mirrors them — one implementation, so the two edges cannot drift apart. Both ends grade to `#000000`. What differs is how long they hold it: the bottom band holds nothing and ramps the whole way, and a header holds only its top 18% — the status-bar strip is true black, and by the title the ramp has already given way to blur, so content passes behind the bar instead of vanishing under it. Holding black across the whole bar (0.7, as it was first built) turns the top of the screen into a slab; watering the colour down instead just leaves the material's grey showing.
- That header is deliberately **not** in the toolbar. `UINavigationBar` runs its own push animation, sliding its items in from the trailing edge, which fights the zoom transition — you get the page expanding out of the card while the bar slides in sideways. Owning the header puts it inside the zoomed content, so it expands with everything else.
- Its tool chips scroll rather than wrap, since three chips laid out for 440pt do not fit 402pt.
- A dimension card's blocks stand **44pt** apart, not 16: Figma pads each block 16 inside its own frame and leaves 12 between frames (689:1053 / 1076 / 1099), and reading only the frame gap collapses the card. The last block's own 16 plus the card's 24 puts the final row 40pt clear of the completeness bar on the bottom edge.
- The Occasion card's `FREQUENCY` block is the one **editable** read on the screen, so it has its own block case (`.frequency`) and its own view rather than bending the static `.meters` renderer. It reads as two lists, each under a heading that names its source, so no row repeats it as a tag. Under `AI READ` sits only what Glance actually inferred — fixed, since that is the app reporting itself, and taps do nothing to it. Under `YOU` sits everything the viewer has a say in: what they have set (amber — tap the track to step Low → Medium → High, × to hand it back), then the occasions Glance has nothing on, each offering `+Add`. Adding starts a row at Medium and moves it up within the section; removing returns it to its seeded place among the rest. With nothing set, `YOU` carries a line saying so. The amber has no Foundations token — it comes from the interaction spec — so it lives in that view, not `GlanceColor`.
- Edits live in the view's own state, seeded from the repository. Persisting them is one conformance away: the seed already arrives through `ProfileRepository`, so a writable store slots in behind the same rows.
- Profile follows `V1 - Profile` (689:881). Against the earlier comps that means: no "gap spotted" panels inside the dimension cards, `AI READ` rows reading **High / Medium / Low** over a track rather than a percentage, and unread rows (Events, Party, Traditionals) offering a `+Add` pill instead. `MeterRow` carries both — `reading` for the word, `percent` for the track — and `nil` on either drops that half.
- Tapping a visual-source tile opens `Add Photo` (693:181), which then routes to the camera or the library. It is **not** a `.sheet`: the comp calls for a plain black 70% scrim, and `.sheet` owns its own dimming, so the sheet is an overlay on `ProfileView` with a move transition and a drag-down-to-dismiss gesture. The camera goes through `UIImagePickerController` (SwiftUI has no capture of its own) and needs `NSCameraUsageDescription`, which the project sets as a build setting; it is unavailable in the simulator, where that option just closes the sheet.
- Two of the four analysis portraits cannot be exported: asking Figma to render the Skin or Hair circle returns a 149-byte 1×1 PNG. Their source photographs come back fine through `download_assets`, so those two cards frame the source with an `ImageCrop` taken from the node's own numbers (`204×163` centred at `+11.26, -10.5` for Skin), while Body and Face use the pre-rendered circles Figma does export.
