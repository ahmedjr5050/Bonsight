import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bonssight/features/analysis/data/models/analysis_result_model.dart';

class HistoryRemoteDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userAnalyses(String uid) =>
      _db.collection('users').doc(uid).collection('analyses');

  DocumentReference<Map<String, dynamic>> _imageDoc(String uid, String docId) =>
      _db.collection('users').doc(uid).collection('analysisImages').doc(docId);

  Future<void> saveAnalysis({
    required String uid,
    required String imageName,
    required Uint8List imageBytes,
    required AnalysisResult result,
  }) async {
    log('── Saving Analysis ───────────────────────────');
    log('Image      : $imageName (${imageBytes.lengthInBytes} bytes)');
    log('Detections : ${result.detections.length}');

    // Step 1: Save metadata + detections to Firestore
    DocumentReference<Map<String, dynamic>>? docRef;
    try {
      docRef = await _userAnalyses(uid).add({
        'imageName': imageName,
        'timestampMs': DateTime.now().toUtc().millisecondsSinceEpoch,
        'detections': result.detections
            .map((d) => {
                  'fractureType': d.fractureType,
                  'confidence': d.confidence,
                  'severity': d.severity,
                  'treatment': d.treatment,
                  'description': d.description,
                })
            .toList(),
      });
      log('Firestore  : saved (doc=${docRef.id})');
    } catch (e) {
      log('Firestore  : FAILED — $e');
      log('─────────────────────────────────────────────');
      return;
    }

    // Step 2: Save image bytes as base64 in a separate document (avoids Firebase Storage)
    // Max safe size: ~700KB original → ~933KB base64, under Firestore's 1MB doc limit
    if (imageBytes.lengthInBytes <= 700 * 1024) {
      try {
        final base64Image = base64Encode(imageBytes);
        await _imageDoc(uid, docRef.id).set({'imageBase64': base64Image});
        log('Image      : saved as base64 (${base64Image.length} chars)');
      } catch (e) {
        log('Image      : FAILED to save — $e');
      }
    } else {
      log('Image      : skipped (too large: ${imageBytes.lengthInBytes} bytes)');
    }

    log('─────────────────────────────────────────────');
  }

  Future<Uint8List?> getAnalysisImage(String uid, String docId) async {
    try {
      final doc = await _imageDoc(uid, docId).get();
      if (!doc.exists) return null;
      final base64Str = doc.data()?['imageBase64'] as String?;
      if (base64Str == null) return null;
      return base64Decode(base64Str);
    } catch (e) {
      log('Failed to load analysis image: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getHistory(String uid) async {
    try {
      final snapshot = await _userAnalyses(uid)
          .orderBy('timestampMs', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final tsMs = (data['timestampMs'] as num?)?.toInt();
        final detections = (data['detections'] as List?) ?? [];
        return {
          'id': doc.id,
          'imageName': data['imageName'] ?? 'Unknown',
          'timestamp': tsMs != null
              ? DateTime.fromMillisecondsSinceEpoch(tsMs, isUtc: true).toLocal()
              : null,
          'detections': detections,
        };
      }).toList();
    } catch (e) {
      log('Failed to load history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getDashboardStats(String uid) async {
    try {
      final snapshot = await _userAnalyses(uid)
          .orderBy('timestampMs', descending: true)
          .get();

      final docs = snapshot.docs;
      final total = docs.length;
      final withDetections = docs.where((doc) {
        final dets = doc.data()['detections'] as List? ?? [];
        return dets.isNotEmpty;
      }).length;

      final recent = docs.take(3).map((doc) {
        final data = doc.data();
        final tsMs = (data['timestampMs'] as num?)?.toInt();
        final detections = (data['detections'] as List?) ?? [];
        return {
          'id': doc.id,
          'imageName': data['imageName'] ?? 'Unknown',
          'timestamp': tsMs != null
              ? DateTime.fromMillisecondsSinceEpoch(tsMs, isUtc: true).toLocal()
              : null,
          'detections': detections,
        };
      }).toList();

      return {'total': total, 'withDetections': withDetections, 'recent': recent};
    } catch (e) {
      log('Failed to get dashboard stats: $e');
      return {'total': 0, 'withDetections': 0, 'recent': []};
    }
  }
}
