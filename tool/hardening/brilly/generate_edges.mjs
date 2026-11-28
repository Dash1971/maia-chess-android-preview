// SPDX-License-Identifier: AGPL-3.0-only
// Constructed regression vectors; run against the pinned upstream TypeScript.
import { pathToFileURL } from 'node:url';
const { exchangeFeatures, exchangeScore, exchangeModel } =
  await import(pathToFileURL(process.argv[2]).href);
import { writeFileSync } from 'node:fs';
const cases=[];
function add(name,fenBefore,uci,alt,fenPrev,reply) {
  const before=[{uci,cp:100},{uci:alt,cp:0}];
  const after={cp:100,...(reply ? {reply} : {})};
  const features=exchangeFeatures(fenPrev,fenBefore,uci,{before,after});
  const score=features?exchangeScore(features):0;
  cases.push({name,fenPrev:fenPrev??null,fenBefore,uci,before,after,
    features:features??null,score,brilliant:!!features&&score>=exchangeModel.cutoff});
}
for(const promotion of ['q','r','b','n']) {
  add('white promotion '+promotion,'7r/P3k3/8/8/8/8/8/4K3 w - - 0 1','a7a8'+promotion,'e1d1');
  add('black promotion '+promotion,'4k3/8/8/8/8/8/p3K3/7R b - - 0 1','a2a1'+promotion,'e8d8');
}
add('white castle','3k4/8/5b2/8/8/2R5/8/4K2R w K - 0 1','e1g1','e1d1');
add('black castle','r3k3/8/2r5/8/8/5B2/8/7K b q - 0 1','e8c8','e8d8');
add('white en passant','3k3q/8/8/3pP3/7R/8/8/4K3 w - d6 0 1','e5d6','e1d1');
add('black en passant','7Q/4k3/8/7r/3Pp3/8/8/4K3 b - d3 0 1','e4d3','e7d7');
add('en passant with history','3k3q/8/8/3pP3/7R/8/8/4K3 w - d6 0 1','e5d6','e1d1','3k3q/3p4/8/4P3/7R/8/8/4K3 b - - 0 1');
add('illegal pinned rook','k3r2q/8/8/8/7N/8/4R3/4K3 w - - 0 1','e2d2','h4f5');
add('pinned recapture remains legal','k3r2q/8/8/8/7N/8/4R3/4K3 w - - 0 1','h4f5','h4g6');
add('first move no history','rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1','e2e4','d2d4');
// A FEN-start game can offer a piece on its first reply. The reference accepts
// the actual root as history; the training extractor sometimes had no such row.
for (const [color, root, before, move, alt, reply] of [
  ['black','4k3/8/5n2/8/4P3/8/8/4K3 w - - 0 1','4k3/8/5n2/8/4P3/8/8/3K4 b - - 1 1','f6d5','e8d8','e4d5'],
  ['white','4k3/8/8/4p3/8/5N2/8/4K3 b - - 0 1','3k4/8/8/4p3/8/5N2/8/4K3 w - - 1 2','f3d4','e1d1','e5d4'],
]) {
  add(color+' first reply with root history',before,move,alt,root,reply);
  add(color+' FEN-start first move without history',before,move,alt,undefined,reply);
}
add('checkmate has no sacrifice candidate','rnbqkbnr/pppp1ppp/8/4p3/6P1/5P2/PPPPP2P/RNBQKBNR b KQkq g3 0 2','d8h4','g8f6');
writeFileSync(process.argv[3],JSON.stringify({source:'Open Brilly Finder 59cab58a8b63387d9775252f03a6875fe451f697 reference TypeScript',scope:'Constructed legal edge cases with synthetic engine scores; no accuracy claim.',cases},null,2)+'\n');
console.log(cases.map(c=>({name:c.name,candidate:c.features!==null,score:c.score})));
