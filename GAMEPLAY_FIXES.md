# Gameplay fixes

Branch: `codex/gameplay-fixes`, based on `0189987`.

## Betting behavior

- Circles uses distinct guesses: probability is `min(guesses, eligibleCircles) / eligibleCircles`. Net odds are `(eligibleCircles - guesses) / guesses`, clamped to zero when a win is guaranteed. The old calculation assumed repeated guesses and treated the total-return multiplier as net profit.
- For 250 circles and six guesses, the chance is 2.4%; net odds are about 40.67 to 1. A 10-coin stake earns 406 whole coins of profit, returning 416 coins in total.
- Stakes are now deducted at placement. Payouts are locked at placement and cannot grow after an incorrect guess. A loss does not deduct the stake again.
- Winning returns the stake plus profit. Cancellation returns one third of the stake, rounded down, consistently across both games and trivia. Cancellation losses are recorded.
- Power-ups are disabled during an active game bet. Finish or cancel the bet before changing the board.
- True/false questions pay 1 to 1; four-choice questions pay 3 to 1. The actual answer count determines the quote.
- Displayed whole-coin returns match settlement. Invalid and overflowing wagers are rejected. Floating-point noise immediately below a whole coin does not remove an extra coin.
- Active wagers remain transient, as game rounds already were. Leaving or terminating an unfinished game forfeits its reserved stake; the rules now disclose this. Abandoned rounds still do not contribute to the existing completed-round statistics.

## Gameplay and reliability

- Circle ID `99` no longer collides with the unselected-winner sentinel.
- Squares always chooses a fresh target for a new guess, except the second attempt of Two Guesses. Other active power-ups cannot accidentally retain an obsolete target.
- Squares scores successful progress, rather than counting missed attempts as points.
- Circles Trivia Mania uses power-up ID `5`, not the quadrant hint's ID `9`. Both games award the full Mania result even when all questions are answered correctly.
- Circle trivia removes up to the advertised number of incorrect circles and preserves the winner, instead of unexpectedly halving a small remaining board.
- Trivia handles HTTP failures, malformed/empty responses, and API errors with retry or cancellation. Canceling a failed load returns the power-up and its cost.
- Trivia state updates on the main actor. Old responses are discarded; stale or duplicate answer selections are rejected. Trivia cannot be swiped away to evade the result.
- Ad continuations require an earned reward. Load failures, presentation failures, and skipped ads complete the pending callback without granting a continuation. Failed coin ads can be retried.
- Loss transitions block further game actions. Returning from a presentation does not reinitialize an already-started board.
- Power-up affordability checks no longer permanently lock an unused power-up. Each game gets its own mutable power-ups.
- Player/stat reset defaults are fresh objects. Startup fills absent saved fields and missing power-up stat entries without replacing existing balances or records. No persisted model properties were added or removed.
- Home waits for its initial player query instead of indexing an empty array.
- The disabled Patterns mode has bounds and score-progression fixes; it remains disabled.

## Validation

On Windows: parsed all Swift files using the tree-sitter Swift grammar; no syntax errors. Checked the Git diff for whitespace errors. Independently checked the probability model by enumerating distinct guesses on small boards and compared whole-coin rounding against integer arithmetic for 13,804 board/guess/stake combinations.

`How LuckyTests/RegressionTests.swift` adds 21 Swift Testing tests for odds, stake settlement, rounding, invalid wagers, independent defaults, save repair, trivia failures, and duplicate answer protection. The local Windows checks were followed by successful Xcode 26.6 compilation and simulator execution on GitHub Actions. All test suites passed. See the TestFlight validation section below; hands-on device/UI checks remain pending.

## Before releasing from a Mac

1. Open `How Lucky.xcodeproj`, choose the `How Lucky` scheme and an installed iOS simulator, then run Product > Test. Build for the supported iOS deployment target as well.
2. Upgrade an installation containing existing coins and records. Confirm balances/highscores survive, missing stats are repaired, and resets work repeatedly. Test cold launch and relaunch.
3. Place, win, lose, and cancel bets in both games and trivia. Confirm the quote stays fixed after a missed circle and that power-ups are disabled while betting. Check cancellation of 1-, 2-, and 30-coin stakes, guaranteed-win boards, and insufficient funds.
4. Exercise each power-up, Two Guesses after a miss, and Free Pass. Complete Mania with zero correct answers, a partial streak, and all questions correct. Confirm Circles results affect Mania stats rather than quadrant stats.
5. Test offline trivia, server errors, retry, and cancel/refund. Repeatedly tap an answer and verify only one result is recorded.
6. Using AdMob test ads, test an earned reward, early dismissal, load failure, and presentation failure. Verify a skipped/failed continuation ends the round and no ad reward is delivered twice.
7. Check iPhone/iPad layouts and light/dark mode, especially the longer betting rules and trivia error controls.

Existing high scores are retained even if earned under the former scoring rules. This change does not reconstruct historical statistics affected by the old bugs.

## Second sweep

- Closing the ad-continuation dialog by tapping outside or using X now takes the same loss path as No. Dialog decisions execute once, preventing duplicate callbacks during dismissal.
- Power-up actions run after the selection sheet finishes dismissing. This avoids overlapping trivia/ad presentations; rapid selection only accepts the first choice.
- Daily rewards use a single 24-hour eligibility check and are rechecked when the player query arrives or the visible home screen returns to the foreground. Repeated callbacks cannot grant duplicate rewards, and nil timestamps/coin overflow are handled.
- Circle placement uses actual game-board bounds. Resizing preserves circle identities, the chosen winner, and game progress; hints are recalculated consistently. Circles fit inside the available area, including narrow windows. Circle views use their own IDs instead of array offsets.
- Decorative result overlays and quadrant outlines do not intercept gameplay taps.
- Trivia requests use the API's documented RFC 3986 encoding, decoded once into plain text. This preserves quotation marks, Unicode, plus/percent signs, and literal Markdown characters. Question identities are stable. API rate-limit errors explain the five-second wait. Reference: [Open Trivia DB documentation](https://opentdb.com/api_config.php).
- Power-up and trivia content scrolls so long questions and controls remain reachable on smaller screens.
- A successful trivia answer or Free Pass consumes an active Two Guesses effect, preventing its stale target from carrying into the next round.
- Fixed red-channel parsing for three-digit hex colors.

Added four regression tests for daily-reward boundaries/duplicate claims, missing dates/overflow, circle resize bounds/identity, and trivia decoding/identity. All 44 Swift files were syntax-parsed again without errors; subsequent GitHub Actions runs passed Xcode type checking and unit tests. Manual UI verification remains pending.

Additional manual checks: dismiss the ad-continue prompt using X and the backdrop; repeatedly select trivia from the power-up sheet; background/foreground the home screen across a reward boundary; rotate and resize Circles with an active quadrant hint/bet; check long trivia questions at larger text sizes; and use Two Guesses followed by trivia or Free Pass before making another square guess.

## Third sweep: Squares and Circles

Squares:
- 50/50 now saves the actual pre-power-up board size, rather than deriving it from the score. It restores that size and adds the next square after any successful guess, trivia result, or Free Pass.
- Lucky Restart discards a pending 50/50 restoration. Reusing 50/50 after Reset Power-Ups keeps the original restoration size. Loss/reset clears temporary board state.
- Replacing a board with Two Guesses active starts a fresh two-attempt target, and repeated power-up activation no longer leaves duplicate active entries.

Circles:
- Cut in Half removes half of the complete board (250 becomes 125; two becomes one), always preserving the winner.
- Circle-removal power-ups choose random incorrect circles, avoiding information leakage from deterministic array-order removal.
- Color-removal eligibility is checked before charging coins, counting usage, or locking the power-up. Impossible uses preserve the power-up and explain why.
- Losing bets settle immediately when the last guess fails, independently of the winner-reveal animation.
- Circle-count and coin-change popups use separate state, so overlapping messages cannot overwrite each other's amounts.

Both games:
- Taps on disabled, removed, or replaced piece objects are ignored.
- Failed/skipped coin ads roll back power-up usage counters as well as unlocking the retry.
- Coin animations restart for each new event; older dismissal callbacks cannot hide a newer popup.

Six additional regression tests cover 50/50 plus Lucky Restart/reuse/reset, exact halving and winner preservation, capped trivia removal, and unavailable color removal. All 44 Swift files passed syntax parsing and the diff passed whitespace checks. The 21 regression tests subsequently passed in the GitHub-hosted iOS simulator.

Additional Mac checks: combine 50/50 with Lucky Restart, Two Guesses, trivia and Free Pass; reuse 50/50 after resetting power-ups; try Remove Three Colors when fewer than three non-winning colors remain; tap quickly during round transitions; and trigger circle-count changes while a coin popup is still visible.

## Game UI refresh

- Shared score dashboard keeps current score, best score, coins, remaining guesses, and board count visible. Short screens use a compact dashboard.
- Squares uses coral accents and an adaptive, scrollable grid (two to six columns depending on board size and available width). Tiles scale with the grid and distinguish available, tried, and revealed-winning states. Large accessibility text uses fewer columns.
- Circles uses teal accents, a padded play area sized separately from the dashboard/actions, and ten consistent colors. The winner's checkmark appears only during the loss reveal, never during active play.
- Both games have a bottom action bar for betting and power-ups, an explicit active-bet label, and a dedicated result/status strip. Large score flashes and popups no longer cover the board. Score gains receive inline feedback.
- Power-ups use an adaptive card layout with visible descriptions, costs, used states, and affordability messages. Long-press discovery is no longer required.
- Betting has a scrollable card, quick amount buttons, a labeled amount field, separate profit/total-return figures, keyboard dismissal, and a dedicated rules sheet. Existing stake/odds/settlement rules are retained.
- Confirmation dialogs, trivia answers, and backgrounds use semantic colors for light/dark mode. Square transitions respect Reduce Motion. Both boards provide labeled accessibility elements.
- New `GameInterface.swift` houses reusable dashboard, palette, notice, and rules components for future game screens. Existing navigation hosts the boards without an extra nested navigation stack.

Validation: Swift syntax parsing and diff whitespace checks passed. Grid sizing was checked arithmetically over representative phone/tablet widths and board sizes. Xcode 26.6 subsequently type-checked the app and passed the regression tests on GitHub Actions. Manual visual verification remains pending; use the included SwiftUI previews or the TestFlight build.

Visual checklist on Mac: small iPhone and iPad; portrait/landscape and split view; light/dark modes; large text and Reduce Motion; Squares boards with 2, 9, 25 and 100 tiles; all 250 Circles and a quadrant reveal; keyboard open in betting; long power-up descriptions; active bets, ad loading, wins/losses, and rapid result updates. Verify that circle targets and hints survive resizing and that rules, betting, and power-up sheets dismiss correctly.

## TestFlight validation — September 27, 2026

- GitHub Actions successfully compiled and ran the unit-test suites with Xcode 26.6.
- The Mac compiler exposed two misplaced square-tap guards in the trivia callback and an obsolete `SwiftUICore` import. Both are fixed.
- Version 2.2 (build 1) was archived with the existing FooWibble distribution certificate and a new app-specific provisioning profile, then successfully uploaded to Apple.
- [Build, tests, and upload evidence](https://github.com/peytonlwhite/How-Lucky/actions/runs/36368386267).
- Export reported missing vendor dSYM files for GoogleMobileAds and UserMessagingPlatform. Upload succeeded; crashes inside those vendor frameworks may have incomplete symbol names.
- The encryption-exemption metadata matches the existing live build. The workflow uploads for internal testing only.
- [Future upload instructions](docs/TESTFLIGHT.md). The device, upgrade, ad-flow, and visual checklists above remain necessary before an App Store release.

## Simpler game layout

- Replaced the dashboard card with a small two-line score/guesses header.
- Removed repeated game headings, board outlines, and boxed status messages.
- Larger starting squares are centered; growing boards still scroll.
- Reduced Circles padding so the play area fills more of the screen.
- Added an iPhone UI check for board height and reachable power-up controls, with screenshot artifacts for visual inspection.
- Gameplay, odds, coin accounting, and power-ups are unchanged by this layout pass.
