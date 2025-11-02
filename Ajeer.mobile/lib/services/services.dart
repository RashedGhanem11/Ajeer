import 'package:flutter/material.dart';

class Service {
  final String name;
  final IconData icon;
  final Map<String, UnitType> unitTypes;

  const Service({
    required this.name,
    required this.icon,
    required this.unitTypes,
  });
}

class UnitType {
  final int estimatedTimeMinutes;
  final double priceJOD;

  const UnitType({required this.estimatedTimeMinutes, required this.priceJOD});
}

const Map<String, UnitType> cleaningUnitTypes = {
  'Deep Cleaning': UnitType(estimatedTimeMinutes: 180, priceJOD: 55.0),
  'House Keeping': UnitType(estimatedTimeMinutes: 120, priceJOD: 35.0),
  'Office Cleaning': UnitType(estimatedTimeMinutes: 150, priceJOD: 40.0),
  'Move In/Out Cleaning': UnitType(estimatedTimeMinutes: 240, priceJOD: 60.0),
  'Carpet Cleaning': UnitType(estimatedTimeMinutes: 90, priceJOD: 25.0),
};

const Map<String, UnitType> plumbingUnitTypes = {
  'Drain Cleaning': UnitType(estimatedTimeMinutes: 60, priceJOD: 20.0),
  'Water Heater Repair': UnitType(estimatedTimeMinutes: 90, priceJOD: 35.0),
  'Leaky Faucet Fix': UnitType(estimatedTimeMinutes: 45, priceJOD: 15.0),
  'Toilet Installation': UnitType(estimatedTimeMinutes: 150, priceJOD: 45.0),
};

const Map<String, UnitType> electricalUnitTypes = {
  'Wiring Repair': UnitType(estimatedTimeMinutes: 120, priceJOD: 50.0),
  'Outlet/Switch Replacement': UnitType(
    estimatedTimeMinutes: 60,
    priceJOD: 25.0,
  ),
  'Light Fixture Installation': UnitType(
    estimatedTimeMinutes: 90,
    priceJOD: 30.0,
  ),
};

const List<Service> kAvailableServices = [
  Service(
    name: 'Cleaning',
    icon: Icons.cleaning_services,
    unitTypes: cleaningUnitTypes,
  ),
  Service(name: 'Plumbing', icon: Icons.plumbing, unitTypes: plumbingUnitTypes),
  Service(
    name: 'Electrical',
    icon: Icons.electrical_services,
    unitTypes: electricalUnitTypes,
  ),
  Service(name: 'Gardening', icon: Icons.grass, unitTypes: {}),
  Service(name: 'Assembly', icon: Icons.handyman, unitTypes: {}),
  Service(name: 'Painting', icon: Icons.format_paint, unitTypes: {}),
  Service(name: 'Pest Control', icon: Icons.pest_control, unitTypes: {}),
  Service(name: 'AC Repair', icon: Icons.ac_unit, unitTypes: {}),
  Service(name: 'Carpentry', icon: Icons.carpenter, unitTypes: {}),
];
