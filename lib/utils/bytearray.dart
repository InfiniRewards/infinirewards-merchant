import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:starknet/starknet.dart';
import 'dart:convert' show utf8;

@immutable
class ByteArray {
  final List<Felt> data;
  final Felt pendingWord;
  final int pendingWordLen;

  const ByteArray({
    required this.data,
    required this.pendingWord,
    required this.pendingWordLen,
  });

  static const int bytesPerFelt = 31;

  factory ByteArray.fromString(String input) {
    // Convert string to bytes
    final bytes = utf8.encode(input);
    return ByteArray.fromBytes(bytes);
  }

  factory ByteArray.fromBytes(List<int> bytes) {
    final data = <Felt>[];

    // Process full 31-byte chunks
    for (var i = 0; i < bytes.length - bytesPerFelt; i += bytesPerFelt) {
      final chunk = bytes.sublist(i, i + bytesPerFelt);
      data.add(_bytesToFelt(chunk));
    }

    // Process remaining bytes (0-30 bytes) as pending word
    final remainingBytes = bytes.length % bytesPerFelt;
    final pendingWordLen = remainingBytes == 0 ? 0 : remainingBytes;
    final pendingWord = pendingWordLen == 0
        ? Felt.zero
        : _bytesToFelt(bytes.sublist(bytes.length - pendingWordLen));

    return ByteArray(
      data: data,
      pendingWord: pendingWord,
      pendingWordLen: pendingWordLen,
    );
  }

  static Felt _bytesToFelt(List<int> bytes) {
    var value = BigInt.zero;
    for (final byte in bytes) {
      value = (value << 8) | BigInt.from(byte);
    }
    return Felt(value);
  }

  List<int> toBytes() {
    final result = <int>[];

    // Convert full words
    for (final word in data) {
      result.addAll(_feltToBytes(word, bytesPerFelt));
    }

    // Add pending word bytes
    if (pendingWordLen > 0) {
      result.addAll(_feltToBytes(pendingWord, pendingWordLen));
    }

    return result;
  }

  static List<int> _feltToBytes(Felt felt, int byteLength) {
    final hex = felt.toHexString().substring(2).padLeft(byteLength * 2, '0');
    final bytes = <int>[];
    for (var i = 0; i < byteLength * 2; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  @override
  String toString() {
    return utf8.decode(toBytes());
  }

  List<Felt> toCallData() {
    return [
      Felt(BigInt.from(data.length)),
      ...data,
      pendingWord,
      Felt(BigInt.from(pendingWordLen)),
    ];
  }

  factory ByteArray.fromCallData(List<Felt> callData) {
    final dataLength = callData[0].toBigInt().toInt();
    final data = callData.sublist(1, dataLength + 1);
    final pendingWord = callData[dataLength + 1];
    final pendingWordLen = callData[dataLength + 2].toBigInt().toInt();

    return ByteArray(
      data: data,
      pendingWord: pendingWord,
      pendingWordLen: pendingWordLen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((felt) => felt.toString()).toList(),
      'pending_word': pendingWord.toString(),
      'pending_word_len': pendingWordLen,
    };
  }

  factory ByteArray.fromJson(Map<String, dynamic> json) {
    return ByteArray(
      data: (json['data'] as List)
          .map((felt) => Felt(BigInt.parse(felt as String)))
          .toList(),
      pendingWord: Felt(BigInt.parse(json['pending_word'] as String)),
      pendingWordLen: json['pending_word_len'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ByteArray &&
          _listEquals(data, other.data) &&
          pendingWord == other.pendingWord &&
          pendingWordLen == other.pendingWordLen;

  bool _listEquals(List<Felt> a, List<Felt> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(data),
        pendingWord,
        pendingWordLen,
      );
}
