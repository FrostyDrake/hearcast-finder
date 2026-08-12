import 'package:flutter/material.dart';

void main() {
  runApp(const HearCastFinderApp());
}

class HearCastFinderApp extends StatelessWidget {
  const HearCastFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HearCast Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF146C63)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _candidateLocations = [
    CandidateLocation(
      name: 'City Conference Hall',
      category: 'Conference',
      note: 'Likely place to check for public audio later.',
    ),
    CandidateLocation(
      name: 'Central Station Platform',
      category: 'Transport',
      note: 'Could be useful for announcements.',
    ),
    CandidateLocation(
      name: 'Museum Auditorium',
      category: 'Museum',
      note: 'Candidate for guided tours and lectures.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HearCast Finder')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Find public audio locations',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Day 1 prototype: a simple starting point for an Android app that will later find and verify Auracast-compatible places.',
          ),
          const SizedBox(height: 24),
          Text(
            'Candidate location ideas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final location in _candidateLocations)
            CandidateLocationCard(location: location),
          const SizedBox(height: 24),
          const _NextStepsCard(),
        ],
      ),
    );
  }
}

class CandidateLocation {
  const CandidateLocation({
    required this.name,
    required this.category,
    required this.note,
  });

  final String name;
  final String category;
  final String note;
}

class CandidateLocationCard extends StatelessWidget {
  const CandidateLocationCard({
    required this.location,
    super.key,
  });

  final CandidateLocation location;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.hearing_outlined),
        title: Text(location.name),
        subtitle: Text('${location.category} • ${location.note}'),
      ),
    );
  }
}

class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Next: add navigation and replace these simple records with real data models.',
        ),
      ),
    );
  }
}
