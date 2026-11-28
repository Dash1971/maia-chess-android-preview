# Model licence and provenance

**Trained models are licensed under [AGPL-3.0-only](LICENSE.txt), the same as the
code.**

The model files are published as a [release](https://github.com/Dash1971/open-board-scanner/releases/tag/models-v1). This page states the
terms they carry and, separately, what they were trained on.

## What the models were trained on

- **Rendered boards in openly licensed piece sets and fonts.**
- **Rendered boards in sixteen Lichess piece sets licensed CC BY-NC-SA**, for
  noncommercial use. From BoardNet v4 on. They are listed in
  [THIRD_PARTY.md](https://github.com/Dash1971/open-board-scanner/blob/dee0475dfc2cda96c0f6aa50e003536d53592ab1/THIRD_PARTY.md).
- **Photographs of diagrams in copyrighted books and e-books.** From BoardNet
  v2 on. The photographs are not distributed.

The models contain none of this artwork or these photographs. They output
piece positions only.

## What we do and do not claim

- **We do not claim the training data restricts how the models may be used.**
  Whether a trained model is a derivative of its training images is not
  settled in law, and we treat ours as not being one.
- **We do not claim it is settled the other way either.** Anyone planning a
  commercial use should take their own advice.
- **We say plainly what went in**, so that nobody has to guess.

## Why the noncommercial sets are there

Without them the reader got 388 of 850 screen boards drawn in those sets
right. With them it gets 800. They include some of the most used pieces on
Lichess.

A model trained without them can be made from this repository:
`python -m train.make_crops --sets open` generates training data from the
openly licensed sets only.

## Status

Inclusion in Mobile Maia is pending a review of the licensing implications.
