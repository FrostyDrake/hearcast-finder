import '../../models/auracast_location.dart';

const sampleLocations = [
  AuracastLocation(
    id: 'city-conference-hall',
    name: 'City Conference Hall',
    address: 'Main Street 12',
    city: 'Copenhagen',
    category: LocationCategory.conference,
    status: LocationStatus.candidate,
    latitude: 55.6761,
    longitude: 12.5683,
  ),
  AuracastLocation(
    id: 'central-station-platform',
    name: 'Central Station Platform',
    address: 'Banegaardspladsen',
    city: 'Copenhagen',
    category: LocationCategory.transport,
    status: LocationStatus.candidate,
    latitude: 55.6728,
    longitude: 12.5656,
  ),
  AuracastLocation(
    id: 'museum-auditorium',
    name: 'Museum Auditorium',
    address: 'Gallery Road 4',
    city: 'Aarhus',
    category: LocationCategory.museum,
    status: LocationStatus.unknown,
    latitude: 56.1629,
    longitude: 10.2039,
  ),
];
