import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/feeding.dart';
import '../models/animal.dart';
import '../providers/animal_provider.dart';
import '../theme/app_theme.dart';
import 'add_feeding_screen.dart';
import 'edit_feeding_screen.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  List<Animal> _animals = [];
  Map<int, Feeding> _feedings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AnimalProvider>(context, listen: false);
    await provider.loadAnimals();
    final animals = provider.animals;
    final Map<int, Feeding> feedings = {};

    for (final animal in animals) {
      if (animal.id != null) {
        final feeding = provider.getFeedingByAnimal(animal.id!);
        if (feeding != null) {
          feedings[animal.id!] = feeding;
        }
      }
    }

    setState(() {
      _animals = animals;
      _feedings = feedings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _animals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.restaurant, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun animal enregistré',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _animals.length,
                      itemBuilder: (context, index) {
                        final animal = _animals[index];
                        final feeding = animal.id != null ? _feedings[animal.id!] : null;
                        return _FeedingCard(
                          animal: animal,
                          feeding: feeding,
                          onTap: () => _showFeedingDetails(animal, feeding),
                          onMarkAsFed: () => _markAsFed(animal),
                          onRestock: feeding != null ? () => _showRestockDialog(context, animal, feeding!) : null,
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFeedingScreen(),
            ),
          );
          _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFeedingDetails(Animal animal, Feeding? feeding) {
    if (feeding == null) return;

    // Simuler des données de consommation hebdomadaire
    final weeklyConsumption = List.generate(7, (index) {
      // Variation de ±10% autour de la consommation quotidienne
      final variation = 0.9 + (index % 3) * 0.1;
      return feeding.dailyQuantity * variation;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.restaurant, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(child: Text('Détails alimentation - ${animal.name}')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations principales
              _DetailCard(
                icon: Icons.fastfood,
                title: 'Régime',
                value: feeding.foodType,
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _DetailCard(
                icon: Icons.scale,
                title: 'Quantité quotidienne',
                value: '${feeding.dailyQuantity.toStringAsFixed(0)} g',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _DetailCard(
                icon: Icons.access_time,
                title: 'Heures de repas',
                value: feeding.mealTimes.join(', '),
                color: Colors.purple,
              ),
              const SizedBox(height: 16),
              
              // Graphique de consommation hebdomadaire
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Consommation hebdomadaire',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (index) {
                          final dayNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                          final maxConsumption = weeklyConsumption.reduce((a, b) => a > b ? a : b);
                          final height = (weeklyConsumption[index] / maxConsumption) * 120;
                          
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 30,
                                height: height,
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.7),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${weeklyConsumption[index].toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dayNames[index],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Stock
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: feeding.stockStatus == StockStatus.critical
                      ? Colors.red.shade50
                      : feeding.stockStatus == StockStatus.warning
                          ? Colors.orange.shade50
                          : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: feeding.stockStatus == StockStatus.critical
                        ? Colors.red
                        : feeding.stockStatus == StockStatus.warning
                            ? Colors.orange
                            : Colors.green,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory,
                          color: feeding.stockStatus == StockStatus.critical
                              ? Colors.red
                              : feeding.stockStatus == StockStatus.warning
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Stock actuel: ${feeding.currentStock.toStringAsFixed(0)} g',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (feeding.currentStock / (feeding.dailyQuantity * 30)).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[300],
                      minHeight: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        feeding.stockStatus == StockStatus.critical
                            ? Colors.red
                            : feeding.stockStatus == StockStatus.warning
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jours restants: ${feeding.daysUntilStockout}',
                      style: TextStyle(
                        color: feeding.stockStatus == StockStatus.critical
                            ? Colors.red
                            : feeding.stockStatus == StockStatus.warning
                                ? Colors.orange
                                : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditFeedingScreen(
                    feeding: feeding,
                    animal: animal,
                  ),
                ),
              ).then((_) => _loadData());
            },
            icon: const Icon(Icons.edit),
            label: const Text('Modifier'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Confirmer la suppression'),
                    ],
                  ),
                  content: Text(
                    'Êtes-vous sûr de vouloir supprimer le plan d\'alimentation "${feeding.foodType}" pour ${animal.name} ?\n\nCette action est irréversible.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                final provider = Provider.of<AnimalProvider>(context, listen: false);
                await provider.deleteFeeding(feeding.id!);
                _loadData();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Plan d\'alimentation supprimé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
          if (feeding.stockStatus == StockStatus.critical || 
              feeding.stockStatus == StockStatus.warning)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showRestockDialog(context, animal, feeding);
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Réapprovisionner'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
        ],
      ),
    );
  }

  Future<void> _markAsFed(Animal animal) async {
    // Marquer le repas comme effectué
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Repas de ${animal.name} marqué comme effectué'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showRestockDialog(BuildContext context, Animal animal, Feeding feeding) {
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.inventory, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Réapprovisionner - ${animal.name}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stock actuel: ${feeding.currentStock.toStringAsFixed(0)} g'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantité à ajouter (g)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.add_circle),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = double.tryParse(quantityController.text);
              if (quantity != null && quantity > 0) {
                final provider = Provider.of<AnimalProvider>(context, listen: false);
                provider.restockFeeding(feeding.id!, quantity);
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Stock de ${animal.name} mis à jour (+${quantity.toStringAsFixed(0)} g)'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer une quantité valide'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Réapprovisionner', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedingCard extends StatelessWidget {
  final Animal animal;
  final Feeding? feeding;
  final VoidCallback onTap;
  final VoidCallback onMarkAsFed;
  final VoidCallback? onRestock;

  const _FeedingCard({
    required this.animal,
    this.feeding,
    required this.onTap,
    required this.onMarkAsFed,
    this.onRestock,
  });

  @override
  Widget build(BuildContext context) {
    if (feeding == null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.pets),
          ),
          title: Text(animal.name),
          subtitle: const Text('Aucun plan d\'alimentation'),
          trailing: const Icon(Icons.add),
          onTap: onTap,
        ),
      );
    }

    final stockPercentage = (feeding!.currentStock / (feeding!.dailyQuantity * 30)) * 100;
    final stockColor = feeding!.stockStatus == StockStatus.critical
        ? Colors.red
        : feeding!.stockStatus == StockStatus.warning
            ? Colors.orange
            : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onMarkAsFed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: const Icon(Icons.restaurant, color: Colors.orange),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          feeding!.foodType,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Jauge de stock
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stock: ${feeding!.currentStock.toStringAsFixed(0)} g',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (stockPercentage / 100).clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${feeding!.daysUntilStockout} jours restants',
                          style: TextStyle(
                            fontSize: 12,
                            color: stockColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Heures de repas
              Wrap(
                spacing: 8,
                children: feeding!.mealTimes.map((time) {
                  return Chip(
                    label: Text(time),
                    avatar: const Icon(Icons.access_time, size: 16),
                  );
                }).toList(),
              ),
              // Alerte de stock
              if (feeding!.stockStatus == StockStatus.critical ||
                  feeding!.stockStatus == StockStatus.warning)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: stockColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: stockColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: stockColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Stock faible: épuisement dans ${feeding!.daysUntilStockout} jours',
                          style: TextStyle(color: stockColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: onRestock,
                        child: const Text('Réapprovisionner'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


