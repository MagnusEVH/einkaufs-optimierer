// app/lib/features/stores_map/chain_style.dart

import 'package:flutter/material.dart';
import '../../core/models/store.dart';

/// Markenfarbe einer Kette für Marker, Icons und Badges.
Color chainColorFor(SupermarketChain chain) {
  switch (chain) {
    case SupermarketChain.lidl:
      return const Color(0xFF0050AA);
    case SupermarketChain.aldi_sued:
    case SupermarketChain.aldi_nord:
      return const Color(0xFF001A9C);
    case SupermarketChain.rewe:
      return const Color(0xFFCC071E);
    case SupermarketChain.netto:
      return const Color(0xFFE2A800);
    case SupermarketChain.dm:
      return const Color(0xFF2F2482);
    case SupermarketChain.rossmann:
      return const Color(0xFFC8102E);
  }
}

/// Kurzes Label für den Marker-Badge.
String chainBadgeFor(SupermarketChain chain) {
  switch (chain) {
    case SupermarketChain.lidl:
      return 'LIDL';
    case SupermarketChain.aldi_sued:
    case SupermarketChain.aldi_nord:
      return 'ALDI';
    case SupermarketChain.rewe:
      return 'REWE';
    case SupermarketChain.netto:
      return 'NETTO';
    case SupermarketChain.dm:
      return 'dm';
    case SupermarketChain.rossmann:
      return 'ROSS';
  }
}
