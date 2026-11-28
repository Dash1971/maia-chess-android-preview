// SPDX-License-Identifier: AGPL-3.0-only
// Dart port of Open Brilly Finder's Mute Exchange reference at 59cab58a8b63387d9775252f03a6875fe451f697.
// See THIRD_PARTY_NOTICES.md and docs/OPEN_BRILLY_FINDER_27.md.
import 'dart:convert';
import 'dart:math' as math;

import 'package:dartchess/dartchess.dart' as dc;

class ExchangeLine {
  const ExchangeLine(this.uci, this.cp);
  final String uci;
  final num cp;
}

class ExchangeEvidence {
  const ExchangeEvidence(this.before, this.afterCp, this.reply);
  final List<ExchangeLine> before;
  final num afterCp;
  final String? reply;
}

class ExchangeDecision {
  const ExchangeDecision(this.candidate, this.score, this.brilliant);
  static const none = ExchangeDecision(false, 0, false);
  final bool candidate;
  final double score;
  final bool brilliant;
}

/// A small tree model, not a calibrated probability or a chess engine.
class BrilliantExchangeModel {
  BrilliantExchangeModel.fromJson(String source) {
    final data = jsonDecode(source) as Map<String, dynamic>;
    features = (data['features'] as List).cast<String>();
    baseline = (data['baseline'] as num).toDouble();
    cutoff = (data['cutoff'] as num).toDouble();
    trees = (data['trees'] as List).cast<Map<String, dynamic>>();
    if (features.length != 91 ||
        trees.length != 222 ||
        cutoff != 0.8193002847777424 ||
        !baseline.isFinite) {
      throw const FormatException('Unexpected Mute Exchange model');
    }
    for (final t in trees) {
      final n = (t['f'] as List).length;
      if (n == 0 ||
          ['t', 'l', 'r', 'v', 'leaf'].any((k) => (t[k] as List).length != n)) {
        throw const FormatException('Invalid tree arrays');
      }
      for (var i = 0; i < n; i++) {
        if (t['leaf'][i] == 0 &&
            (t['f'][i] < 0 ||
                t['f'][i] >= 91 ||
                t['l'][i] <= i ||
                t['r'][i] <= i ||
                t['l'][i] >= n ||
                t['r'][i] >= n)) {
          throw const FormatException('Invalid tree node');
        }
      }
    }
  }
  late final List<String> features;
  late final double baseline, cutoff;
  late final List<Map<String, dynamic>> trees;

  double score(Map<String, num> values) {
    final x = features.map((k) => values[k]).toList(growable: false);
    if (x.any((v) => v == null || !v.isFinite)) {
      throw const FormatException('Missing or non-finite exchange feature');
    }
    var raw = baseline;
    for (final t in trees) {
      var i = 0;
      while (t['leaf'][i] == 0) {
        i = x[t['f'][i] as int]! <= (t['t'][i] as num)
            ? t['l'][i] as int
            : t['r'][i] as int;
      }
      raw += (t['v'][i] as num).toDouble();
    }
    return 1 / (1 + math.exp(-raw));
  }
}

class _EMove {
  _EMove(
    this.position,
    this.move,
    this.to,
    this.role,
    this.capture,
    this.ep,
    this.castle,
  );
  final dc.Position position;
  final dc.NormalMove move;
  final dc.Square to;
  final dc.Role role;
  final bool capture, ep, castle;
  dc.Square get from => move.from;
  late final dc.Position next = position.playUnchecked(move);
  String get key => '${from.value}-${to.value}-${move.promotion?.name ?? ''}';
  String get uci => '${from.name}${to.name}${move.promotion?.letter ?? ''}';
}

typedef _Offer = ({dc.Square square, int type, int attacker, int gain});

/// One evaluator per worker/run. Caches board work, not engine evaluations.
class BrilliantExchange {
  BrilliantExchange(this.model);
  final BrilliantExchangeModel model;
  final _moveCache = Map<dc.Position, List<_EMove>>.identity();
  final _offerCache = Map<dc.Position, Map<dc.Side, List<_Offer>>>.identity();
  final _boardFeatures = <String, Map<String, num>?>{};
  static const _value = {
    dc.Role.pawn: 1,
    dc.Role.knight: 3,
    dc.Role.bishop: 3,
    dc.Role.rook: 5,
    dc.Role.queen: 9,
    dc.Role.king: 100,
  };
  static const _type = {
    dc.Role.pawn: 1,
    dc.Role.knight: 2,
    dc.Role.bishop: 3,
    dc.Role.rook: 4,
    dc.Role.queen: 5,
    dc.Role.king: 6,
  };

  static int lineCp({required int cp, int? mate, required bool moverIsWhite}) {
    final pov = moverIsWhite ? 1 : -1;
    if (mate != null) {
      final n = mate * pov;
      return n == 0 ? -10000 : (10000 - math.min(n.abs(), 99) * 10) * n.sign;
    }
    return (cp * pov).clamp(-9000, 9000);
  }

  List<_EMove> _moves(dc.Position p) => _moveCache.putIfAbsent(p, () {
    final dests = p.legalMoves;
    final out = <_EMove>[], pawns = <_EMove>[], eps = <_EMove>[];
    void push(dc.Square from, dc.Square to, dc.Role role, List<_EMove> list) {
      final target = p.board.pieceAt(to);
      final castle = role == dc.Role.king && target?.color == p.turn;
      final ep =
          role == dc.Role.pawn &&
          to == p.epSquare &&
          target == null &&
          from.file != to.file;
      final capture = ep || (target != null && target.color != p.turn);
      final standard = castle
          ? dc.Square(from.value + (to > from ? 2 : -2))
          : to;
      final promotions = role == dc.Role.pawn && (to < 8 || to >= 56)
          ? <dc.Role?>[
              dc.Role.queen,
              dc.Role.rook,
              dc.Role.bishop,
              dc.Role.knight,
            ]
          : <dc.Role?>[null];
      for (final promotion in promotions) {
        (ep ? eps : list).add(
          _EMove(
            p,
            dc.NormalMove(from: from, to: to, promotion: promotion),
            standard,
            role,
            capture,
            ep,
            castle,
          ),
        );
      }
    }

    void pieces(bool includeKing) {
      for (final from
          in p.board.bySide(p.turn).diff(p.board.pawns).squaresReversed) {
        final role = p.board.roleAt(from)!;
        if (role == dc.Role.king && !includeKing) continue;
        final castles = <_EMove>[];
        for (final to in (dests[from] ?? dc.SquareSet.empty).squaresReversed) {
          push(
            from,
            to,
            role,
            role == dc.Role.king && p.board.sideAt(to) == p.turn
                ? castles
                : out,
          );
        }
        out.addAll(castles);
      }
    }

    if (p.isCheck) {
      final king = p.board.kingOf(p.turn)!;
      for (final to in (dests[king] ?? dc.SquareSet.empty).squaresReversed) {
        push(king, to, dc.Role.king, out);
      }
      pieces(false);
    } else {
      pieces(true);
    }
    for (final from in p.board.piecesOf(p.turn, dc.Role.pawn).squaresReversed) {
      for (final to in (dests[from] ?? dc.SquareSet.empty).squaresReversed) {
        push(
          from,
          to,
          dc.Role.pawn,
          p.board.pieceAt(to) != null || to == p.epSquare ? out : pawns,
        );
      }
    }
    return [...out, ...pawns, ...eps];
  });
  int _gain(dc.Position p, _EMove m) =>
      (!m.castle && p.board.pieceAt(m.to) != null
          ? _value[p.board.roleAt(m.to)]!
          : m.ep
          ? 1
          : 0) +
      (m.move.promotion == null ? 0 : _value[m.move.promotion]! - 1);
  int _seeAfter(dc.Position p, dc.Square square) {
    if (p.board.pieceAt(square) == null) return 0;
    _EMove? best;
    for (final m in _moves(p)) {
      if (!m.castle &&
          !m.ep &&
          m.to == square &&
          (best == null || _value[m.role]! < _value[best.role]!)) {
        best = m;
      }
    }
    return best == null ? 0 : math.max(0, _seeCapture(p, best));
  }

  int _seeCapture(dc.Position p, _EMove m) =>
      _gain(p, m) - (m.next.isCheckmate ? 0 : _seeAfter(m.next, m.to));
  List<_Offer> _offers(dc.Position p, dc.Side color) =>
      (_offerCache[p] ??= {}).putIfAbsent(color, () {
        final out = <dc.Square, _Offer>{};
        for (final m in _moves(p)) {
          if (m.castle) continue;
          final t = p.board.pieceAt(m.to);
          if (t == null || t.color != color || t.role == dc.Role.pawn) continue;
          final gain = _seeCapture(p, m);
          if (out[m.to] == null || gain > out[m.to]!.gain) {
            out[m.to] = (
              square: m.to,
              type: _type[t.role]!,
              attacker: _type[m.role]!,
              gain: gain,
            );
          }
        }
        return out.values.toList(growable: false);
      });
  int _material(dc.Position p, dc.Side side) => [
    dc.Role.pawn,
    dc.Role.knight,
    dc.Role.bishop,
    dc.Role.rook,
    dc.Role.queen,
  ].fold(0, (v, r) => v + _value[r]! * p.board.piecesOf(side, r).size);
  (int, _EMove?) _bestCapture(dc.Position p) {
    var best = 0;
    _EMove? move;
    for (final m in _moves(p)) {
      if (!m.capture) continue;
      final g = _seeCapture(p, m);
      if (g > best) {
        best = g;
        move = m;
      }
    }
    return (best, move);
  }

  bool _mateOne(dc.Position p) => _moves(p).any((m) => m.next.isCheckmate);
  dc.Position? _passed(dc.Position p) {
    final next = p.copyWith(turn: p.turn.opposite, epSquare: null);
    try {
      next.validate();
      return next;
    } on dc.PositionSetupException {
      return null;
    }
  }

  int _qs(dc.Position p, int depth, int alpha, int beta) {
    if (depth == 0) return 0;
    var best = p.isCheck ? -99 : 0;
    if (best >= beta) return best;
    alpha = math.max(alpha, best);
    final all = _moves(p);
    final moves = p.isCheck
        ? all
        : all.where((m) => m.capture || m.move.promotion != null).toList();
    if (p.isCheck && moves.isEmpty) return -99;
    final ordered =
        [
          for (var i = 0; i < moves.length; i++)
            (move: moves[i], gain: _gain(p, moves[i]), order: i),
        ]..sort((a, b) {
          final d = b.gain.compareTo(a.gain);
          return d != 0 ? d : a.order.compareTo(b.order);
        });
    for (final item in ordered) {
      final value =
          item.gain -
          _qs(item.move.next, depth - 1, -beta + item.gain, -alpha + item.gain);
      if (value > best) {
        best = value;
        if (value > alpha) alpha = value;
        if (alpha >= beta) break;
      }
    }
    return best;
  }

  static num _max(Iterable<num> values, num fallback) =>
      values.fold<num?>(null, (v, n) => v == null ? n : math.max(v, n)) ??
      fallback;
  static double _chance(num cp) => 100 / (1 + math.exp(-.00368208 * cp));
  static int _distance(dc.Square a, dc.Square b) =>
      math.max((a.file - b.file).abs(), (a.rank - b.rank).abs());
  static int _b(bool value) => value ? 1 : 0;

  /// All 91 reference features, in named form for differential checks.
  Map<String, num>? features(
    String? fenPrev,
    String fenBefore,
    String uci,
    ExchangeEvidence evidence,
  ) {
    if (evidence.before.isEmpty) return null;
    final key = '${fenPrev ?? ''}|$fenBefore|$uci';
    Map<String, num>? board;
    if (_boardFeatures.containsKey(key)) {
      board = _boardFeatures[key];
    } else {
      // Bound retention to one move window. Recursive positions must not survive
      // for an entire game; current/prior engine iterations share board features.
      _moveCache.clear();
      _offerCache.clear();
      _boardFeatures.clear();
      board = _boardFeatures[key] = _features(fenPrev, fenBefore, uci);
      _moveCache.clear();
      _offerCache.clear();
    }
    if (board == null) return null;
    final f = Map<String, num>.of(board);
    final lines = evidence.before;
    final bestCp = lines.first.cp, playedCp = evidence.afterCp;
    final index = lines.indexWhere((l) => l.uci == uci);
    final alts = lines.where((l) => l.uci != uci).toList();
    f['best_cp'] = bestCp;
    f['best_is_mate'] = _b(bestCp >= 9000);
    f['rank'] = index >= 0 ? index + 1 : 3;
    f['alt_cp'] = alts.isNotEmpty ? alts.first.cp : -9999;
    f['played_cp_before'] = index >= 0 ? lines[index].cp : -9999;
    f['played_cp'] = playedCp;
    f['played_mate'] = _b(playedCp >= 9000);
    final best = math.max(bestCp, playedCp);
    f['cp_loss'] = best - playedCp;
    f['wc_best'] = _chance(best);
    f['wc_played'] = _chance(playedCp);
    f['wc_loss'] = f['wc_best']! - f['wc_played']!;
    f['wc_alt'] = alts.isNotEmpty ? _chance(f['alt_cp']!) : 0;
    f['wc_gain_vs_alt'] = f['wc_played']! - f['wc_alt']!;
    // Internal cached fields describe board facts, never enter the model vector.
    f['reply_is_accept'] = _b(
      evidence.reply != null &&
          (board['_hang_squares']!.toInt() &
                  (1 <<
                      dc.Square.parse(evidence.reply!.substring(2, 4))!
                          .value)) !=
              0,
    );
    f['alt_net'] = alts.isNotEmpty ? (board['_alt_${alts.first.uci}'] ?? 0) : 0;
    return f..removeWhere((k, v) => k.startsWith('_'));
  }

  Map<String, num>? _features(String? fenPrev, String fenBefore, String uci) {
    final before = dc.Chess.fromSetup(dc.Setup.parseFen(fenBefore));
    final mover = before.turn, them = mover.opposite;
    final beforeMoves = _moves(before);
    final move = beforeMoves.where((m) => m.uci == uci).firstOrNull;
    if (move == null) return null;
    dc.Position? prev;
    _EMove? oppMove;
    var oppCap = 0;
    if (fenPrev != null) {
      prev = dc.Chess.fromSetup(dc.Setup.parseFen(fenPrev));
      for (final m in _moves(prev)) {
        if (m.next.board.fen != before.board.fen) continue;
        final victim = prev.board.pieceAt(m.to);
        oppCap = !m.castle && victim != null
            ? _value[victim.role]!
            : m.ep
            ? 1
            : 0;
        oppMove = m;
        break;
      }
    }
    final capPiece = before.board.pieceAt(move.to);
    final capVal = !move.castle && capPiece != null
        ? _value[capPiece.role]!
        : move.ep
        ? 1
        : 0;
    final beforePassed = before.isCheck ? null : _passed(before);
    final beforeOffers = beforePassed == null
        ? null
        : _offers(beforePassed, mover);
    final after = move.next;
    final offered = after.isCheckmate ? <_Offer>[] : _offers(after, mover);
    if (!offered.any((o) => o.gain >= 2)) return null;
    final hang = offered.where((o) => o.gain > 0).toList();
    var top = hang.first;
    for (final o in hang) {
      if (o.gain > top.gain || (o.gain == top.gain && o.type > top.type)) {
        top = o;
      }
    }
    final sq = top.square;
    final bo = {for (final o in beforeOffers ?? <_Offer>[]) o.square: o};
    final f = <String, num>{};
    final own = _material(before, mover),
        opp = _material(before, them),
        afterMoves = _moves(after);
    f.addAll({
      'net': capVal - top.gain,
      'hang_see': top.gain,
      'hang_type': top.type,
      'hang_attacker': top.attacker,
      'hang_is_moved': _b(sq == move.to),
      'hang_already_attacked': _b(sq != move.to && bo.containsKey(sq)),
      'hang_already_hanging': _b(
        sq != move.to && bo.containsKey(sq) && bo[sq]!.gain > 0,
      ),
      'before_hang_max': beforeOffers == null
          ? -1
          : _max(beforeOffers.map((o) => o.gain), 0),
      'n_hang': hang.length,
      'hang_sum': hang.fold<int>(0, (s, o) => s + o.gain),
      'n_capturable': offered.length,
      'moved_type': _type[move.role]!,
      'cap_val': capVal,
      'gives_check': _b(after.isCheck),
      'in_check': _b(before.isCheck),
      'promo': move.move.promotion == null ? 0 : _type[move.move.promotion]!,
      'matdiff': own - opp,
      'mat_total': own + opp,
      'mat_own': own,
      'opp_prev_cap': oppCap,
      'recapture': _b(oppMove != null && oppMove.to == move.to && capVal > 0),
      'n_legal': beforeMoves.length,
      'n_replies': afterMoves.length,
    });
    final altNets = <String, int>{};
    for (final m in beforeMoves) {
      if (identical(m, move)) continue;
      final victim = before.board.pieceAt(m.to);
      final cv = !m.castle && victim != null
          ? _value[victim.role]!
          : m.ep
          ? 1
          : 0;
      altNets[m.key] = m.next.isCheckmate
          ? 99
          : cv - _max(_offers(m.next, mover).map((o) => o.gain), 0).toInt();
      f['_alt_${m.uci}'] = altNets[m.key]!;
    }
    final alt = altNets.values.toList();
    f['alt_best_net'] = _max(alt, -99);
    f['alt_safe_frac'] = alt.isEmpty
        ? 0
        : alt.where((v) => v >= 0).length / alt.length;
    f['alt_n_better_net'] = alt.where((v) => v > f['net']!).length;
    f['hang_n_attackers'] = after.kingAttackers(sq, them).size;
    f['hang_n_defenders'] = after.kingAttackers(sq, mover).size;
    f['hang_see_before'] = bo[sq]?.gain ?? (sq != move.to ? 0 : -1);
    f['hang_worsened'] = _b(sq != move.to && top.gain > (bo[sq]?.gain ?? 0));
    f['from_hang'] = bo[move.from]?.gain ?? 0;
    f['moved_safe'] = _b(
      !offered.any((o) => o.square == move.to && o.gain > 0),
    );
    var escape = 0;
    if (sq != move.to) {
      for (final m in beforeMoves) {
        if (m.from != sq) continue;
        final victim = before.board.pieceAt(m.to);
        final cv = !m.castle && victim != null ? _value[victim.role]! : 0;
        final lost = _max(
          _offers(
            m.next,
            mover,
          ).where((o) => o.square == m.to).map((o) => o.gain),
          0,
        );
        if (cv - lost >= 0) {
          escape = 1;
          break;
        }
      }
    }
    f['hang_could_escape'] = escape;
    var threatGain = 0, threatMate = 0;
    _EMove? threatMove;
    if (!after.isCheck) {
      final free = _passed(after);
      if (free != null) {
        (threatGain, threatMove) = _bestCapture(free);
        threatMate = _b(_mateOne(free));
      }
    }
    f.addAll({
      'threat_gain': threatGain,
      'threat_mate1': threatMate,
      'threat_by_moved': _b(threatMove != null && threatMove.from == move.to),
      'threat_minus_hang': threatGain - top.gain,
      'pre_capture_gain': _bestCapture(before).$1,
    });
    final victimValue = _value[after.board.roleAt(sq)]!;
    final accepts = afterMoves
        .where(
          (m) => !m.castle && !m.ep && m.to == sq && _seeCapture(after, m) > 0,
        )
        .toList();
    f['n_accepting'] = accepts.length;
    f['accept_by_king_only'] = _b(
      accepts.isNotEmpty && accepts.every((m) => m.role == dc.Role.king),
    );
    final outcomes =
        <({int net2, int regain, int same, int pre, int mate1, int chk})>[];
    for (final m in accepts) {
      final next = m.next;
      if (next.isCheckmate) continue;
      final (g, bm) = _bestCapture(next);
      outcomes.add((
        net2: capVal - victimValue + g,
        regain: g,
        same: _b(bm != null && bm.to == sq),
        pre: _b(
          bm != null &&
              threatMove != null &&
              bm.to == threatMove.to &&
              bm.to != sq,
        ),
        mate1: _b(_mateOne(next)),
        chk: _b(_moves(next).any((x) => x.next.isCheck)),
      ));
    }
    if (outcomes.isNotEmpty) {
      var worst = outcomes.first;
      for (final o in outcomes) {
        if (o.net2 < worst.net2) worst = o;
      }
      f.addAll({
        'acc_net2_min': worst.net2,
        'acc_net2_max': _max(outcomes.map((o) => o.net2), -9),
        'acc_regain': worst.regain,
        'acc_regain_same_sq': worst.same,
        'acc_regain_pre_threat': worst.pre,
        'acc_mate1_any': _max(outcomes.map((o) => o.mate1), 0),
        'acc_mate1_all': outcomes.map((o) => o.mate1).reduce(math.min),
        'acc_check_avail': worst.chk,
      });
    } else {
      for (final k in [
        'acc_net2_min',
        'acc_net2_max',
        'acc_regain',
        'acc_regain_same_sq',
        'acc_regain_pre_threat',
        'acc_mate1_any',
        'acc_mate1_all',
        'acc_check_avail',
      ]) {
        f[k] = -9;
      }
    }
    final hangSquares = hang.map((o) => o.square).toSet();
    f['_hang_squares'] = hangSquares.fold<int>(0, (s, q) => s | (1 << q.value));
    f['opp_other_gain'] = _max(
      afterMoves
          .where((m) => m.capture && !hangSquares.contains(m.to))
          .map((m) => _seeCapture(after, m)),
      0,
    );
    final movedPiece = after.board.pieceAt(move.to)!;
    f['moved_attacks_higher'] = _b(
      dc.attacks(movedPiece, move.to, after.board.occupied).squares.any((s) {
        final p = after.board.pieceAt(s);
        return p != null &&
            p.color != mover &&
            p.role != dc.Role.king &&
            _value[p.role]! > _value[movedPiece.role]!;
      }),
    );
    final king = after.board.kingOf(them);
    f['king_zone_att'] = 0;
    if (king != null) {
      final zone = dc.kingAttacks(king).withSquare(king);
      f['king_zone_att'] = zone.squares
          .where((z) => after.kingAttackers(z, mover).isNotEmpty)
          .length;
      f['hang_dist_opp_king'] = _distance(sq, king);
      f['to_dist_opp_king'] = _distance(move.to, king);
    } else {
      f['hang_dist_opp_king'] = f['to_dist_opp_king'] = 9;
    }
    for (final depth in [2, 4, 6, 10]) {
      f['qs_net$depth'] = (capVal - _qs(after, depth, -200, 200)).clamp(
        -30,
        30,
      );
    }
    f['qs_before6'] = beforePassed == null
        ? 0
        : (-_qs(beforePassed, 6, -200, 200)).clamp(-30, 30);
    f['qs_delta6'] = f['qs_net6']! - f['qs_before6']!;
    f['qs_own_before6'] = _qs(before, 6, -200, 200).clamp(-30, 30);
    f.addAll({
      'has_prev': 0,
      'hang_age': 0,
      'prev_hang_max': -1,
      'prev_n_hang': 0,
      'origin_offered_prev': 0,
      'origin_offered_prev_see': 0,
      'prev_gives_check': 0,
      'hang_see_prev': 0,
      'hung_was_there_prev': -1,
      'opp_last_attacks_hung': -1,
      'opp_last_cap': -1,
      'opp_last_piece': 0,
      'opp_last_to_hung_sq': 0,
      'opp_last_attacks_origin': -1,
      'opp_last_see_loss': 0,
      'opp_last_discovers_hung': -1,
    });
    if (prev != null && oppMove != null) {
      final po = _offers(prev, mover);
      f['has_prev'] = 1;
      f['prev_hang_max'] = _max(po.map((o) => o.gain), 0);
      f['prev_n_hang'] = po.where((o) => o.gain > 0).length;
      f['hang_age'] = _b(
        sq != move.to &&
            po.any((o) => o.square == sq && o.type == top.type && o.gain > 0),
      );
      f['origin_offered_prev'] = _b(
        po.any((o) => o.square == move.from && o.gain > 0),
      );
      f['origin_offered_prev_see'] = _max(
        po.where((o) => o.square == move.from).map((o) => o.gain),
        0,
      );
      f['prev_gives_check'] = _b(prev.isCheck);
      f['hang_see_prev'] = _max(
        po
            .where((o) => o.square == sq && o.type == top.type)
            .map((o) => o.gain),
        0,
      );
      final there = prev.board.pieceAt(sq);
      f['hung_was_there_prev'] = _b(
        there != null && there.color == mover && _type[there.role] == top.type,
      );
      f['opp_last_piece'] = _type[oppMove.role]!;
      f['opp_last_cap'] = oppCap;
      final attBefore = prev.kingAttackers(sq, them),
          afterOpp = oppMove.next,
          attAfter = afterOpp.kingAttackers(sq, them);
      f['opp_last_attacks_hung'] = _b(attAfter.has(oppMove.to));
      f['opp_last_discovers_hung'] = _b(
        attAfter.diff(attBefore).withoutSquare(oppMove.to).isNotEmpty,
      );
      f['opp_last_attacks_origin'] = _b(
        afterOpp.kingAttackers(move.from, them).has(oppMove.to),
      );
      f['opp_last_to_hung_sq'] = _b(oppMove.to == sq);
      f['opp_last_see_loss'] = _max(
        _offers(afterOpp, them).map((o) => o.gain),
        0,
      );
    }
    return f;
  }

  ExchangeDecision evaluate(
    String? previous,
    String before,
    String uci,
    ExchangeEvidence evidence,
  ) {
    final f = features(previous, before, uci, evidence);
    if (f == null) return ExchangeDecision.none;
    final score = model.score(f);
    return ExchangeDecision(true, score, score >= model.cutoff);
  }
}
